--Alekron - Meliyrna
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    -- Special Summon from GY when a card on the field activates its effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_CHAIN_ACTIVATING)
    e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Fusion Summon non-Spellcaster Alekron Fusion Monster during the turn this card is summoned
    local params={function(c) return c:IsSetCard(SET_ALEKRON) and not c:IsRace(RACE_SPELLCASTER) end}
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.fuscon)
    e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
    e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
    c:RegisterEffect(e2)
end

-- e1: Special Summon from GY when a field effect activates
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler():IsLocation(LOCATION_ONFIELD)
end

-- e2: Special Summon self and send to GY
function s.tgfilter(c)
    return c:IsSetCard(SET_ALEKRON) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.cfilter(c)
    return c:IsSetCard(SET_ALEKRON) and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
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

-- e3: Fusion Summon during turn this card is summoned
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsStatus(STATUS_SPSUMMON_TURN+STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN)
end
