--Aimers Auxillary Functions

if not aux.AimersAux then
    aux.AimersAux = {}
    Aimer = aux.AimersAux
end

if not Aimer then
    Aimer = aux.AimersAux
end

--Common used cards
CARD_ZORGA = 999415



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






