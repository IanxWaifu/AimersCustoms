--Neko Cinnamon
function c455558.initial_effect(c)
	--fusion substitute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(c455558.subcon)
	e1:SetCountLimit(1,455558)
	e1:SetValue(c455558.subval)
	c:RegisterEffect(e1)
	--ToDeck Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(455558,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,455559)
	e2:SetCondition(c455558.tdcon)
	e2:SetTarget(c455558.tdtg)
	e2:SetOperation(c455558.tdop)
	c:RegisterEffect(e2)
	--Add Code
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_ADD_CODE)
	e3:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE)
	e3:SetValue(455552)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_ADD_CODE)
	e4:SetRange(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE)
	e4:SetValue(455554)
	c:RegisterEffect(e4)
end
function c455558.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
function c455558.subval(e,c)
	return c:IsSetCard(0x1194)
end
function c455558.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e and e:GetHandler():IsSetCard(0x1194) and e:GetHandler():IsReason(REASON_EFFECT+REASON_COST)
end
function c455558.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1194)
end
function c455558.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(c455558.tdfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c455558.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c455558.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetValue(c455558.aclimit)
	e1:SetCondition(c455558.actcon)
	tc:RegisterEffect(e1)
	end
end
function c455558.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function c455558.actcon(e)
	return (Duel.GetAttacker()==e:GetHandler()) or (Duel.GetAttackTarget()==e:GetHandler())
end
