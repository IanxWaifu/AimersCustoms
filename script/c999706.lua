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
	e1:SetRange(LOCATION_HAND)
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
	e3:SetCountLimit(1,{id,1})
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
	if Duel.RemoveCounter(tp,1,1,COUNTER_ICE,4,REASON_RULE) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local dg=g:Select(tp,1,1,nil)
		if Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			dg:GetFirst():AddCounter(COUNTER_ICE,1)
		end
	end
end

--tribute to summon a synchro
function s.tspfilter(c,e,tp)
	local counter=Duel.GetCounter(tp,LOCATION_MZONE,0,COUNTER_ICE)
	return c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLevel()<=counter
		and c:IsLocation(LOCATION_EXTRA)
		and Duel.IsExistingMatchingCard(s.countfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.countfilter(c)
	return c:IsReleasable() and c:GetCounter(COUNTER_ICE)>0
end

function s.tsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tspfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if chk==0 then
		return #g>0 and Duel.GetCounter(tp,LOCATION_MZONE,0,COUNTER_ICE)>0
			and Duel.IsExistingMatchingCard(s.countfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local tc=g:Select(tp,1,1,nil):GetFirst()
	e:SetLabelObject(tc)
	local lv=tc:GetLevel()
	local iceCounter=Duel.GetCounter(tp,LOCATION_MZONE,0,COUNTER_ICE)
	if iceCounter<lv then return false end
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
	e:SetLabel(lv)
	Duel.Release(sg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_EXTRA)
end



function s.tfilter(c,lv,e,tp)
	return c:IsSetCard(SET_DRAGOCYENE) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(lv) and c:IsLocation(LOCATION_EXTRA)
end
function s.tspop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Place Counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,1,1,nil)
	sg:GetFirst():AddCounter(COUNTER_ICE,1)
end
