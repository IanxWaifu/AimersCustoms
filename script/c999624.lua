--Scripted by IanxWaifu
--Deathrall Surgeiroth
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
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCountLimit(1,{id,1})
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--Material check on summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck2)
	c:RegisterEffect(e4)
	--Shuffle opponent's activated effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(s.tdcon)
	e5:SetTarget(s.tdtg)
	e5:SetOperation(s.tdop)
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
	local ct=g:FilterCount(Card.IsRace,nil,RACE_PYRO)
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






function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove() and c:IsSetCard(SET_DEATHRALL)
	and Duel.IsExistingMatchingCard(s.ttfilter,tp,LOCATION_DECK,0,1,nil,tp)
end
function s.ttfilter(c,tp)
	return c:IsSpellTrap() and (c:IsType(TYPE_CONTINUOUS) or c:IsType(TYPE_FIELD)) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:ListsArchetype(SET_LEGION_TOKEN)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)>0 and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.ttfilter,tp,LOCATION_DECK,0,nil,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and #g>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local dg=g:Select(tp,1,1,nil):GetFirst()
		if dg:IsType(TYPE_FIELD) then
			Duel.MoveToField(dg,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		else
			Duel.MoveToField(dg,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end


--Shuffle into deck
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsAbleToDeck())
end
function s.tgfilter(c,rc)
	local rrc=rc:GetType()
	return c:IsAbleToGrave() and c:GetType()~=rrc and (c:IsSetCard(SET_DEATHRALL) or c:ListsArchetype(SET_LEGION_TOKEN))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return e:GetHandler():GetFlagEffect(id+3)>0 and not rc:IsLocation(LOCATION_DECK) 
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,rc) end
	Duel.SetTargetCard(rc)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,rc,1,rc:GetControler(),rc:GetLocation())
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	rc:CancelToGrave()
	if Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if og:GetFirst():IsLocation(LOCATION_DECK) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
			if #g2>0 then
				Duel.BreakEffect()
				Duel.SendtoGrave(g2,REASON_EFFECT)
			end
		end
	end
end
