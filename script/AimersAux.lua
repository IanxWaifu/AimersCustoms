--Aimers Auxillary Functions

if not aux.AimersAux then
    aux.AimersAux = {}
    Aimer = aux.AimersAux
end

if not Aimer then
    Aimer = aux.AimersAux
end

--Common use Events
EVENT_PENDULUM_ZONE_CHANGE = EVENT_CUSTOM + 3200

--Common used cards
CARD_ZORGA = 999415

--Common Setcards
SET_VOLTAIC = 0x2A1
SET_VOLDRAGO = 0x2A2



-- Gets cards Attribute countFunction to get the count of set bits (1s) in a card's attribute
function Aimer.GetAttributeCount(card)
    local att = card:GetAttribute()
    local count = 0
    while att > 0 do
        if att & 0x1 ~= 0 then
            count = count + 1
        end
        att = att >> 1
    end
    return count
end

--Voltaic Same Columns
function Aimer.VoltaicSameColumns(e,cc)
    local function facedownfilter(c,tp)
        return c:IsControler(tp) and c:IsFacedown()
    end
    return cc:GetColumnGroup():IsExists(facedownfilter,1,cc,e:GetHandlerPlayer())
end

-- Utility filter and function to check if a card can be placed in the appropriate zone
function Aimer.CanMoveCardToAppropriateZone(c,p,checkOpponent)
    if checkOpponent == true then
        p=1-p -- If checking opponent, change the player ID
    end
    if c:IsMonster() then
        return Duel.GetLocationCount(p,LOCATION_MZONE)>0
    elseif c:IsSpellTrap() and not c:IsType(TYPE_FIELD) then
        if c:IsLocation(LOCATION_PZONE) then
            return Duel.CheckPendulumZones(p)
        else
            return Duel.GetLocationCount(p,LOCATION_SZONE)>0
        end
    end
    return false
end

function Aimer.MoveCardToAppropriateZone(tc,p,zoneType)
    local seq=-1
    if tc:IsLocation(LOCATION_MZONE) then
        seq=math.log(Duel.SelectDisableField(p,1,LOCATION_MZONE,0,0),2)
    elseif tc:IsLocation(LOCATION_STZONE) and not tc:IsLocation(LOCATION_PZONE) then
        local zone=Duel.SelectDisableField(p,1,LOCATION_SZONE,0,0)
        seq=math.log(zone,2)-8
        if not Duel.CheckLocation(p,LOCATION_SZONE,seq) then return end
    elseif tc:IsLocation(LOCATION_PZONE) then
        seq=tc:IsSequence(0) and 1 or 0
        zoneType=zoneType or LOCATION_PZONE
    end
    if seq>=0 then
        Duel.MoveSequence(tc,seq,zoneType)
    end
end


--Voltaic face-down Pendulum Summon
function Aimer.AddVoltaicPendProcedure(c,reg,desc)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    if desc then
        e1:SetDescription(desc)
    else
        e1:SetDescription(1074)
    end
    e1:SetCode(EFFECT_SPSUMMON_PROC_G)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCondition(Aimer.VoltaicPendCondition())
    e1:SetOperation(Aimer.VoltaicPendOperation())
    e1:SetValue(SUMMON_TYPE_PENDULUM)
    c:RegisterEffect(e1)
    --register by default
    if reg==nil or reg then
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(1160)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    c:RegisterEffect(e2)
    end
end
function Aimer.VoltaicPendFilter(c,e,tp,lscale,rscale,lvchk)
    if lscale>rscale then lscale,rscale=rscale,lscale end
    local lv=0
    if c.pendulum_level then
        lv=c.pendulum_level
    else
        lv=c:GetLevel()
    end
    return c:IsSetCard(0x2A1) 
        and (lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) 
            and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false,POS_FACEDOWN_DEFENSE) and not c:IsForbidden()
end
function Aimer.VoltaicPendCondition()
    return function(e,c,og)
        if c==nil then return true end
        local tp=c:GetControler()
        local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
        if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,10000000)>0 then return false end
        local lscale=c:GetLeftScale()
        local rscale=rpz:GetRightScale()
        if lscale>rscale then lscale,rscale=rscale,lscale end
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<=0 then return false end
        if og then
            return og:Filter(Card.IsLocation,nil,LOCATION_HAND):IsExists(Aimer.VoltaicPendFilter,1,nil,e,tp,lscale,rscale)
        else
            return Duel.IsExistingMatchingCard(Aimer.VoltaicPendFilter,tp,LOCATION_HAND,0,1,nil,e,tp,lscale,rscale)
        end
    end
end
function Aimer.VoltaicPendOperation()
    return function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
        local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
        local lscale=c:GetLeftScale()
        local rscale=rpz:GetRightScale()
        if lscale>rscale then lscale,rscale=rscale,lscale end
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
        ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
        if og then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=og:Filter(Card.IsLocation,nil,LOCATION_HAND):FilterSelect(tp,Aimer.VoltaicPendFilter,0,ft,nil,e,tp,lscale,rscale)
            if g then
                sg:Merge(g)
            end
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,Aimer.VoltaicPendFilter,tp,LOCATION_HAND,0,0,ft,nil,e,tp,lscale,rscale)
            if g then
                sg:Merge(g)
            end
        end
        if #sg<=0 then return end
        local id=c:GetCode()
        Duel.Hint(HINT_CARD,0,id)
        Duel.RegisterFlagEffect(tp,10000000,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
        Duel.HintSelection(c,true)
        Duel.HintSelection(rpz,true)
        for tc in sg:Iter() do
            if tc:IsSetCard(0x2A1) then
                Duel.SpecialSummonStep(tc,SUMMON_TYPE_PENDULUM,tp,tp,true,false,POS_FACEDOWN_DEFENSE)
            end
        end
        Duel.SpecialSummonComplete()
    end
end


--Synchro monster, m-n tuners + m-n monsters
function Aimer.VoltaicSynchroAddProcedure(c,...)
    --parameters (f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
    if c.synchro_type==nil then
        local code=c:GetOriginalCode()
        local mt=c:GetMetatable()
        mt.synchro_type=1
        mt.synchro_parameters={...}
        if type(mt.synchro_parameters[2])=='function' then
            Debug.Message("Old Synchro Procedure detected in c"..code..".lua")
            return
        end
    end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(1172)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SPSUM_PARAM)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetTargetRange(POS_FACEDOWN_DEFENSE+POS_FACEUP,0)
    e1:SetCondition(Synchro.Condition(...))
    e1:SetTarget(Synchro.Target(...))
    e1:SetOperation(Aimer.VoltaicSynchroOperation())
    e1:SetValue(SUMMON_TYPE_SYNCHRO)
    c:RegisterEffect(e1)
end
function Aimer.VoltaicSynchroOperation()
    return function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
        local g=e:GetLabelObject()
        c:SetMaterial(g)
        local tg=g:Filter(Auxiliary.TatsunecroFilter,nil)
        if #tg>0 then
            Synchro.Send=2
            for tc in aux.Next(tg) do tc:ResetFlagEffect(3096468) end
        end
        if Synchro.Send==1 then
            Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO+REASON_RETURN)
        elseif Synchro.Send==2 then
            Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==3 then
            Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==4 then
            Duel.SendtoHand(g,nil,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==5 then
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==6 then
            Duel.Destroy(g,REASON_MATERIAL+REASON_SYNCHRO)
        else
            Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
        end
        
        Synchro.Send=0
        Synchro.CheckAdditional=nil
        g:DeleteGroup()
    end
end





































--(checkOpponentMonsterZone, checkOpponentGraveyard) Setting to "true" sets the Locations to check against your own Locations. Use if You must have different Attributes.
--(checkPlayerMonsterZone, checkPlayerGraveyard) Setting to "true" sets the Locations to check against your opponents Locations. Use if Opponent must have different Attributes.
--atleast 1 of each player must be used.
--ie; (tp,true,false,true,false) would compare opponent' Mzone to your Mzone. and finds the single Attribute bits which are Unique Between both Players
function Aimer.GetUniqueAttributesByLocation(handler, oppLocations, playerLocations, oppFilter, playerFilter)
    oppLocations = oppLocations or 0
    playerLocations = playerLocations or 0
    oppFilter = oppFilter or function(c) return true end
    playerFilter = playerFilter or function(c) return true end

    local player = handler
    local attributes = {}

    -- Define a set of locations to iterate through
    local locations = {
        [LOCATION_MZONE] = { opp = true, player = true },
        [LOCATION_GRAVE] = { opp = true, player = true },
        [LOCATION_HAND] = { opp = true, player = true },
        [LOCATION_DECK] = { opp = true, player = true },
        [LOCATION_EXTRA] = { opp = true, player = true },
        [LOCATION_REMOVED] = { opp = true, player = true }
    }

    -- Helper function to iterate through a location
    local function IterateLocation(location, control, filter)
        local group = Duel.GetFieldGroup(control, location, 0)
        for _, card in ipairs(group) do
            if filter(card) then
                local att = card:GetAttribute()
                while att > 0 do
                    local bitPos = att & -att
                    attributes[bitPos] = true
                    att = att - bitPos
                end
            end
        end
    end

    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
                if (location == LOCATION_MZONE) then
                    for i = 0, 6 do
                        local zone = Duel.GetFieldCard(p, location, i)
                        if zone and oppFilter(zone) then
                            local att = zone:GetAttribute()
                            while att > 0 do
                                local bitPos = att & -att
                                attributes[bitPos] = true
                                att = att - bitPos
                            end
                        end
                    end
                end
            end
        end

        if (playerLocations & location) == location and flags.player then
            if (location == LOCATION_MZONE) then
                for i = 0, 6 do
                    local zone = Duel.GetFieldCard(player, location, i)
                    if zone and playerFilter(zone) then
                        local att = zone:GetAttribute()
                        while att > 0 do
                            local bitPos = att & -att
                            attributes[bitPos] = nil
                            att = att - bitPos
                        end
                    end
                end
            end
        end
    end
    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
                if (location == LOCATION_GRAVE) then
                    local ct=Duel.GetFieldGroupCount(player,0,LOCATION_GRAVE)
                    for i = 0, ct do
                        local zone = Duel.GetFieldCard(player, 0, LOCATION_GRAVE)
                        if zone and oppFilter(zone) then
                            local att = zone:GetAttribute()
                            while att > 0 do
                                local bitPos = att & -att
                                attributes[bitPos] = true
                                att = att - bitPos
                            end
                        end
                    end
                end
            end
        end

        if (playerLocations & location) == location and flags.player then
            if (location == LOCATION_GRAVE) then
                local ct=Duel.GetFieldGroupCount(player,LOCATION_GRAVE,0)
                for i = 0, ct do
                    local zone = Duel.GetFieldCard(player, LOCATION_GRAVE, 0)
                    if zone and playerFilter(zone) then
                        local att = zone:GetAttribute()
                        while att > 0 do
                            local bitPos = att & -att
                            attributes[bitPos] = nil
                            att = att - bitPos
                        end
                    end
                end
            end
        end
    end
    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
                if (location == LOCATION_EXTRA) then
                    local ct=Duel.GetFieldGroupCount(player,0,LOCATION_EXTRA)
                    for i = 0, ct do
                        local zone = Duel.GetFieldCard(player, 0, LOCATION_EXTRA)
                        if zone and oppFilter(zone) then
                            local att = zone:GetAttribute()
                            while att > 0 do
                                local bitPos = att & -att
                                attributes[bitPos] = true
                                att = att - bitPos
                            end
                        end
                    end
                end
            end
        end

        if (playerLocations & location) == location and flags.player then
            if (location == LOCATION_EXTRA) then
                local ct=Duel.GetFieldGroupCount(player,LOCATION_EXTRA,0)
                for i = 0, ct do
                    local zone = Duel.GetFieldCard(player, LOCATION_EXTRA, 0)
                    if zone and playerFilter(zone) then
                        local att = zone:GetAttribute()
                        while att > 0 do
                            local bitPos = att & -att
                            attributes[bitPos] = nil
                            att = att - bitPos
                        end
                    end
                end
            end
        end
    end
    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
                if (location == LOCATION_DECK) then
                    local ct=Duel.GetFieldGroupCount(player,0,LOCATION_DECK)
                    for i = 0, ct do
                        local zone = Duel.GetFieldCard(player, 0, LOCATION_DECK)
                        if zone and oppFilter(zone) then
                            local att = zone:GetAttribute()
                            while att > 0 do
                                local bitPos = att & -att
                                attributes[bitPos] = true
                                att = att - bitPos
                            end
                        end
                    end
                end
            end
        end

        if (playerLocations & location) == location and flags.player then
            if (location == LOCATION_DECK) then
                local ct=Duel.GetFieldGroupCount(player,LOCATION_DECK,0)
                for i = 0, ct do
                    local zone = Duel.GetFieldCard(player, LOCATION_DECK, 0)
                    if zone and playerFilter(zone) then
                        local att = zone:GetAttribute()
                        while att > 0 do
                            local bitPos = att & -att
                            attributes[bitPos] = nil
                            att = att - bitPos
                        end
                    end
                end
            end
        end
    end
    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
                if (location == LOCATION_REMOVED) then
                    local ct=Duel.GetFieldGroupCount(player,0,LOCATION_REMOVED)
                    for i = 0, ct do
                        local zone = Duel.GetFieldCard(player, 0, LOCATION_REMOVED)
                        if zone and oppFilter(zone) then
                            local att = zone:GetAttribute()
                            while att > 0 do
                                local bitPos = att & -att
                                attributes[bitPos] = true
                                att = att - bitPos
                            end
                        end
                    end
                end
            end
        end

        if (playerLocations & location) == location and flags.player then
            if (location == LOCATION_REMOVED) then
                local ct=Duel.GetFieldGroupCount(player,LOCATION_REMOVED,0)
                for i = 0, ct do
                    local zone = Duel.GetFieldCard(player, LOCATION_REMOVED, 0)
                    if zone and playerFilter(zone) then
                        local att = zone:GetAttribute()
                        while att > 0 do
                            local bitPos = att & -att
                            attributes[bitPos] = nil
                            att = att - bitPos
                        end
                    end
                end
            end
        end
    end
    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
                if (location == LOCATION_HAND) then
                    local ct=Duel.GetFieldGroupCount(player,0,LOCATION_HAND)
                    for i = 0, ct do
                        local zone = Duel.GetFieldCard(player, 0, LOCATION_HAND)
                        if zone and oppFilter(zone) then
                            local att = zone:GetAttribute()
                            while att > 0 do
                                local bitPos = att & -att
                                attributes[bitPos] = true
                                att = att - bitPos
                            end
                        end
                    end
                end
            end
        end

        if (playerLocations & location) == location and flags.player then
            if (location == LOCATION_HAND) then
                local ct=Duel.GetFieldGroupCount(player,LOCATION_HAND,0)
                for i = 0, ct do
                    local zone = Duel.GetFieldCard(player, LOCATION_HAND, 0)
                    if zone and playerFilter(zone) then
                        local att = zone:GetAttribute()
                        while att > 0 do
                            local bitPos = att & -att
                            attributes[bitPos] = nil
                            att = att - bitPos
                        end
                    end
                end
            end
        end
    end
    local result = {}
    for att, _ in pairs(attributes) do
        table.insert(result, att)
    end

    return result
end






