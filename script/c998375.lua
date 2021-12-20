--激流蘇生
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsSetCard(0x12E5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x12E5)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if chk==0 then
		local ct=eg:FilterCount(s.spfilter,nil,e,tp)
		return #tg>0 and ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
	end
	Duel.SetTargetCard(eg)
	local g=eg:Filter(s.spfilter,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spfilter2(c,e,tp)
	return c:IsControler(tp) and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x12E5)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if ft<=0 or #tg<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=eg:Filter(s.spfilter2,nil,e,tp)
	if ft<#sg then return end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.ConfirmDecktop(tp,1)
		Duel.DisableShuffleCheck()
		local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
		if tc:IsSetCard(0x12E5) then
			Duel.DisableShuffleCheck()
			Duel.MoveSequence(tc,0)
			tc:ReverseInDeck()
		elseif not tc:IsSetCard(0x12E5) then 
			Duel.DisableShuffleCheck()
			Duel.MoveSequence(tc,1)
		end
	end
end
function s.handcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
