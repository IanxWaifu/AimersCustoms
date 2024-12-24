--Azhimaou - Angramalog
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --synchro summon
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_AZHIMAOU),1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_AZHIMAOU),1,99)
    c:EnableReviveLimit()
    --Register Custom Event upon Level Adjustment
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e0:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK)
    e0:SetCode(EVENT_ADJUST)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)
    --Allows Negative Levels
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ALLOW_NEGATIVE)
    c:RegisterEffect(e1)
    --Destroy itself upon Custom Event
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CUSTOM+id)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK)
    e2:SetCountLimit(1)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    --Negate
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.discon)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
    --Special
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

--Raise Custom Event
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetLevel()>0 then return end
    if c:GetLevel()<=0 and ((c:IsLocation(LOCATION_HAND)) or (c:IsLocation(LOCATION_DECK)) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())) then
        Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
    end
end

--Self Destroy upon Custom Event
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_RULE)
end

--Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp,lv)
    return c:IsSetCard(SET_AZHIMAOU) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,true,true) and c:IsLevel(lv)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local lv=c:GetPreviousLevelOnField()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,lv) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    local lv=c:GetPreviousLevelOnField()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end



--Disable Effct/Shuffle
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return Duel.IsChainDisablable(ev)
end

function s.tdfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ct=c:GetLevel()//4
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,ct,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_GRAVE|LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=c:GetLevel()//4
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,ct,ct,nil)
    if #g>0 then
        local ct=Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
        local og=Duel.GetOperatedGroup()
        if #og==0 then return end
        if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.SortDeckbottom(tp,tp,ct) end
        if ct==#g then
            Duel.NegateEffect(ev)
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
            Duel.Draw(1-tp,1,REASON_EFFECT)
        end
    end
end