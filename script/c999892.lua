--Kegai - Hakusai no Noroi
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate 1 of these effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(Cost.SelfBanish)
    e2:SetTarget(s.pctg)
    e2:SetOperation(s.pcop)
    c:RegisterEffect(e2)
     --Activate it from hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e3:SetCondition(s.actcon)
    c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}

--banish 2
function s.resfilter(c)
    return c:IsSetCard(SET_KEGAI) and c:IsOriginalType(TYPE_MONSTER)
end
function s.rescon(sg,e,tp,mg)
    return sg:IsExists(s.resfilter,1,nil)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeEffectTarget,e),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
    if chk==0 then return aux.SelectUnselectGroup(g,1,tp,2,2,s.rescon,chk,tp) end
    local tg=aux.SelectUnselectGroup(g,1,tp,2,2,s.rescon,chk,tp)
    Duel.SetTargetCard(tg)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g~=0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

--activate from hand
function s.actfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_KEGAI) and c:IsOriginalType(TYPE_MONSTER) and c:IsOriginalType(TYPE_RITUAL)
end
function s.actcon(e)
    return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

function s.pcfilter(c,tp)
    return c:IsSetCard(SET_KEGAI) and c:IsMonster() and not c:IsForbidden() and c:CheckUniqueOnField(tp) and (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and (c:IsLocation(LOCATION_REMOVED) or c:IsLocation(LOCATION_GRAVE))))
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
        and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pcfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET)
        e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
        tc:RegisterEffect(e1)
    end
end