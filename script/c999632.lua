--Scripted by IanxWaifu
--Deathrall Eishethx
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	Aimer.AddLinkProcedureDeathrall(c,s.sfilter1,2,99,s.lcheck)
	--ED Summon token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Material check on summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck1)
	c:RegisterEffect(e2)
	--Destroy 1 card on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	--Material check on summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck2)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(s.tgcon)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}

function s.lcheck(g,lc)
	return g:IsExists(s.sfilter2,1,nil)
end
function s.sfilter1(c)
	return c:IsSetCard(SET_DEATHRALL) or c:IsSetCard(SET_LEGION_TOKEN)
end
function s.sfilter2(c)
	return c:IsSetCard(SET_DEATHRALL)
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end


function s.fiendfilter(c,tp)
	return c:IsType(TYPE_TOKEN) and c:IsFaceup() and c:IsRace(RACE_FIEND)
end
function s.pyrofilter(c,tp)
	return c:IsType(TYPE_TOKEN) and c:IsFaceup() and c:IsRace(RACE_PYRO)
end
function s.zombiefilter(c,tp)
	return c:IsType(TYPE_TOKEN) and c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- Check for the presence of Fiend monsters
    local hasFiend=Duel.IsExistingMatchingCard(s.fiendfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    -- Check for the presence of Pyro monsters
    local hasPyro=Duel.IsExistingMatchingCard(s.pyrofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    -- Check for the presence of Zombie monsters
    local hasZombie=Duel.IsExistingMatchingCard(s.zombiefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    -- Return false if all three races are present
    if hasFiend and hasPyro and hasZombie then
        return false
    end
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    -- Determine the owner of the group of cards in eg
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,0,0) then return end
    local raceCount = 0
	local excludedRace = 0
	local mg = Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	for mrc in aux.Next(mg) do
	    local race = mrc:GetRace()
	    excludedRace = excludedRace | race
	end
	excludedRace = excludedRace & (RACE_FIEND+RACE_PYRO+RACE_ZOMBIE)

	local race = 0
	if raceCount == 1 then
	    race = Duel.AnnounceRace(tp,1,excludedRace)
	    e:SetLabel(race)
	else
	    race = Duel.AnnounceRace(tp,1,RACE_FIEND+RACE_PYRO+RACE_ZOMBIE-excludedRace)
	    e:SetLabel(race)
	end
    
    local token
    if race == RACE_FIEND then
        token = Duel.CreateToken(tp,TOKEN_LEGION_F)
    elseif race == RACE_PYRO then
        token = Duel.CreateToken(tp,TOKEN_LEGION_P)
    elseif race == RACE_ZOMBIE then
        token = Duel.CreateToken(tp,TOKEN_LEGION_Z)
    else
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

--Check Materials 1
function s.valcheck1(e,c)
	local g=c:GetMaterial()
	if not g then return end
	local ct=g:FilterCount(Card.IsRace,nil,RACE_FIEND)
	if ct==#g then e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD-RESET_TOFIELD,0,1) end
end

-- Check Materials
function s.valcheck2(e, c)
    local g=c:GetMaterial()
    local races={} 
    local uniqueRaceCount=0 
    for tc in aux.Next(g) do
        local race=tc:GetRace()
        if not races[race] then
            races[race]=true
            uniqueRaceCount=uniqueRaceCount+1
        end
    end
    if uniqueRaceCount>=3 then
    	e:GetHandler():RegisterFlagEffect(id+1,RESETS_STANDARD-RESET_TOFIELD,0,1)
    end
end


function s.negfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DEATHRALL) and c:IsType(TYPE_LINK)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)>0 and Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=Duel.GetMatchingGroupCount(s.negfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		for tc in aux.Next(g) do
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if not tc:IsFaceup() then return end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end



function s.rmfilter(c,tp)
	return not c:IsLocation(LOCATION_REMOVED) and c:GetPreviousControler()==1-tp and c:IsAbleToRemove() and not c:IsType(TYPE_TOKEN)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rmfilter,1,nil,tp)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id+1)>0 and eg end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end