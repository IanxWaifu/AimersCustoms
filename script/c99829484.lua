--Scripted by Aimer
--Sylvestrie Gaiaranthis
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(s.ffilter),1,aux.FilterBoolFunctionEx(s.attfilter),2)
	--Special Summon 2 monsters from the GYs
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	--Quick Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_SYLVESTRIE}

function s.ffilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsRitualMonster()
end
function s.attfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WIND)
end



--Special Summon 2 Targets
function s.spfilter(c,e,tp,targetp)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,targetp) and c:IsCanBeEffectTarget(e)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,tp)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,1-tp)
	if chk==0 then return ((#g1>1 and #g2>1) or (#(g1&g2)~=#g1 and #(g1&g2)~=#g2)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	local tg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,function(sg) return #(sg&g1)>0 and #(sg&g2)>0 end,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,0,0)
end
function s.spownfilter(c,e,tp,tg)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (tg-c):GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #tg<2 or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<1
		or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local sc=tg:FilterSelect(tp,s.spownfilter,1,1,nil,e,tp,tg):GetFirst()
	if not sc then return end
	Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep((tg-sc):GetFirst(),0,tp,1-tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
end


--Check Field Spell presence
function s.youfs(tp)
	return Duel.GetFieldCard(tp,LOCATION_FZONE,0)~=nil
end
function s.oppfs(tp)
	return Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)~=nil
end

--Option 1: negate
function s.negfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.negchk(e,tp)
	return s.youfs(tp)
		and Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil)
		and e:GetHandler():GetFlagEffect(id)==0
end

--Option 2: add Ritual
function s.thfilter(c)
	return c:IsRitualMonster() and c:IsAbleToHand()
end
function s.thchk(e,tp)
	return s.oppfs(tp)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():GetFlagEffect(id+1)==0
end

--Condition (add chain lock)
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)>0 then return false end --once per chain lock
	return s.negchk(e,tp) or s.thchk(e,tp)
end

--Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.negchk(e,tp)
	local b2=s.thchk(e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b2 then
		op=1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
	--register once-per-chain flag
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end

--Operation
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	--register once-per-chain flag
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	if op==0 then
		--Negate
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
		c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)

	else
		--Add Ritual
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
		end
		c:RegisterFlagEffect(id+1,RESET_PHASE+PHASE_END,0,1)
	end
end