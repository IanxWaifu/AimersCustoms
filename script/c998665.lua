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
   local sg=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,cd,tp)
   local tc=sg:GetFirst()
   if tc then
   Duel.HintSelection(sg)
   local tpe=tc:GetType()
   local te=tc:GetActivateEffect()
   local tg=te:GetTarget()
   local co=te:GetCost()
   local op=te:GetOperation()
   e:SetCategory(te:GetCategory())
   e:SetProperty(te:GetProperty())
   Duel.ClearTargetCard()
   if bit.band(tpe,TYPE_FIELD)~=0 and not tc:IsType(TYPE_FIELD) and not tc:IsFacedown() then
      local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
      if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
         if fc then Duel.Destroy(fc,REASON_RULE) end
         fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
         if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
      else
         fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
         if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
      end
   end
   Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
   if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
   Duel.Hint(HINT_CARD,0,tc:GetCode())
   tc:CreateEffectRelation(te)
   if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
      tc:CancelToGrave(false)    
   end
   if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
   if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
   Duel.BreakEffect()
   local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
   if g then
      local etc=g:GetFirst()
      while etc do
         etc:CreateEffectRelation(te)
         etc=g:GetNext()
      end
   end
   if op then op(te,tp,eg,ep,ev,re,r,rp) end
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

