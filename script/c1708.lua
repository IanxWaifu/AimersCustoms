function c1708.initial_effect(c)
	c:SetUniqueOnField(1,0,1708)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1708.target)
	e1:SetOperation(c1708.operation)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c1708.eqlimit)
	c:RegisterEffect(e2)
	--Equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1708,0))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c1708.eqcost)
	e3:SetTarget(c1708.eqtg)
	e3:SetOperation(c1708.eqop)
	e3:SetCountLimit(1,1708)
	c:RegisterEffect(e3)
end
function c1708.eqlimit(e,c)
	local code=c:GetCode()
	return code==1707
end
function c1708.filter(c)
	local code=c:GetCode()
	return c:IsFaceup() and (code==1707)
end
function c1708.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1708.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1708.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c1708.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c1708.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
function c1708.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c1708.filter2(c,ec)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6A4)
end
function c1708.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=e:GetHandler():GetEquipTarget()
	if chkc then return chkc:IsLocation(LOCATION_DECK+LOCATION_GRAVE) and chkc:IsControler(tp) and c1708.filter2(chkc,ec) end
	if chk==0 then return ec and Duel.IsExistingMatchingCard(c1708.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,ec) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,ec,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	e:GetLabelObject():CreateEffectRelation(e)
end
function c1708.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=e:GetLabelObject()
	if ec:IsRelateToEffect(e) and ec:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,c1708.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e:GetLabelObject())
		local eqc=g:GetFirst()
		local code=eqc:GetOriginalCode()
		if not eqc or not Duel.Equip(tp,eqc,ec,true) then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c1708.eqlimit2)
		e1:SetLabelObject(ec)
		eqc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(1708,1))
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(code)
		eqc:RegisterEffect(e2)
		ec:CopyEffect(code,RESET_EVENT+0x1fe0000)
		end
	end
function c1708.eqlimit2(e,c)
	return e:GetLabelObject()==c
end
