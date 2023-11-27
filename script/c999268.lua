--Scripted by IanxWaifu
--Daedric Relic, Deprivation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Special Summon Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--inactivatable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end


--Special Summon Material
function s.spfilter(c,e,tp)
	return c:IsControler(tp) and c:IsSetCard(0x718) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup() 
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	return eg:IsExists(s.spfilter,1,nil,e,tp) and e:GetHandler():IsAbleToGrave()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsAbleToGrave() then return end
	local g=eg:Filter(s.spfilter,nil,e,tp)
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tc=g:Select(tp,1,1,nil)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	if c:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end





--[[
local DaemonMonsterCard = {
    [0] = true,   -- Set column 0 as true if it contains a Daemon Monster Card
    [1] = true,   -- Set column 1 as true if it contains a Daemon Monster Card
    [2] = true,   -- Set column 2 as true if it contains a Daemon Monster Card
    [3] = true,   -- Set column 3 as true if it contains a Daemon Monster Card
    [4] = true,   -- Set column 4 as true if it contains a Daemon Monster Card
    [5] = true,   -- Set column 5 as true if it contains a Daemon Monster Card
    [6] = true,   -- Set column 6 as true if it contains a Daemon Monster Card
}

function s.efilter(e, ct)
    local p = e:GetHandlerPlayer()
    local te, loc, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION, CHAININFO_TRIGGERING_PLAYER)
    local tc = te:GetHandler()
	if not ((te:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE) or (te:IsActiveType(TYPE_SPELL) and loc==LOCATION_PZONE)) then return false end
    local c = e:GetHandler()
    local zones = {}  -- Table of zones with matching Daemon Monster Cards

    -- Iterate over all 7 monster zones
    for seq = 0, 6 do
        local zone = Duel.GetFieldCard(p, LOCATION_MZONE, seq)
        if zone and zone:IsControler(p) then  -- Check if there is a monster in the monster zone and if you control it
            local column = zone:GetColumnZone(seq)
            if DaemonMonsterCard[column] then  -- Check if the column matches one of your Daemon Monster Cards
                table.insert(zones, seq)  -- Add the zone to the table of matching zones
            end
        end
    end

    -- Check the Pendulum Zones (if applicable)
    for seq = 0, 1 do
        local zone = Duel.GetFieldCard(p, LOCATION_PZONE, seq)
        if zone and zone:IsControler(p) then  -- Check if there is a card in the Pendulum Zone and if you control it
            local column = zone:GetColumnZone(seq + 16)  -- Adjust the sequence for Pendulum Zones
            if DaemonMonsterCard[column] then  -- Check if the column matches one of your Daemon Monster Cards
                table.insert(zones, seq + 16)  -- Add the Pendulum Zone to the table of matching zones
            end
        end
    end

    -- Check if the triggering effect meets the condition for any of the zones
    for _, seq in ipairs(zones) do
        local zone = c:GetColumnZone(seq)
        if seq == tc:GetSequence() and p == tp and zone == c:GetColumnZone(tc:GetSequence()) then
            return true
        end
    end

    return false
end
--]]

function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,loc,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	local cg=tc:GetColumnGroup(1,1)
	return p==tp and tc:IsSetCard(0x718) and tc:GetControler()==tp and tc:IsFaceup() and cg:IsExists(Card.IsControler,1,nil,1-tp)
	and ((((tc:IsType(TYPE_XYZ) or tc:IsType(TYPE_RITUAL) or tc:IsType(TYPE_FUSION)) and tc:IsMonster()) or (tc:IsLocation(LOCATION_PZONE))) and (te:IsHasCategory(CATEGORY_SPECIAL_SUMMON) or te:IsActiveType(TYPE_MONSTER)))
end