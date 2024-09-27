--Azhimaou - Empusith
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    -- Add 1 "Achimaou" Ritual Card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    --Synchro Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.synchcon)
    e3:SetTarget(s.synchtg)
    e3:SetOperation(s.synchop)
    c:RegisterEffect(e3)
end

function s.filter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end


function s.synchcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsStatus(STATUS_SPSUMMON_TURN+STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN)
end
function s.syncfilter(c)
    return c:IsFaceup()
end
function s.exfilter(c,mg)
    return --[[c:IsSetCard(SET_AZHIMAOU) and --]] c:IsSynchroSummonable(nil,mg)
end
function s.synchtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mg=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_MZONE,0,nil)
    if chk==0 then return #mg>0 and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,nil,mg) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_MZONE,0,nil)
    if #mg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,nil,mg)
    if #g>0 then
        Duel.SynchroSummon(tp,g:GetFirst(),nil,mg)
    end
end