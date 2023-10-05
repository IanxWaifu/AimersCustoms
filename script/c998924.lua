--Scripted by IanxWaifu
--Tetra’s Chronicle of Iron Saga
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.CheckPhaseActivity()
end
--return to hand
function s.rtfilter(c)
	return c:IsSetCard(0x1A0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--to grave
function s.tgfilter(c)
	return c:IsSetCard(0x1A0) and c:IsAbleToGrave()
end
--special summon/set
function s.tffilter1(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x1A0)
end
function s.tffilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true) and c:IsSetCard(0x1A0)
end
function s.tffilter3(c,e,tp)
	return (c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x1A0)) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and c:IsSetCard(0x1A0))
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	local mz=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sz=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ph==PHASE_MAIN1 and Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g1=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #g1>0 then
			Duel.HintSelection(g1)
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
		end
	end
	if ph==PHASE_MAIN1 and Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_DECK,0,1,1,nil)
		if Duel.SendtoHand(g2,nil,REASON_EFFECT)~=0 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
	if ph==PHASE_MAIN2 and Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g3=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g3>0 then
			Duel.SendtoGrave(g3,REASON_EFFECT)
		end
	end
		if ph==PHASE_MAIN2 and Duel.IsExistingMatchingCard(s.tffilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then
		local g4=Duel.SelectMatchingCard(tp,s.tffilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local g4=Duel.SelectMatchingCard(tp,s.tffilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local g4=Duel.SelectMatchingCard(tp,s.tffilter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g4:GetFirst()
			if #g4>0 and tc:IsType(TYPE_MONSTER) then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.SSet(tp,tc)>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(3300)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetValue(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				tc:RegisterEffect(e1,true)
			end
		end
	end
end