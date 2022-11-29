--NP Bellerophon
function c1726.initial_effect(c)
	c:SetUniqueOnField(1,0,1726)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1726.target)
	e1:SetOperation(c1726.operation)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c1726.eqlimit)
	c:RegisterEffect(e2)
	--Negate Seq
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c1726.negtg)
	c:RegisterEffect(e3)
	--Negate DisSeq
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_DISABLE_EFFECT)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(c1726.negtg)
	c:RegisterEffect(e4)
	--To Hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(1726,0))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,1726)
	e5:SetCost(c1726.retcost)
	e5:SetTarget(c1726.rettg)
	e5:SetOperation(c1726.retop)
	c:RegisterEffect(e5)
end
function c1726.eqlimit(e,c)
	local code=c:GetCode()
	return code==1709
end
function c1726.filter(c)
	local code=c:GetCode()
	return c:IsFaceup() and (code==1709)
end
function c1726.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1726.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1726.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c1726.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c1726.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
function c1726.get_sequence(e)
  local c=e:GetHandler()
  c=c:GetEquipTarget()
   
  local seq=c and (4-c:GetSequence()) or nil
  local hasEquip=c and true or false
 
  return seq, hasEquip
end
 
function c1726.negtg(e,c)
  local seq,hasEquip=c1726.get_sequence(e)
 
  local isFaceup=c:IsFaceup()
  local isEffect=c:IsType(TYPE_EFFECT)
  local hasSequence=hasEquip and (c:GetSequence()==seq)
 
  return isFaceup and isEffect and hasSequence
end
function c1726.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function c1726.acfilter(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:GetSequence()<5
end
function c1726.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1726.acfilter,tp,0,LOCATION_SZONE,1,nil) end
	local g=Duel.GetMatchingGroup(c1726.acfilter,tp,0,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c1726.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c1726.acfilter,tp,0,LOCATION_SZONE,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)	
	end
end