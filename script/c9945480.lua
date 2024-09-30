--Searching for a Sign
function c9945480.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,9945480+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c9945480.cost)
	e1:SetTarget(c9945480.target)
	e1:SetOperation(c9945480.activate)
	c:RegisterEffect(e1)
end
function c9945480.filter(c)
	return c:IsSetCard(0x12D7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c9945480.filter2(c)
	return c:IsSetCard(0x12D7) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c9945480.cfilter(c)
	return c:IsSetCard(0x12D7) and not c:IsPublic()
end
function c9945480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9945480.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c9945480.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c9945480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1 and Duel.IsExistingMatchingCard(c9945480.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(c9945480.filter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c9945480.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local ag=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9945480.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local sg=Duel.GetMatchingGroup(c9945480.filter2,tp,LOCATION_DECK,0,nil)
	if #ag>0 and Duel.SendtoHand(ag,nil,REASON_EFFECT)>0 and ag:GetFirst():IsLocation(LOCATION_HAND) and #sg>0 then
		Duel.ConfirmCards(1-tp,ag)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local tg=sg:Select(tp,1,1,nil)
		if tg and Duel.SSet(tp,tg:GetFirst())~=0 and tg:GetFirst():IsLocation(LOCATION_SZONE) then
			Duel.ConfirmCards(1-tp,tg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
