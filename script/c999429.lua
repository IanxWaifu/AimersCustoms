--Scripted by IanxWaifu
--Necrotic Psychauger
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    -- Discard and apply sequences
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_START)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCondition(s.rmeffcon)
    c:RegisterEffect(e2)
    --Used as Material
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.tgcon)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCondition(s.setcon)
    c:RegisterEffect(e4)
end

s.listed_series={0x29f}
s.listed_names={id}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttacker()
    local bc=Duel.GetAttackTarget()
    if not bc then return false end
    if tc:IsControler(1-tp) then bc,tc=tc,bc end
    local cards = {tc, bc}
    e:SetLabelObject(cards)
    return bc:IsFaceup() and tc:IsFaceup() and tc:IsSetCard(0x29f)
end

function s.rmeffcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp and re:IsMonsterEffect()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local cards = e:GetLabelObject()
    if cards then
    local tc = cards[1] -- Get the first card (tc)
    local bc = cards[2] -- Get the second card (bc)
end
    local tg=Duel.GetMatchingGroup(s.checkfilter,tp,0,LOCATION_MZONE,nil)
    if chk==0 then return (bc and not bc:IsDisabled() and bc:IsFaceup()) or (tc and tc:IsSetCard(0x29f) and tc:IsFaceup() and Duel.IsPlayerCanDiscardDeck(tp,2)) or (#tg>0) end
        if tc then
            Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
        end
        if bc then
            Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
    end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tg=Duel.GetMatchingGroup(s.checkfilter,tp,0,LOCATION_MZONE,nil)
    if #tg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local g=tg:Select(tp,1,1,nil)
        Duel.HintSelection(g)
        local negatt
        local negrc
        if g:GetFirst():GetAttribute() & ATTRIBUTE_DIVINE ~= 0 then
            negatt = bit.band(ATTRIBUTE_ALL, bit.bnot(g:GetFirst():GetAttribute()))
        else 
            negatt = ATTRIBUTE_ALL - ATTRIBUTE_DIVINE - g:GetFirst():GetAttribute()
        end
        if g:GetFirst():GetRace() then
            negrc = bit.band(RACE_ALL, bit.bnot(g:GetFirst():GetRace()))
        end
        local att = Duel.AnnounceAttribute(tp, 1, negatt)
        local race = Duel.AnnounceRace(tp, 1, negrc)
        Duel.BreakEffect()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_ATTRIBUTE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(att)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        g:GetFirst():RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_ADD_RACE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetValue(race)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        g:GetFirst():RegisterEffect(e2)
    end
    local cards = e:GetLabelObject()
    if cards then
        local tc = cards[1] -- Get the first card (tc)
        local bc = cards[2] -- Get the second card (bc)
        if tc and not tc:IsDisabled() and tc:IsMonster() then
            Duel.BreakEffect()
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            bc:RegisterEffect(e3)
            local e4=Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_DISABLE_EFFECT)
            e4:SetValue(RESET_TURN_SET)
            e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            bc:RegisterEffect(e4)
        end
        if bc and bc:IsFaceup() and Duel.IsPlayerCanDiscardDeck(tp,2) then
            Duel.BreakEffect()
            Duel.DiscardDeck(tp,2,REASON_EFFECT)
            local og=Duel.GetOperatedGroup():Filter(s.checkfilter2,nil)
            if #og==0 then return end
            local e5=Effect.CreateEffect(c)
            e5:SetType(EFFECT_TYPE_SINGLE)
            e5:SetCode(EFFECT_UPDATE_ATTACK)
            e5:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
            e5:SetValue(#og*500)
            tc:RegisterEffect(e5)
        end
    end
end
function s.checkfilter(c)
    return c:GetAttribute() ~= ATTRIBUTE_ALL and c:GetRace() ~= RACE_ALL and c:IsFaceup()
end

function s.checkfilter2(c)
    return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x29f)
end

    --Used as Material
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    return r & REASON_FUSION == REASON_FUSION and not c:IsLocation(LOCATION_DECK)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_COST|REASON_EFFECT)
        and c:IsPreviousLocation(LOCATION_OVERLAY)
end

function s.setfilter(c)
    return c:IsTrap() and c:IsSetCard(0x29f) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if tc then
        Duel.SSet(tp,tc)
        if tc:IsTrap() then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,4))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
            --Cannot be activated unless opponent controls ED monster
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CANNOT_TRIGGER)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            e2:SetCondition(s.triggercon)
            tc:RegisterEffect(e2)
        end
    end
end

function s.triggercon(e)
    local tp=e:GetHandlerPlayer()
    return not Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.cfilter(c)
    return c:GetSummonLocation()==LOCATION_EXTRA and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end