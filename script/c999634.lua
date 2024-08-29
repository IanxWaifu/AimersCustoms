--Scripted by IanxWaifu
--Deathrall Deathrall Sibylonetter
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	Aimer.AddLinkProcedureDeathrall(c,s.sfilter1,2,99,s.lcheck)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--SetLabels
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.flagop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetCondition(s.tgcon)
	e4:SetOperation(s.flagop)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetOperation(s.flagop)
	c:RegisterEffect(e5)
	--EP effect displace
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,1})
	e6:SetTarget(s.cttg)
	e6:SetOperation(s.ctop)
	c:RegisterEffect(e6)
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
	return c:IsSetCard(SET_DEATHRALL) and c:IsType(TYPE_LINK)
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end

function s.lvfdfilter(c,e)
	return c==e:GetHandler()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.lvfdfilter,1,nil,e) then
		local tc=eg:GetFirst()
		for tc in aux.Next(eg) do
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,REASON_EFFECT+REASON_TEMPORARY,tp,tp,0)
			Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,REASON_EFFECT+REASON_TEMPORARY,tp,tp,0)
		end
	end
end

function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,REASON_EFFECT+REASON_TEMPORARY,tp,tp,0)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,REASON_EFFECT+REASON_TEMPORARY,tp,tp,0)
end

function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and c:IsSetCard(SET_DEATHRALL)
end


function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end

-- Your function to remove monsters and set up the return effect
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g==0 then return end
    Duel.HintSelection(g,true)
    g:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD,0,0)
    if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
    	g:KeepAlive()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_CUSTOM+id)
        e1:SetCondition(s.retcon)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0 
end

function s.cfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)>0
end

-- Function to handle returning monsters to the field
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_REMOVED,0,nil)
    if ft<=0 or #g<=0 then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	    -- Prompt the player to select monsters to return to the field
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	    local return_group = g:FilterSelect(tp,Card.GetFlagEffect,1,ft,nil,id)
	    -- Return the selected monsters to the field
	    if #return_group >0 then
	    	for tc in aux.Next(return_group) do
	        	Duel.ReturnToField(tc)
	        end
	    end
	end
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

function s.cttg(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local loc=LOCATION_ONFIELD
	if ft<=0 then loc=LOCATION_MZONE end
	local g=Duel.GetMatchingGroup(s.chfilter,tp,0,loc,c,tp,c)
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
	return #g>0 and ft>-1
end

function s.chfilter(c,tp,hc)
	local emzone=c:GetColumnGroup():IsExists(s.zonefilter,1,nil,tp)
	if not c:GetColumnGroup():IsContains(hc) then return end
    if c:IsLocation(LOCATION_MMZONE) then return true end
	if (c:IsLocation(LOCATION_STZONE) or c:IsLocation(LOCATION_EMZONE)) and not emzone then return true end
	return false
end

function s.zonefilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MMZONE)
end


function s.ctop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local loc=LOCATION_ONFIELD
	if ft<=0 then loc=LOCATION_MZONE end
    local g=Duel.GetMatchingGroup(s.chfilter,tp,0,loc,c,tp,c)
     -- Check for the presence of Fiend monsters
    local hasFiend=Duel.IsExistingMatchingCard(s.fiendfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    -- Check for the presence of Pyro monsters
    local hasPyro=Duel.IsExistingMatchingCard(s.pyrofilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    -- Check for the presence of Zombie monsters
    local hasZombie=Duel.IsExistingMatchingCard(s.zombiefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
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