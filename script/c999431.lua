--Scripted by IanxWaifu
--Necrotic Soul Harvest
local s, id = GetID()

function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
end

-- Function to get the count of set bits (1s) in a card's attribute
function GetAttributeCount(card)
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

function s.attcountfilter(c)
 	local attCount = GetAttributeCount(c)
    return c:IsFaceup() and attCount > 1
end

function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.attcountfilter(chkc) end
    if chk==0 then
        return ((Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsPlayerCanDiscardDeck(1-tp,1)) or Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_SZONE,1,nil)) 
            and Duel.IsExistingMatchingCard(s.attcountfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_SZONE)
end


function s.PerformCardRemoval(tp, removedCount, e)
    local szone = Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, 0, LOCATION_SZONE, nil)
    local mydeck = Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)
    local oppdeck = Duel.GetFieldGroupCount(1 - tp, LOCATION_DECK, 0)
    
    if #szone >= removedCount or
       (mydeck >= removedCount and oppdeck >= removedCount) or
       (#szone + mydeck >= removedCount and #szone + oppdeck >= removedCount) then
       
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
        if #szone == 0 then
            s.PerformDiscardDeck(tp, removedCount, e)
        else
            s.PerformSelectAndGrave(tp, removedCount, e)
        end
    end
end

function s.PerformDiscardDeck(tp, count, e)
    if Duel.IsPlayerCanDiscardDeck(tp, count) and Duel.IsPlayerCanDiscardDeck(1 - tp, count) then
        Duel.DiscardDeck(tp, count, REASON_EFFECT)
        Duel.DiscardDeck(1 - tp, count, REASON_EFFECT)
        s.ApplyEffectToCards(s.cfilter, tp, e)
    end
end

function s.PerformSelectAndGrave(tp, count, e)
    local og = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_SZONE, 0, count, nil)
    Duel.SendtoGrave(og, REASON_EFFECT)
    local oc = Duel.GetOperatedGroup():FilterCount(Card.IsLocation, nil, LOCATION_GRAVE)
    
    if oc < count then
        local deckCount = count - oc
        s.PerformDiscardDeck(tp, deckCount, e)
    end
end

function s.ApplyEffectToCards(cfilter, tp, e)
    local c = e:GetHandler()
    local fg1 = Duel.GetOperatedGroup()
    local fg2 = fg1:Filter(cfilter, nil, tp)
    for dc in aux.Next(fg2) do
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id, 3))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        dc:RegisterEffect(e1)
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_TRIGGER)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
        dc:RegisterEffect(e2)
    end
end

function s.attop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local removedCount = 0
    while true do
        local dg = Duel.GetMatchingGroup(s.attcountfilter, tp, LOCATION_MZONE, 0, nil)
        local tg = dg:Select(tp, 1, 1, nil)
        local tc = tg:GetFirst()
        local attCount = GetAttributeCount(tc)
        
        while attCount > 1 do
            local quickatt = tc:GetAttribute()
            local att_to_lose = Duel.AnnounceAttribute(tp, 1, quickatt)
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            e1:SetValue(att_to_lose)
            tc:RegisterEffect(e1)
            Duel.AdjustInstantly(tc)
            attCount = attCount - 1
            removedCount = removedCount + 1
            if attCount > 1 and not Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
                break  -- Exit the loop if the player chooses to stop
            end
        end
        
        local fdg = Duel.GetMatchingGroup(s.attcountfilter, tp, LOCATION_MZONE, 0, nil)
        if #fdg == 0 or not Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            break
        end
    end
    
    s.PerformCardRemoval(tp, removedCount, e)
end

function s.cfilter(c, tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp)
end