--Scripted by IanxWaifu
--Necrotic Revenant Aperture
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    --Change the Attribute of 1 monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.attrtg)
    e2:SetOperation(s.attrop)
    c:RegisterEffect(e2)
end

s.listed_series={0x29f}
s.listed_names={id}

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
function s.cfilter(c, tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp)
end

-- Attribute count function
function s.GetAttributeCount(card)
    local att = card:GetAttribute()
    local attCount = 0
    while att > 0 do
        if att & 0x1 ~= 0 then
            attCount = attCount + 1
        end
        att = att >> 1
    end
    return attCount
end

-- Attribute count filter
function s.attctfilter(c)
    return c:IsFaceup() and s.GetAttributeCount(c) > 1 
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ct = Duel.GetMatchingGroupCount(s.attctfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if chk == 0 then
        return ct > 0 and Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, nil)
    end
end

-- Attribute selection and operation
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.attctfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    local g2 = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_ONFIELD, nil)
    if #g == 0 then return false end
    local removedCount = 0
    for tc in aux.Next(g) do
        local attCount = s.GetAttributeCount(tc)
        while attCount > 1 do
            local quickatt = tc:GetAttribute()
            -- Set the Divine attribute bit to 0
            quickatt = quickatt & ~ATTRIBUTE_DIVINE
            Duel.HintSelection(tc)
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
            if attCount == 1 then
                break
            end
        end
    end
    if removedCount > 0 then
        local dg = Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, 0, LOCATION_ONFIELD, 1, removedCount, nil)
        if #dg > 0 then
            Duel.HintSelection(dg)
            Duel.Destroy(dg, REASON_EFFECT)
            s.ApplyEffectToCards(s.cfilter, tp, e)
        end
    end
end


--Attribute Gain BFG
function s.attfil(c,e,att)
    return c:IsCanBeEffectTarget(e) and c:IsAttributeExcept(att) and c:IsFaceup() and c:GetAttribute() ~= ATTRIBUTE_ALL
end

function s.attrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsAttributeExcept(e:GetLabel())
    end
    if chk==0 then
        return Duel.IsExistingTarget(s.attfil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,e:GetLabel())
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.SelectTarget(tp,s.attfil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,e:GetLabel())
    local negatt
    if g:GetFirst():GetAttribute() & ATTRIBUTE_DIVINE ~= 0 then
        negatt = bit.band(ATTRIBUTE_ALL, bit.bnot(g:GetFirst():GetAttribute()))
    else 
        negatt = ATTRIBUTE_ALL - ATTRIBUTE_DIVINE - g:GetFirst():GetAttribute()
    end
    local att = Duel.AnnounceAttribute(tp, 1, negatt)
    e:SetLabel(att)
end

function s.attrop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_ATTRIBUTE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(e:GetLabel())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        tc:RegisterEffect(e1)
    end
end
