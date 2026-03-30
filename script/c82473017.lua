--Genosynx Garupegrim
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.ffilter,3)
    -- Spirit Procedure (Override)
    local se1,se2=Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP)
    se1:SetDescription(aux.Stringid(id,4))
    se1:SetCategory(CATEGORY_TOHAND+CATEGORY_POSITION)
    se1:SetTarget(s.spretg)
    se1:SetOperation(s.spretop)
    --Flip all other face-up monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_FLIP)
    c:RegisterEffect(e2)
    --Negate effect activation
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.discon)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_POSITION)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE|PHASE_STANDBY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.fchangepostg)
    e4:SetOperation(s.fchangeposop)
    c:RegisterEffect(e4)
end

s.listed_names={id}
s.listed_series={SET_GENOSYNX}
--Spirit Return Custom
function s.spretg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and tc:IsCanTurnSet() end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    c:ResetFlagEffect(FLAG_SPIRIT_RETURN)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,tp,POS_FACEDOWN_DEFENSE)
end

function s.spretop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SendtoHand(c,nil,REASON_EFFECT)==0 then return end
    local g=Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and tc:IsCanTurnSet() end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.BreakEffect()
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end

--Fusion Materials
function s.ffilter(c,fc,sumtype,tp)
    return c:IsType(TYPE_SPIRIT,fc,sumtype,tp) or c:IsType(TYPE_TRAP,fc,sumtype,tp)
end
function s.posfilter(c)
    return not (c:IsFaceup() and c:IsDefensePos())
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,e:GetHandler())
    if Duel.ChangePosition(g,POS_FACEUP_DEFENSE)~=0 then
        local og=Duel.GetOperatedGroup()
        local oc=og:GetFirst()
        for oc in aux.Next(og) do
            --Become unaffected by its owners activated effects while in Defense.
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_IMMUNE_EFFECT)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e1:SetRange(LOCATION_MZONE)
            e1:SetCondition(s.immcon)
            e1:SetValue(s.immval)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            oc:RegisterEffect(e1)
        end
    end
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsDefensePos()
end
function s.immval(e,te)
    return te:GetOwnerPlayer()==e:GetHandlerPlayer() and te:IsActivated()
end


------
-- returns true if this chain link includes a Special Summon that comes from Deck or Extra
function s.chain_summons_from_deck_or_extra(ev)
    local ex,g=Group.CreateGroup(),Group.CreateGroup()
    local loc=0
    local ok,sg,sp,sloc=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
    if not ok then return false end
    loc=sloc or 0
    return (loc&(LOCATION_DECK|LOCATION_EXTRA))~=0
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not Duel.IsChainNegatable(ev) then return false end
    if not re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then return false end
    return s.chain_summons_from_deck_or_extra(ev)
end
function s.disfilter(c)
    return c:IsType(TYPE_EFFECT) and c:IsFaceup() and not c:IsDisabled()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.disfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local tc=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESETS_STANDARD_PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESETS_STANDARD_PHASE_END)
        tc:RegisterEffect(e2)
    end
end

---------
function s.fchangepostg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function s.fchangeposop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.ChangePosition(c,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE)
end