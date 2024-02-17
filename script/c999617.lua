--Scripted by IanxWaifu
--Embodiment of Perdition
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetLabelObject(e3)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
	--register when a card leaves the field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(function(c)
        return c:IsSetCard(SET_LEGION_TOKEN) or c:IsSetCard(SET_DEATHRALL)
    end),tp,LOCATION_MZONE,0,1,nil)
end


function s.fiendfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
function s.pyrofilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
function s.zombiefilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,c,tp)
	 -- Check for the presence of Fiend monsters
    local hasFiend=Duel.IsExistingMatchingCard(s.fiendfilter,tp,LOCATION_MZONE,0,1,nil)
    -- Check for the presence of Pyro monsters
    local hasPyro=Duel.IsExistingMatchingCard(s.pyrofilter,tp,LOCATION_MZONE,0,1,nil)
    -- Check for the presence of Zombie monsters
    local hasZombie=Duel.IsExistingMatchingCard(s.zombiefilter,tp,LOCATION_MZONE,0,1,nil)
    -- Return false if all three races are present
    if hasFiend and hasPyro and hasZombie then
        return false
    end
	return #g>0
end
function s.filter(c,tp)
	local emzone=c:GetColumnGroup():IsExists(s.zonefilter,1,nil,tp)
    if c:IsLocation(LOCATION_MMZONE) then return true end
	if (c:IsLocation(LOCATION_STZONE) or c:IsLocation(LOCATION_EMZONE)) and not emzone then return true end
	return false
end

function s.zonefilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MMZONE)
end


function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,c,tp)
     -- Check for the presence of Fiend monsters
    local hasFiend=Duel.IsExistingMatchingCard(s.fiendfilter,tp,LOCATION_MZONE,0,1,nil)
    -- Check for the presence of Pyro monsters
    local hasPyro=Duel.IsExistingMatchingCard(s.pyrofilter,tp,LOCATION_MZONE,0,1,nil)
    -- Check for the presence of Zombie monsters
    local hasZombie=Duel.IsExistingMatchingCard(s.zombiefilter,tp,LOCATION_MZONE,0,1,nil)
    -- Return false if all three races are present
    if hasFiend and hasPyro and hasZombie then return end
    if #g>0 then
    	local dg=g:Select(tp,1,1,nil)
    	local dgt=dg:GetFirst()
		Duel.HintSelection(dg)
        local seq = dgt:GetSequence()
        local pos = 0 
        if dgt:IsSpellTrap() then pos=POS_FACEUP_DEFENSE else pos=dgt:GetPosition() end
		local seq_bit = 0
		if dgt:IsLocation(LOCATION_MMZONE) then seq_bit = 2 ^ seq end
		if dgt:IsLocation(LOCATION_STZONE) then seq_bit = 1<<seq end
		if dgt:IsLocation(LOCATION_EMZONE) then
		    if seq == 5 then seq_bit=2 end
		    if seq == 6 then seq_bit=8 end 
		end
	    local p=dgt:GetControler()
	    if Duel.SendtoGrave(dgt, REASON_RULE)~=0 then
		local raceCount = 0
		local excludedRace = 0
		local mg = Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_MONSTER)
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
	        if race==RACE_FIEND then
		    local token=Duel.CreateToken(tp,TOKEN_LEGION_F)
			Duel.SpecialSummon(token,0,tp,p,false,false,pos,seq_bit)
	    elseif race==RACE_PYRO then
	    	local token=Duel.CreateToken(tp,TOKEN_LEGION_P)
			Duel.SpecialSummon(token,0,tp,p,false,false,pos,seq_bit)
	    elseif race==RACE_ZOMBIE then
	    	local token=Duel.CreateToken(tp,TOKEN_LEGION_Z)
			Duel.SpecialSummon(token,0,tp,p,false,false,pos,seq_bit)
		else return end
        end
    end
end



function s.lvfdfilter(c)
	return c:IsLocation(LOCATION_MZONE) --[[and c:IsSetCard(SET_DEATHRALL)--]]
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.lvfdfilter,1,nil) then
		local tc=eg:GetFirst()
		for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end



-- Condition Filter and Groups
function s.sefilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetFlagEffect(id)>0 and 
    (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())
    )
end

function s.sefilter2(c,e,tp)
    return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetFlagEffect(id)>0 and 
    (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())
    )
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local mzcount = eg:GetCount()
	local spz = Duel.GetLocationCount(tp, LOCATION_MZONE)
	return spz >= mzcount and eg:IsExists(s.sefilter,mzcount,nil,e,tp) 
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.sefilter,nil,e,tp)
	if chk==0 then return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and
	Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,SET_LEGION_TOKEN) end
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_LEGION_TOKEN)
	Duel.SetTargetCard(eg)
	local dg=eg:Filter(s.sefilter,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dg,#dg,0,0)
end


-- Special Summon
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_LEGION_TOKEN)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft+#dg<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=eg:Filter(s.sefilter2,nil,e,tp)
	if ft+#dg<#sg then return end
    if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)~=0 then
        Duel.SpecialSummon(eg,0,tp,tp,false,false,POS_FACEUP)
    end
end
