--Azhimaou - Carminum
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	-- Activate (Special Summon + Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- GY/Banish effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET) 
	e2:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1}) 
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	-- Activity Counter for Special Summons
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.spsumfilter)
end

function s.spsumfilter(c)
	return not (c:IsSummonLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_AZHIMAOU))
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- Extra Deck Restriction
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
end

function s.splimit(e,c)
	return not c:IsSetCard(SET_AZHIMAOU) and c:IsLocation(LOCATION_EXTRA)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end

function s.stfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		-- Make Level 4
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- Set Possible Operation (send to GY or Set Spell/Trap)
		local op=0
		if Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)
			and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) then
			op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		else op=0 end

		-- Send to GY
		if op==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,1,1,c)
			if #sg>0 then 
				Duel.SendtoGrave(sg,REASON_EFFECT) 
			end
		-- Set Spell/Trap
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if sc then
				Duel.SSet(tp,sc)
				-- Activate in Set turn
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
				e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e3)
			end
		end
	end
end

-- GY/Banish Effect: Return to Deck and Add 1 "Azhimaou" card from GY to hand
function s.tdfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,c):GetFirst()
		if tc then 
			Duel.SendtoHand(tc,nil,REASON_EFFECT) 
			Duel.ConfirmCards(1-tp,tc) 
		end
	end
end