--Icyene Contractress
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Tribute and Special Summon Dragocyene
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tsptg)
	e2:SetOperation(s.tspop)
	c:RegisterEffect(e2)
	--Place Counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_ICYENE,SET_DRAGOCYENE}
s.counter_list={COUNTER_ICE}

--Special Summon Condition

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CYENE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsCanRemoveCounter(c:GetControler(),1,1,COUNTER_ICE,4,REASON_RULE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if Duel.RemoveCounter(tp,1,1,COUNTER_ICE,4,REASON_RULE) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local dg=g:Select(tp,1,1,nil)
			if Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP)~=0 then
				dg:GetFirst():AddCounter(COUNTER_ICE,1)
			end
		end
	end
end
--tribute to summon a synchro
function s.tspfilter(c,e,tp,icecounter)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetLevel()<=icecounter and c:IsLocation(LOCATION_EXTRA)
		and c:IsSetCard(SET_DRAGOCYENE) and Duel.IsExistingMatchingCard(s.countfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.countfilter(c)
	return c:IsReleasable() and c:GetCounter(COUNTER_ICE)>0
end

function s.tsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Calculate the total ICE counters only from monsters
	local mcounter=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_MONSTER) end,tp,LOCATION_MZONE,0,nil)
	local icecounter=0
	local tc=mcounter:GetFirst()
	while tc do
		icecounter=icecounter+tc:GetCounter(COUNTER_ICE)
		tc=mcounter:GetNext()
	end
	local g=Duel.GetMatchingGroup(s.tspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,icecounter)
	if chk==0 then return #g>0 and icecounter>0 and Duel.IsExistingMatchingCard(s.countfilter,tp,LOCATION_MZONE,0,1,nil) end
	local tc=g:Select(tp,1,1,nil):GetFirst()
	local lv=tc:GetLevel()
	if icecounter<lv then return end
	e:SetLabelObject(tc)
	local sg=Group.CreateGroup()
	local counter=0
	while counter<lv do
		local tg=Duel.GetMatchingGroup(function(c) return c:GetCounter(COUNTER_ICE)>=1 end,tp,LOCATION_MZONE,0,nil)
		tg:Sub(sg)
		if tg:GetCount()==0 then
			return false
		end
		local card=tg:Select(tp,1,1,nil):GetFirst()
		if not card then
			return false
		end
		sg:AddCard(card)
		counter=counter+card:GetCounter(COUNTER_ICE)
	end
	Duel.Release(sg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_EXTRA)
end


function s.tspop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end



--Place Counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,1,1,nil)
	sg:GetFirst():AddCounter(COUNTER_ICE,1)
end
