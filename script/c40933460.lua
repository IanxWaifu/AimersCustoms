--Mecha Girl Nafumi
function c40933460.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,40933460)
	e1:SetCondition(c40933460.spcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40933460,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,40933461)
	e2:SetCondition(c40933460.regcon)
	e2:SetOperation(c40933460.regop)
	c:RegisterEffect(e2)
	---banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40933460,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,40933462)
	e3:SetCost(c40933460.atkcost)
	e3:SetOperation(c40933460.atkop)
	c:RegisterEffect(e3)
end
function c40933460.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3052)
end
function c40933460.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c40933460.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c40933460.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c40933460.regop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetCountLimit(1,40933463)
    e1:SetCondition(c40933460.thcon)
    e1:SetOperation(c40933460.thop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    Duel.RegisterEffect(e1,tp)
end
function c40933460.thfilter(c)
    return c:IsSetCard(0x3052) and c:IsType(TYPE_MONSTER) and not c:IsCode(40933460) and c:IsAbleToHand()
end
function c40933460.thcon(e,tp,eg,ep,ev,re,r,rp)
 return Duel.IsExistingMatchingCard(c40933460.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function c40933460.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,40933460)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c40933460.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        e:Reset()
    end
end
function c40933460.costfilter(c)
	return c:IsSetCard(0x3052) and c:IsAbleToRemoveAsCost()
end
function c40933460.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c40933460.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c40933460.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c40933460.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3052)
end
function c40933460.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c40933460.afilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)
		e1:SetValue(300)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

