--Scripted by IanxWaifu
--Necrotic Soul Harvest
local s, id = GetID()
function s.initial_effect(c)
    -- Targeted monster has its effects negate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    c:RegisterEffect(e1)
    --bfg
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
end

function s.oppfilter(c, tp)
    return (c:IsNegatableMonster() or (c:IsFaceup() and (c:GetAttack() > 0 or c:GetDefense() > 0))) and Duel.IsExistingMatchingCard(s.myattfilter, tp, LOCATION_MZONE, 0, 1, nil, c)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk == 0 then return Duel.IsExistingTarget(s.oppfilter, tp, 0, LOCATION_MZONE, 1, nil, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.oppfilter, tp, 0, LOCATION_MZONE, 1, 1, nil, tp)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.myattfilter(c,tc)
    return c:IsFaceup() and (tc:GetAttribute()&(~c:GetAttribute()))&~ATTRIBUTE_DIVINE~=0
end
-- Operation function
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    local att = tc:GetAttribute()
    local g1 = Duel.GetMatchingGroup(s.myattfilter, tp, LOCATION_MZONE, 0, nil, tc) 
    if tc:IsCanBeDisabledByEffect(e) and #g1>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(-1000)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e4)
		if tc:IsImmuneToEffect(e1) or (tc:IsImmuneToEffect(e2) or tc:IsImmuneToEffect(e3)) then return end
		Duel.AdjustInstantly(tc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	    local ssg=g1:Select(tp,1,1,nil)
		local sc=ssg:GetFirst()
		if sc then
		    local negatt = (att&(~sc:GetAttribute()))&~ATTRIBUTE_DIVINE
		    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTRIBUTE)
		    local new_att = Duel.AnnounceAttribute(tp, 1, negatt)
		    local e1 = Effect.CreateEffect(e:GetHandler())
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
		    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		    e1:SetValue(new_att)
		    e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
		    sc:RegisterEffect(e1)
	    end
	end
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
function s.attcountfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x29f) and s.GetAttributeCount(c) > 1
end

-- Attribute targeting
function s.attg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.attcountfilter(chkc) end
    if chk == 0 then
        return ((Duel.IsPlayerCanDiscardDeck(tp, 1) and Duel.IsPlayerCanDiscardDeck(1 - tp, 1)) or Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, 0, LOCATION_SZONE, 1, nil))
            and Duel.IsExistingTarget(s.attcountfilter, tp, LOCATION_MZONE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, s.attcountfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    local tc = g:GetFirst()
    local attCount = s.GetAttributeCount(tc)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(attCount - 1)
    Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, PLAYER_ALL, attCount - 1)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_SZONE)
end



-- Attribute selection and operation
function s.attop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or not tc:IsFaceup() or not Duel.IsPlayerCanDiscardDeck(tp, 1) then return end
    local attCount = s.GetAttributeCount(tc)
    local removedCount = 0
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
        if attCount == 1 or not Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            break
        end
    end
    local newattCount = s.GetAttributeCount(tc)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    Duel.DiscardDeck(tp, removedCount*2, REASON_EFFECT)
    Duel.DiscardDeck(1 - tp, removedCount*2, REASON_EFFECT)
end