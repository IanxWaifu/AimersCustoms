--Scripted by IanxWaifu
--Deathrall Sins of Sibyl
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return c:IsSetCard(SET_LEGION_TOKEN) end)
	e2:SetValue(s.sumlimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e5)
	--ED Summon token
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id)
	e6:SetCost(s.dcost)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	--Shuffle Links+SP
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCountLimit(1,{id,1})
	e7:SetCondition(s.spcon)
	e7:SetTarget(s.tdtg)
	e7:SetOperation(s.tdop)
	c:RegisterEffect(e7)
end

function s.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end

function s.dfilter(c)
	return (c:IsSetCard(SET_DEATHRALL) or c:ListsArchetype(SET_LEGION_TOKEN)) and c:IsDiscardable()
end
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.dfilter,1,1,REASON_DISCARD+REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDraw(tp,1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
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
    return true
end



function s.tdfilter(c)
	return c:IsSetCard(SET_DEATHRALL) and c:IsAbleToExtra() and c:IsType(TYPE_LINK) and c:IsMonster()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,0,1,nil) 
		and (Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0)
		or Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_P,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_PYRO,0)
		or Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_Z,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_ZOMBIE,0)) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local cg = Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,99,nil)
    if Duel.SendtoDeck(cg,nil,2,REASON_EFFECT)~=0 then
        local ct = Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
        if ct<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			for i = 1, ct do
			-- Check if there are no more monster zones left
		    if Duel.GetLocationCount(tp, LOCATION_MZONE) <=0 or not (Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0)
				or Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_P,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_PYRO,0)
				or Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_Z,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_ZOMBIE,0)) or not Duel.SelectYesNo(tp, aux.Stringid(id,2)) then break end
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
    end
end