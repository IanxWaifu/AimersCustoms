--Miku's Endless Sea
function c9947505.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c9947505.activate)
	e1:SetCost(c9947505.cost)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(9947505,ACTIVITY_SPSUMMON,c9947505.counterfilter)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,9947506)
	e2:SetCondition(c9947505.thcon)
	e2:SetTarget(c9947505.thtg)
	e2:SetOperation(c9947505.thop)
	c:RegisterEffect(e2)
	--Banish
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c9947505.rmcon)
	e3:SetTarget(c9947505.rmtg)
	e3:SetOperation(c9947505.rmop)
	c:RegisterEffect(e3)
end
function c9947505.counterfilter(c)
	return c:IsSetCard(0x12E8)
end
function c9947505.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(9947505,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c9947505.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c9947505.spfilter(c,e,tp)
	return c:IsCode(9947500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetFlagEffect(tp,9947505)==0
end
function c9947505.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c9947505.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(9947505,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c9947505.sumlimit)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,9947505,RESET_PHASE+PHASE_END,0,1)
	end
end
function c9947505.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x12E8)
end
function c9947505.thcfilter(c,tp)
	return c:IsPreviousSetCard(0x12E8) and c:GetPreviousControler()==tp and c:IsPreviousPosition(POS_FACEUP)
end
function c9947505.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9947505.thcfilter,1,nil,tp)
end
function c9947505.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x12E8) and c:IsAbleToHand() and not c:IsCode(9947505)
end
function c9947505.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9947505.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c9947505.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c9947505.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c9947505.rmfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x12E8) and c:IsAbleToDeck() 
end
function c9947505.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9947505.rmfilter,1,nil,tp)
end
function c9947505.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(c9947505.rmfilter,nil,tp)
	local ct=g:GetCount()
	if chk==0 then return ct>0 end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,ct,0,0)
end
function c9947505.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c9947505.rmfilter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end

