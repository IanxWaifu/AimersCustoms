--Alekron - Ingelia
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    -- Special Summon from Deck when a card in the GY activates its effect
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
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.hspctg)
    e2:SetOperation(s.hspcop)
    c:RegisterEffect(e2)
end

-- e1: Special Summon from Deck when a GY effect activates
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler():IsLocation(LOCATION_GRAVE)
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
    if chk==0 then 
        return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler())
            and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.hspcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Send 1 "Alekron" card from hand or field to GY
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
    if Duel.SendtoGrave(g1,REASON_EFFECT)~=0 then
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
end
