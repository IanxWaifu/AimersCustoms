--Gate of Babylon
function c1722.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1722+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c1722.condition)
	e1:SetTarget(c1722.target)
	e1:SetOperation(c1722.activate)
	c:RegisterEffect(e1)
end
function c1722.cfilter(c)
	return c:IsFaceup() and c:IsCode(1721)
end
function c1722.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c1722.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c1722.filter(c)
	return (c:IsSetCard(0x6A4) or c:IsSetCard(0x6D6) or c:IsSetCard(0x708) or c:IsSetCard(0x73A)) and c:IsAbleToHand()
end
function c1722.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1722.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c1722.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c1722.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end