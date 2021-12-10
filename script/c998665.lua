--Scripted by IanxWaifu
--Moeru Yöna Tamashi no Ikari
local s,id=GetID()
function s.initial_effect(c)
   --Activate
   local e1=Effect.CreateEffect(c)
   e1:SetType(EFFECT_TYPE_ACTIVATE)
   e1:SetCode(EVENT_FREE_CHAIN)
   e1:SetCountLimit(1,id)
   e1:SetTarget(s.acttg)
   e1:SetOperation(s.actop)
   c:RegisterEffect(e1)
   --Special Summon
   local e2=Effect.CreateEffect(c)
   e2:SetDescription(aux.Stringid(id,3))
   e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
   e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
   e2:SetCode(EVENT_LEAVE_FIELD)
   e2:SetRange(LOCATION_GRAVE)
   e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
   e2:SetCountLimit(1,id)
   e2:SetCondition(s.spcon)
   e2:SetCost(aux.bfgcost)
   e2:SetTarget(s.sptg)
   e2:SetOperation(s.spop)
   c:RegisterEffect(e2)
 end
function s.actfilter2(c,code)
   return c:IsFaceup() and c:IsCode(code)
end
function s.actfilter(c,tp,cd)
   return c:IsSetCard(0x12EA) and c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true)
      and not Duel.IsExistingMatchingCard(s.actfilter2,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode()) and not c:IsCode(cd)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
   Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,cd,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
   if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
   local sg=Duel.SelectMatchingCard(tp,s.actfilter2,tp,LOCATION_DECK,0,1,1,nil,cd,tp)
   local tc=sg:GetFirst()
   local te=tc:GetActivateEffect()
   if not te then return end
   local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
   if pre[1] then
      for i,eff in ipairs(pre) do
         local prev=eff:GetValue()
         if type(prev)~='function' or prev(eff,te,tp) then return end
      end
   end
   if tc then
   Duel.HintSelection(sg)
      te:UseCountLimit(tp,1)
      local tpe=tc:GetType()
      local tg=te:GetTarget()
      local co=te:GetCost()
      local op=te:GetOperation()
      e:SetCategory(te:GetCategory())
      e:SetProperty(te:GetProperty())
      Duel.ClearTargetCard()
      local loc=LOCATION_SZONE
      if (tpe&TYPE_FIELD)~=0 then
         loc=LOCATION_FZONE
         local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
         if Duel.IsDuelType(DUEL_1_FIELD) then
            if fc then Duel.Destroy(fc,REASON_RULE) end
            fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
            if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
         else
            fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
            if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
         end
      end
      Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
      if (tpe&TYPE_FIELD)==TYPE_FIELD then
         Duel.MoveSequence(tc,5)
      end
      Duel.Hint(HINT_CARD,0,tc:GetCode())
      tc:CreateEffectRelation(te)
      if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
         tc:CancelToGrave(false)
      end
      if te:GetCode()==EVENT_CHAINING then
         local chain=Duel.GetCurrentChain()-1
         local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
         local tc=te2:GetHandler()
         local g=Group.FromCards(tc)
         local p=tc:GetControler()
         if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
         if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
      elseif te:GetCode()==EVENT_FREE_CHAIN then
         if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
         if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
      else
         local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
         if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
         if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
      end
      Duel.BreakEffect()
      local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
      if g then
         local etc=g:GetFirst()
         while etc do
            etc:CreateEffectRelation(te)
            etc=g:GetNext()
         end
      end
      tc:SetStatus(STATUS_ACTIVATED,true)
      if not tc:IsDisabled() then
         if te:GetCode()==EVENT_CHAINING then
            local chain=Duel.GetCurrentChain()-1
            local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
            local tc=te2:GetHandler()
            local g=Group.FromCards(tc)
            local p=tc:GetControler()
            if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
         elseif te:GetCode()==EVENT_FREE_CHAIN then
            if op then op(te,tp,eg,ep,ev,re,r,rp) end
         else
            local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
            if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
         end
      else
         --insert negated animation here
      end
      Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
      if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
         Duel.Equip(tp,tc,g:GetFirst())
      end
      tc:ReleaseEffectRelation(te)
      if etc then
         etc=g:GetFirst()
         while etc do
            etc:ReleaseEffectRelation(te)
            etc=g:GetNext()
         end
      end
   end
end
end



function s.costfilter(c,tp)
   return c:IsPreviousSetCard(0x12EA) and c:GetReasonPlayer()==1-tp
      and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
      and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
   return eg:IsExists(s.costfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
   return c:IsSetCard(0x12EA) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4) and c:IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
   if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
   if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) 
      and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
   local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
   Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
   if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
   local tc=Duel.GetFirstTarget()
   if tc and tc:IsRelateToEffect(e) then
      Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
   end
end

