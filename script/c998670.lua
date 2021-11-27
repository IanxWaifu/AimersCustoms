--Scripted by IanxWaifu
--Kijin, Akki no Tenohono Ningen
local s,id=GetID()
function s.initial_effect(c)
   --Activate
   local e1=Effect.CreateEffect(c)
   e1:SetDescription(aux.Stringid(id,0))
   e1:SetType(EFFECT_TYPE_ACTIVATE)
   e1:SetCode(EVENT_CHAINING)
   e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
   e1:SetCountLimit(1,id)
   e1:SetCondition(s.negcon)
   e1:SetTarget(s.negtg)
   e1:SetOperation(s.negop)
   c:RegisterEffect(e1)
   -- Set itself from GY
   local e2=Effect.CreateEffect(c)
   e2:SetDescription(aux.Stringid(id,1))
   e2:SetType(EFFECT_TYPE_QUICK_O)
   e2:SetProperty(EFFECT_FLAG_DELAY)
   e2:SetCode(EVENT_FREE_CHAIN)
   e2:SetRange(LOCATION_GRAVE)
   e2:SetCountLimit(1,id)
   e2:SetCost(s.setcost)
   e2:SetTarget(s.settg)
   e2:SetOperation(s.setop)
   c:RegisterEffect(e2)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   if ep==tp then return false end
   return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end


function s.cfilter(c)
   return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x12EA) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_CONTINUOUS)
end
function s.filter(c,e)
   return c:IsSetCard(0x12EA) and c:IsCanBeEffectTarget(e)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e) end
   if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
      and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e)  end
   local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)
   local dg2=Group.GetCount(dg)
   if dg2==0 then return end
   if dg2>3 then dg2=3 end
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
   local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,dg2,nil)
   Duel.Remove(rg,POS_FACEUP,REASON_COST)
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
   local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,rg:GetCount(),rg:GetCount(),nil,e)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
   local dg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
   for tc in aux.Next(dg) do
      if tc:IsRelateToEffect(e) and tc:IsOnField() and tc:IsFaceup() then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetDescription(aux.Stringid(id,0))
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_IMMUNE_EFFECT)
      e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
      e1:SetReset(RESET_CHAIN)
      e1:SetValue(s.efilter)
      tc:RegisterEffect(e1)
      end
   end
end
function s.efilter(e,te)
   local c=te:GetHandler()
   return te:GetOwner()~=e:GetOwner() 
end

function s.setcostfilter(c)
   return c:IsSetCard(0x12EA) and c:IsType(TYPE_RITUAL+TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.IsExistingMatchingCard(s.setcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
   local g=Duel.SelectMatchingCard(tp,s.setcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
   Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return e:GetHandler():IsSSetable() end
   Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   if c:IsRelateToEffect(e) and c:IsSSetable() then
      Duel.SSet(tp,c)
      -- Banish it if it leaves the field
      local e1=Effect.CreateEffect(c)
      e1:SetDescription(3300)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
      e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
      e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
      e1:SetValue(LOCATION_REMOVED)
      c:RegisterEffect(e1)
   end
end
