--Scripted by IanxWaifu
--Crux of the Necromancer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,999415),matfilter=s.matfilter,extrafil=s.fextra,extraop=s.extraop,extratg=s.extratg})
	c:RegisterEffect(e1)
end
s.listed_series={0x29f}
s.listed_names={999415}

function s.matfilter(c)
	return (c:IsLocation(LOCATION_MZONE) and c:IsAbleToGrave()) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove())
end

local function GetAttributes(att)
    local attributes = {}
    
    -- Define the attributes and their corresponding values
    local attributeValues = {
        ATTRIBUTE_EARTH = 1,
        ATTRIBUTE_WATER = 2,
        ATTRIBUTE_FIRE = 4,
        ATTRIBUTE_WIND = 8,
        ATTRIBUTE_LIGHT = 16,
        ATTRIBUTE_DARK = 32,
        ATTRIBUTE_DIVINE = 64
    }
    
    -- Iterate through the attributeValues table to check each attribute
    for attribute, value in pairs(attributeValues) do
        if (att & value) == value then
            table.insert(attributes, attribute)
        end
    end
    
    return attributes
end

function s.myattfilter(c, yourMonsters, oppMonsters)
    local yourAttributes = {}
    local oppAttributes = {}

    -- Function to get attributes based on card type and attribute
    local function getAttributes(card)
        local attributes = {}

        -- Check if it's a monster card
        if card:IsType(TYPE_MONSTER) then
            local attribute = card:GetAttribute()
            if attribute ~= 0 then
                attributes[attribute] = true
            end
        end

        return attributes
    end

    -- Store your monsters' attributes
    for yc in aux.Next(yourMonsters) do
        local attributes = getAttributes(yc)
        for attribute, _ in pairs(attributes) do
            yourAttributes[attribute] = true
        end
    end

    -- Store opponent's monsters' attributes
    for tc in aux.Next(oppMonsters) do
        local attributes = getAttributes(tc)
        for attribute, _ in pairs(attributes) do
            oppAttributes[attribute] = true
        end
    end

    -- Check if any of the opponent's attributes are not in your controlled attributes
    for oppAttribute, _ in pairs(oppAttributes) do
        local hasMatchingAttribute = false
        for yourAttribute, _ in pairs(yourAttributes) do
            if oppAttribute == yourAttribute then
                hasMatchingAttribute = true
                break
            end
        end
        if not hasMatchingAttribute then
            return true  -- Opponent's monster has attributes you don't control
        end
    end

    -- Check if any of your attributes are not in the opponent's controlled attributes
    for yourAttribute, _ in pairs(yourAttributes) do
        local hasMatchingAttribute = false
        for oppAttribute, _ in pairs(oppAttributes) do
            if yourAttribute == oppAttribute then
                hasMatchingAttribute = true
                break
            end
        end
        if not hasMatchingAttribute then
            return true  -- You have attributes that the opponent doesn't control
        end
    end
    return false
end


function s.oppfcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE+LOCATION_GRAVE)<=1
end

function s.fcheck(tp, sg)
    local yourMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)  -- Get your monsters
    local oppMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil),s.oppfcheck -- Get opponent's monsters

    for tc in aux.Next(oppMonsters) do
        if s.myattfilter(tc, yourMonsters, oppMonsters) then
            return s.fcheck  -- Opponent's monster has attributes you don't control
        end
    end

    -- Include your monsters from the GY without checking attributes
    local yourGrave = Duel.GetMatchingGroup(Card.IsMonster, tp, LOCATION_GRAVE, 0, nil)
    if yourGrave:GetCount() > 0 then
        return true
    end

    return false
end

function s.rmfilter(c)
    return c:IsMonster() and c:IsAbleToRemove()
end


function s.fextra(e, tp, mg)
    local g1, g2 = Group.CreateGroup(), Group.CreateGroup()  -- Initialize g1 and g2 here
    local g2_added = false  -- Flag to track if g2 has cards added from oppMonsters loop

    if not Duel.IsPlayerAffectedByEffect(tp, 69832741) then
        g1 = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove), tp, LOCATION_GRAVE, 0, nil)
    end

    local yourMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local oppMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)

    -- Include your monsters from the GY without checking attributes
    local yourGrave = Duel.GetMatchingGroup(s.rmfilter, tp, LOCATION_GRAVE, 0, nil)
    g2:Merge(yourGrave)  -- Concatenate your monsters from GY with g2

    -- Include opponent's monsters with attributes you don't control from the FIELD
    for tc in aux.Next(oppMonsters) do
        if s.myattfilter(tc, yourMonsters, oppMonsters) then
            g2:AddCard(tc)
            g2_added = true
        end
    end

    if g2_added then
        -- Include opponent's graveyard monsters with attributes you don't control
        local oppGrave = Duel.GetMatchingGroup(s.rmfilter, tp, 0, LOCATION_GRAVE, nil)
        for tc in aux.Next(oppGrave) do
            if s.myattfilter(tc, yourMonsters, oppMonsters) then
                g2:AddCard(tc)
            end
        end
    end
    local resultGroup = Group.CreateGroup()

    if #g1 > 0 then
        resultGroup:Merge(g1)
    end

    if #g2 > 0 then
        resultGroup:Merge(g2)
    end

    return resultGroup 
end


function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
