--Scripted by IanxWaifu
--Deathrall Faldreia
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
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Material check on summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck2)
	c:RegisterEffect(e4)
	--Flip opponent's monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.tdtg1)
	e5:SetOperation(s.tdop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e7:SetTarget(s.tdtg2)
	c:RegisterEffect(e7)
	local e8=e5:Clone()
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e8:SetCode(EVENT_CHAINING)
	e8:SetCondition(s.tdcon)
	e8:SetTarget(s.tdtg3)
	c:RegisterEffect(e8)
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
	local ct=g:FilterCount(Card.IsRace,nil,RACE_ZOMBIE)
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
    	e:GetHandler():RegisterFlagEffect(id+3,RESETS_STANDARD-RESET_TOFIELD,0,1)
    end
end




function s.desfilter(c,e)
	return c:IsDestructable(e)
end
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	local g2=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if chk==0 then return #g1>0 and #g2>0 and e:GetHandler():GetFlagEffect(id)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,PLAYER_ALL,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,PLAYER_ALL,LOCATION_GRAVE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e)
	if #g1==0 then return end
	Duel.HintSelection(g1:GetFirst(),true)
	if Duel.Destroy(g1,REASON_EFFECT)>0 then
		local g2=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		if #g2==0 then return end
		Duel.BreakEffect()
		local dg=g2:Select(tp,1,1,nil):GetFirst()
		Duel.HintSelection(dg,true)
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
	end
end



function s.tdfilter(c,tp)
	return c:IsFaceup() and not c:IsSummonPlayer(tp) and c:IsCanTurnSet()
end
function s.tdtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id+3)>0 and eg and eg:IsExists(s.tdfilter,1,nil,tp) end
	local g=eg:Filter(s.tdfilter,nil,tp)
	Duel.SetTargetCard(g)
end
function s.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return e:GetHandler():GetFlagEffect(id+3)>0 and rp==1-tp and tc:IsFaceup() and tc:IsCanTurnSet() end
	Duel.SetTargetCard(tc)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and loc==LOCATION_MZONE
end
function s.tdtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id+3)>0 end
	if re:GetHandler():IsLocation(LOCATION_MZONE) and re:GetHandler():IsCanBeEffectTarget(e) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetTargetCard(eg)
	end
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		local og=Duel.GetOperatedGroup()
		local tc=og:GetFirst()
		for tc in aux.Next(og) do
			--Cannot change its battle position
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetCondition(s.tgcond)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.tgcond(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_LEGION_TOKEN),e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end