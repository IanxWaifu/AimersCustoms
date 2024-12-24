--Azhimaou - Akashisko
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --synchro summon
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_AZHIMAOU),1,99)
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
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CUSTOM+id)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK)
    e3:SetCountLimit(1)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
    --Place on Bottom of the Deck/ ATK/DEF Gain
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.tdcost)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)
    --Special
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
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

--Place on Bottom of the Deck/ ATK/DEF Gain
function s.tdfilter(c)
    return c:IsAbleToDeckAsCost() and c:IsSetCard(SET_AZHIMAOU) 
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
    Duel.SendtoDeck(g,nil,1,REASON_COST)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    --Cannot be Link MAterial
    local c=e:GetHandler()
    --atk/def gain
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetValue(500)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    Duel.RegisterEffect(e2,tp)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetReset(RESET_PHASE+PHASE_END)
    e3:SetValue(s.indtg)
    Duel.RegisterEffect(e3,tp)
    aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2),nil)
end

function s.indtg(e,c)
    return c:IsSetCard(SET_AZHIMAOU)
end


--Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp,lv)
    return c:IsSetCard(SET_AZHIMAOU) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(lv)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local lv=c:GetPreviousLevelOnField()
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,lv) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
