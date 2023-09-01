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
function s.checkmat(tp,sg,fc)
	return fc:ListsCodeAsMaterial(999415) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end


function s.myattfilter(c, yourMonsters, oppMonsters)
    local yourBits = 0
    local oppBits = 0

    for yc in aux.Next(yourMonsters) do
        yourBits = yourBits | (1 << yc:GetAttribute())
    end

    for tc in aux.Next(oppMonsters) do
        oppBits = oppBits | (1 << tc:GetAttribute())
    end

    local unmatchedBits = oppBits & ~yourBits

    if unmatchedBits ~= 0 then
        return true  -- Opponent's monster has attributes you don't control
    end

    return false
end

function s.fcheck(tp, sg)
    if not sg:IsExists(Card.IsLocation, 1, nil, LOCATION_MZONE) then
        return false
    end

    local yourMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)  -- Get your monsters
    local oppMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil) -- Get opponent's monsters

    for tc in aux.Next(oppMonsters) do
        if s.myattfilter(tc, yourMonsters, oppMonsters) then
            return true  -- Opponent's monster has attributes you don't control
        end
    end

    return false
end


function s.fextra(e, tp, mg)
    local g1, g2 = Group.CreateGroup(), Group.CreateGroup()
    local g2_added = false  -- Flag to track if g2 has cards added from oppMonsters loop

    if not Duel.IsPlayerAffectedByEffect(tp, 69832741) then
        g1 = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove), tp, LOCATION_GRAVE, 0, nil)
    end

    local yourMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local oppMonsters = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)

    for tc in aux.Next(oppMonsters) do
        if s.myattfilter(tc, yourMonsters, oppMonsters) then
            g2:AddCard(tc)
            g2_added = true
        end
    end

    if g2_added then
        -- Include opponent's graveyard monsters with attributes you don't control
        local oppGrave = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_GRAVE, nil)
        for tc in aux.Next(oppGrave) do
            if s.myattfilter(tc, yourMonsters, oppMonsters) then
                g2:AddCard(tc)
            end
        end
    end

    local resultGroup = Group.CreateGroup()

    if #g1 > 0 then
        resultGroup:Merge(g1)
        if not s.checkmat(tp, resultGroup, e:GetHandler()) then
            return nil
        end
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
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_EITHER,LOCATION_GRAVE)
end
