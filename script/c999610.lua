--Scripted by IanxWaifu
--Deathrall Esoterica
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Special summon 3 tokens
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Change effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.chcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_P,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_PYRO,0)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_Z,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_ZOMBIE,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<3
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0)
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_P,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_PYRO,0)
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_Z,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_ZOMBIE,0) then return end
	local c=e:GetHandler()
	for i=1,3 do
		local token=Duel.CreateToken(tp,id+i)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
	--Cannot activate the effects of monsters with the same name
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.aclimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

function s.aclimit(e, re, tp)
    local c=re:GetHandler()
    local rc=c:GetRace()
    local g=Duel.GetMatchingGroup(s.atfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,rc)
    return (c:IsType(TYPE_MONSTER) and not g:IsExists(Card.IsRace,1,nil,rc)) and not c:IsCode(999634)
end


function s.atfilter(c, rc)
    return c:IsFaceup() and c:IsType(TYPE_TOKEN) and c:IsMonster() and c:IsRace(rc)
end

function s.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
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
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(1-tp,LOCATION_MZONE) <= 0 then
        return false
    end

    if not Duel.IsPlayerCanSpecialSummonMonster(1-tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0) then
        return false
    end

    if not (rp == 1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then
        return false
    end
    local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
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

    return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_LEGION_TOKEN),tp,LOCATION_MZONE,0,1,nil)
end


function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(1-tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,0)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end




function s.repop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE) <=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,0,0) then return end
	local raceCount = 0
	local excludedRace = 0
	local mg = Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_TOKEN)
	for mrc in aux.Next(mg) do
	    local race = mrc:GetRace()
	    excludedRace = excludedRace | race
	end
	excludedRace = excludedRace & (RACE_FIEND+RACE_PYRO+RACE_ZOMBIE)

	local race = 0
	if raceCount == 1 then
	    race = Duel.AnnounceRace(1-tp,1,excludedRace)
	    e:SetLabel(race)
	else
	    race = Duel.AnnounceRace(1-tp,1,RACE_FIEND+RACE_PYRO+RACE_ZOMBIE-excludedRace)
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
    Duel.SpecialSummon(token,0,tp,p,false,false,POS_FACEUP)
end
