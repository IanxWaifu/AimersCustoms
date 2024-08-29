--Icyene Angel
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ICYENE,SET_DRAGOCYENE}
s.counter_list={COUNTER_ICE}
s.astral_shift={id}


--Special from hand
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsCanRemoveCounter(tp,1,1,COUNTER_ICE,1,REASON_EFFECT) or Aimer.FrostrineCheckEnvironment(tp)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local check=0
    if Duel.GetCounter(tp,1,1,COUNTER_ICE)>=1 and Aimer.FrostrineCheckEnvironment(tp) then
        if Duel.SelectYesNo(tp,aux.Stringid(999721,1)) then
            Duel.RegisterFlagEffect(tp,999721,RESET_PHASE+PHASE_END,0,1)
            Duel.Hint(HINT_CARD,0,999721)
            check=check+1
        end
    elseif Duel.GetCounter(tp,1,1,COUNTER_ICE)<1 and Aimer.FrostrineCheckEnvironment(tp) then
        Duel.RegisterFlagEffect(tp,999721,RESET_PHASE+PHASE_END,0,1)
        Duel.Hint(HINT_CARD,0,999721)
        check=check+1
    end
    if check==0 then
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.RemoveCounter(tp,1,1,COUNTER_ICE,1,REASON_EFFECT)
	end
end

function s.spfilter(c,e,tp,mat,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	if not c:IsSetCard(SET_DRAGOCYENE) then
		return c:IsSynchroSummonable(mat) and c:IsAttribute(ATTRIBUTE_WATER) and Duel.GetLocationCountFromEx(tp,tp,mg,c)
	else
		return c:IsSynchroSummonable(mat,mg) and c:IsSetCard(SET_DRAGOCYENE) and Duel.GetLocationCountFromEx(tp,tp,mg,c)
	end
end

function s.matfilter(c,tp)
	return c:IsCanBeSynchroMaterial() and ((c:GetCounter(COUNTER_ICE)>0 and c:IsControler(1-tp) and c:IsFaceup()) or (c:IsControler(tp)))
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
		local reset={}
		for tc in aux.Next(mg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
			e1:SetReset(RESET_CHAIN)
			e1:SetOperation(s.synop)
			tc:RegisterEffect(e1,true)
			table.insert(reset,e1)
			if tc:IsControler(1-tp) then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SYNCHRO_MATERIAL)
				e2:SetReset(RESET_CHAIN)
				tc:RegisterEffect(e2)
				table.insert(reset,e2)
			end
		end
		local res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,mg)
		for _,eff in ipairs(reset) do
			eff:Reset()
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	local reset={}
	for tc in aux.Next(mg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		e1:SetOperation(s.synop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		table.insert(reset,e1)
		if tc:IsControler(1-tp) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SYNCHRO_MATERIAL)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			table.insert(reset,e2)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sync=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,mg):GetFirst()
	if sync then
		if not sync:IsSetCard(SET_DRAGOCYENE) then
		local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,tp)
		Duel.SynchroSummon(tp,sync,c,mg2)
	
	else
		if not sync:IsSetCard(SET_DRAGOCYENE) then
		Duel.SynchroSummon(tp,sync,c,mg)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetOperation(function()
			for _,eff in ipairs(reset) do
				eff:Reset()
			end
		end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sync:RegisterEffect(e1,true)
	else
		for _,eff in ipairs(reset) do
			eff:Reset()
		end
	end
end end end

function s.synop(e,tg,ntg,sg,lv,sc,tp)
	return sg:GetSum(Card.GetLevel)==lv,true
end


