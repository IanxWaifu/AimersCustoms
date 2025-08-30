--Scripted by Aimer
--Shiroki Junsei no Uroko
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Quick Effect: Chain protection for Kegai/Kijin
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.protcon)
    e1:SetCost(s.protcost)
    e1:SetOperation(s.protop)
    c:RegisterEffect(e1)
    --Material effect: Protect summoned monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.matcon)
    e2:SetOperation(s.matop)
    c:RegisterEffect(e2)
end

--Check if opponent chained to Kegai/Kijin card effect
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    local rc=re:GetHandler()
    return (rc:IsSetCard(SET_KEGAI) or rc:IsSetCard(SET_KIJIN)) and re:IsActivated()
end
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
    local ch=Duel.GetCurrentChain(true)-1
    return ep==1-tp and ch>0 and Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)==tp
        and (Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT):GetHandler():IsSetCard(SET_KEGAI) or Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT):GetHandler():IsSetCard(SET_KIJIN))
end
--Discard this card as cost
function s.protcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
--Make your Kegai/Kijin cards unaffected by opponent's effects until end of chain
function s.protop(e,tp,eg,ep,ev,re,r,rp)
    --Unaffected
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetTargetRange(LOCATION_ALL,0)
    e1:SetTarget(s.etg)
    e1:SetValue(1)
    e1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(e1,tp)
end
function s.etg(e,c)
    return c:IsSetCard({SET_KEGAI,SET_KIJIN})
end


--Material condition: for Dragon, Fiend, or Reptile
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:GetReasonCard():IsRace(RACE_DRAGON) or c:GetReasonCard():IsRace(RACE_FIEND) or c:GetReasonCard():IsRace(RACE_REPTILE))
end

--Apply destroy & banish protection until end of next turn
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetHandler():GetReasonCard()
    if not rc then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTIBLE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(1)
    e1:SetOwnerPlayer(tp)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
    rc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    rc:RegisterEffect(e2)
end
