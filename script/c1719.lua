function c1719.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetCondition(c1719.atkcon)
	e1:SetValue(3200)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1719,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,1719)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c1719.eqtg)
	e2:SetOperation(c1719.eqop)
	c:RegisterEffect(e2)
end
function c1719.atkfilter(c)
	return c:IsCode(1703) and c:IsFaceup()
end
function c1719.atkcon(e,c)
	return Duel.IsExistingMatchingCard(c1719.atkfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function c1719.filter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x6D6)
end
function c1719.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c1719.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
end
function c1719.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,c1719.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,c)
	if g:GetCount()==0 then return end
 	local sc=g:GetFirst()
 		Duel.Equip(tp,sc,c,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c1719.eqlimit)
		e1:SetLabelObject(c)
		sc:RegisterEffect(e1)
end
function c1719.eqlimit(e,c)
 return e:GetLabelObject()==c
end