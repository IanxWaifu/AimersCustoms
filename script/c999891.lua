--Kegai - Doroku ni Shinkoudaraku
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate 1 of these effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thsptg)
    e1:SetOperation(s.thspop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(Cost.SelfBanish)
    e2:SetCondition(s.lfcon)
    e2:SetTarget(s.lftg)
    e2:SetOperation(s.lfop)
    c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}


function s.tdfilter(c,e,tp)
    return c:IsSetCard(SET_KEGAI) and c:IsOriginalType(TYPE_RITUAL) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.spfilter(c,e,tp)
    return ((c:IsFaceup() and not c:IsLocation(LOCATION_HAND)) or c:IsLocation(LOCATION_HAND)) and c:IsSetCard(SET_KEGAI) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
    and (c:IsOriginalType(TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER))
end

function s.thfilter(c,code)
    return c:IsSetCard(SET_KEGAI) and c:IsSpellTrap() and c:IsAbleToHand() and not c:IsCode(code) and not c:IsCode(id)
end

function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,e,tp) end
        --[[or (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_SZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end--]]
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_SZONE)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,nil,e,tp)
    if #g1>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        g1=g1:Select(tp,1,1,nil)
    end
    if #g1==1 then
        Duel.ConfirmCards(1-tp,g1)
        if g1:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then Duel.ShuffleHand(tp) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tc=g1:GetFirst()
        local code=tc:GetCode()
        local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
        if #hg>0 then 
            Duel.BreakEffect()
            Duel.SendtoHand(hg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,hg)
        end
        if tc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and s.spfilter(tc,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
        end
    end
end

--If leaves the field, return to hand
function s.lffilter(c)
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.lfcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.lffilter,1,nil) and ((re and re:GetHandler():IsType(TYPE_RITUAL)) or ((r&REASON_RITUAL)==REASON_RITUAL))
end

function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.lfop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end