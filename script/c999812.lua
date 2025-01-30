--Novalxon Periapsis
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.movetg)
    e1:SetOperation(s.moveop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.zonetg)
    e2:SetValue(s.zoneval)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.rettcost)
    e3:SetTarget(s.retttg)
    e3:SetOperation(s.rettop)
    c:RegisterEffect(e3)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsSetCard(SET_NOVALXON) end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_NOVALXON),tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_NOVALXON),tp,LOCATION_MZONE,0,1,1,nil)
end

function s.moveop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local p1,p2,i
        if tc:IsControler(tp) then
            i=0
            p1=LOCATION_MZONE
            p2=0
        else
            i=16
            p2=LOCATION_MZONE
            p1=0
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
    end
end

function s.zonetg(e,c)
    return c:IsSetCard(SET_NOVALXON) and c:IsFaceup() and (c:GetSequence()%2==0)
end


function s.zoneval(e,re,c)
    local zone=c:GetSequence()
    return ((zone==0 and re:IsSpellEffect()) or (zone==2 and re:IsMonsterEffect()) or (zone==4 and re:IsTrapEffect())) and (re:GetOwnerPlayer()~=e:GetHandlerPlayer())
end

function s.rettcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.rtfilter(c,tp)
    return c:IsSetCard(SET_NOVALXON) and c:IsControler(tp) and c:IsFaceup()
end
function s.rescon(sg,e,tp,mg)
    return sg:IsExists(s.rtfilter,1,nil,tp)
end
function s.retttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local rg=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
    if chk==0 then return #rg>=2 and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
    local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_RTOHAND)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.rettop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg>0 then
        Duel.SendtoHand(tg,nil,REASON_EFFECT)
    end
end