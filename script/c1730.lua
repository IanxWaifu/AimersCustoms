--Servant Caster, Lily
function c1730.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsCode,1728),1,1,Synchro.NonTuner(Card.IsSetCard,0x6A4),1,1)
	c:EnableReviveLimit()
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetValue(1707)
	c:RegisterEffect(e1)	
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c1730.glpop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1730,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,1730)
	e3:SetTarget(c1730.target)
	e3:SetOperation(c1730.operation)
	c:RegisterEffect(e3)
	--damage conversion
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_REVERSE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	c:RegisterEffect(e4)
end
function c1730.glpfilter(c)
	return c:IsSetCard(0x6D6)
end
function c1730.glpop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c1730.glpfilter,nil)
	if ct>0 then
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end
function c1730.tcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6A4) and Duel.IsExistingMatchingCard(c1730.ecfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
function c1730.ecfilter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x6D6) and c:CheckEquipTarget(tc)
end
function c1730.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1730.tcfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c1730.tcfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1730,0))
	Duel.SelectTarget(tp,c1730.tcfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end
function c1730.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local ec=Duel.SelectMatchingCard(tp,c1730.ecfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc):GetFirst()
		if ec then
			Duel.Equip(tp,ec,tc)
		end
	end
end
