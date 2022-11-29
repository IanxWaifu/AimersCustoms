function c1706.initial_effect(c)
	c:SetUniqueOnField(1,0,1706)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1706.target)
	e1:SetOperation(c1706.operation)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c1706.eqlimit)
	c:RegisterEffect(e2)
	--Destroy Sub
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c1706.reptg)
	e3:SetOperation(c1706.repop)
	c:RegisterEffect(e3)
	--Targeted Immune
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1706,1))
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c1706.efilter)
	c:RegisterEffect(e4)
end
function c1706.eqlimit(e,c)
	local code=c:GetCode()
	return code==1705
end
function c1706.filter(c)
	local code=c:GetCode()
	return c:IsFaceup() and (code==1705)
end
function c1706.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1706.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1706.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c1706.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c1706.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
function c1706.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	return Duel.SelectYesNo(tp,aux.Stringid(1706,0))
end
function c1706.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
function c1706.efilter(e,re)
	return e:GetHandler():GetEquipTarget() and e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end