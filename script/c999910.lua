--Scripted by Aimer
--Shuken ni Taisuru Höfuku
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Helper: Check if card is Kegai or Kijin
function s.IsKegaiKijin(c)
	return c:IsSetCard(SET_KEGAI) or c:IsSetCard(SET_KIJIN)
end

-- Cost filter
function s.costfilter(c)
	return ((c:IsLocation(LOCATION_MZONE)) or (c:IsLocation(LOCATION_GRAVE) and c:IsSetCard({SET_KEGAI,SET_KIJIN})))
		and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
end


function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end

-- Cost: banish exactly 2 Rituals (diff names)
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=2 and g:GetClassCount(Card.GetCode)>=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end


--Target: Choose effect
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
end

--Synchro Summon
function s.synfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard({SET_KEGAI,SET_KIJIN})
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

--Activate
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local spelltrap_g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_SZONE,nil,TYPE_SPELL+TYPE_TRAP)
	local monster_g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_MONSTER)
	local opt=nil
	if #spelltrap_g>0 and #monster_g>0 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif #spelltrap_g>0 then
		opt=0
	elseif #monster_g>0 then
		opt=1
	else
		return
	end
	if opt==0 then
		Duel.Remove(spelltrap_g,POS_FACEDOWN,REASON_EFFECT)
	else
		Duel.Remove(monster_g,POS_FACEDOWN,REASON_EFFECT)
	end
	--Check for valid Synchro and ask
	if Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end

