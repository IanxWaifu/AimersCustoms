--Genosynx Plagrixva
--Scripted by Aimer
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ILLUSION),1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPIRIT),1,99)
	c:EnableReviveLimit()
    -- Spirit Procedure (Override)
    local se1,se2=Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP)
    se1:SetDescription(aux.Stringid(id,4))
    se1:SetCategory(CATEGORY_TOHAND+CATEGORY_POSITION)
    se1:SetTarget(s.spretg)
    se1:SetOperation(s.spretop)
    --If Synchro Summoned or flipped face-up
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.tgcon1)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_FLIP)
    c:RegisterEffect(e2)
    --Negate Extra Deck monster effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_CHAINING)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    e3:SetCountLimit(1,{id,1})
    c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={SET_GENOSYNX}

--Spirit Return Custom
function s.spretg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    c:ResetFlagEffect(FLAG_SPIRIT_RETURN)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.spretop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SendtoHand(c,nil,REASON_EFFECT)==0 then return end
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local dg=g:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

--Attach or Send
function s.deckfilter(c)
    return c:IsSetCard(SET_GENOSYNX)
end
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_XYZ)
end

function s.tgcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.deckfilter,tp,LOCATION_DECK,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    local b1=tc:IsAbleToGrave()
    local b2=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
    if b1 and b2 then
        local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if op==0 then
            Duel.SendtoGrave(tc,REASON_EFFECT)
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
            local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
            if xyz then Duel.Overlay(xyz,tc) end
        end
    elseif b1 then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    elseif b2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
        local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if xyz then Duel.Overlay(xyz,tc) end
    end
end

--Negate Extra Deck monster effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonLocation(LOCATION_EXTRA)
        and Duel.IsChainDisablable(ev)
end

function s.costfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsAbleToDeckAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetMatchingGroupCount(s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)>=3
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end