--Miku, Aquatic Respiration
function c9947545.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,9947545+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c9947545.target)
	e1:SetOperation(c9947545.activate)
	c:RegisterEffect(e1)
	--Special
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,9947546)
	e2:SetCost(c9947545.thcost)
	e2:SetCondition(c9947545.thcon)
	e2:SetTarget(c9947545.thtg)
	e2:SetOperation(c9947545.thop)
	c:RegisterEffect(e2)
end
function c9947545.tgfilter1(c)
	return c:IsCode(9947500) and c:IsAbleToGrave()
end
function c9947545.tgfilter2(c)
	return c:IsSetCard(0x12E8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c9947545.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9947545.tgfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c9947545.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c9947545.tgfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		local tc=g:GetFirst()
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c9947545.tgfilter2),tp,LOCATION_GRAVE,0,tc)
		if mg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(9947545,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,tc)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

function c9947545.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c9947545.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSetCard(0x12E8) and c:GetSummonPlayer()==tp and Duel.GetTurnPlayer()~=tp
end
function c9947545.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9947545.cfilter,1,nil,tp)
end
function c9947545.spfilter(c,eg,e,tp)
	return c:IsReason(REASON_SYNCHRO) and eg:IsContains(c:GetReasonCard()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c9947545.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c9947545.spfilter(chkc,eg,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c9947545.spfilter,tp,LOCATION_GRAVE,0,1,nil,eg,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c9947545.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,eg,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c9947545.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
