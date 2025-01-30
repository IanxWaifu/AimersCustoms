--Novalxon Meridian
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.rmcon)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e4)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(_c) return _c:IsSetCard(SET_NOVALXON) end)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return not c:IsSetCard(SET_NOVALXON) end)
    Duel.RegisterEffect(e1,tp)
end


function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_NOVALXON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and (c:IsLocation(LOCATION_DECK) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
        local seq=tc:GetSequence()
        --Cannot activate its effects
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_TRIGGER)
        e1:SetLabel(seq)
        e1:SetCondition(s.seqcon)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
    Duel.SpecialSummonComplete()
end
function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
    local seq=e:GetLabel()
    return e:GetHandler():GetSequence()==seq
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return tc:IsSummonPlayer(1-tp) and Duel.IsExistingMatchingCard(s.novalxonfilter,tp,LOCATION_MZONE,0,1,nil,tc:GetColumnGroup())
end
function s.novalxonfilter(c,col)
    return c:IsSetCard(SET_NOVALXON) and col:IsContains(c)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
    g:AddCard(e:GetHandler())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rmfilter(c)
    return c:IsSetCard(SET_NOVALXON) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:GetFirst():IsAbleToRemove() end
    Duel.SetTargetCard(eg:GetFirst())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
