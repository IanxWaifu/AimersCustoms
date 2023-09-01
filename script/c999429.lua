--Scripted by IanxWaifu
--Necrotic Crypt Maiden
local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be destroyed by battle or card effects while you control a specific monster
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.indescon)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e2)
    -- Zombie monsters you control gain 300 ATK/DEF
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetValue(300)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
    -- Send a "Necrotic" card from Deck to GY on Normal or Special Summon
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_TOGRAVE)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SUMMON_SUCCESS)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,id)
    e5:SetTarget(s.tgtg)
    e5:SetOperation(s.tgop)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e6)
end

-- Condition for the indestructible effect
function s.rcfilter(c)
    return c:IsSetCard(0x29f) and c:IsRace(RACE_ZOMBIE) and c:IsFaceup() and C:IsType(TYPE_FUSION)
end
function s.indescon(e)
    local c=e:GetHandler()
    return Duel.IsExistingMatchingCard(Card.IsCode,c:GetControler(),LOCATION_MZONE,0,1,nil,999415)
        or Duel.IsExistingMatchingCard(s.rcfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

-- Send a "Necrotic" card from Deck to GY on Normal or Special Summon
function s.tgfilter(c)
    return c:IsSetCard(0x29f) and not c:IsCode(id) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end