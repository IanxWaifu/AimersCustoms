--Alekron - Thyrsa
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    -- Special Summon from GY when a card in the hand activates its effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_CHAIN_ACTIVATING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Special Summon self and send Alekron card to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.hspctg)
    e2:SetOperation(s.hspcop)
    c:RegisterEffect(e2)
    --You cannot Special Summon, except FIRE monsters
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(1,0)
    e3:SetTarget(function(_,_c)return not _c:IsSetCard(SET_ALEKRON) end)
    c:RegisterEffect(e3)
end

-- e1: Special Summon from GY when a card in the hand activates its effect
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler():IsLocation(LOCATION_HAND)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_ALEKRON) and not c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- e2: Special Summon self and send to GY
function s.tgfilter(c)
    return c:IsSetCard(SET_ALEKRON) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.cfilter(c)
    return c:IsSetCard(SET_ALEKRON) and c:IsAbleToGrave()
end
function s.hspctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.hspcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Special Summon itself
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- Send 1 "Alekron" card from Deck to GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g2>0 then
            Duel.SendtoGrave(g2,REASON_EFFECT)
        end
    end
end
