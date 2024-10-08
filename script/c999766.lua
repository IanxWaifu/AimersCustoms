--Azhimaou - Malphashax
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
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK)
    e0:SetCode(EVENT_ADJUST)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)
    --Destroy itself upon Custom Event
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CUSTOM+id)
    e1:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK)
    e1:SetCountLimit(1)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    --Special
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.tgcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    --Remove until End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
    -- Check for activated "Azhimaou" Spell/Traps
    aux.GlobalCheck(s,function()
        s[0]=0
        s[1]=0
        aux.AddValuesReset(function()
            s[0]=0
            s[1]=0
        end)
        local ge1=Effect.GlobalEffect()
        ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        ge1:SetCode(EVENT_CHAIN_SOLVING)
        ge1:SetCondition(s.regcon1)
        ge1:SetOperation(s.regop1)
        Duel.RegisterEffect(ge1,0)
        local ge2=Effect.GlobalEffect()
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_CHAIN_NEGATED)
        ge2:SetCondition(s.regcon1)
        ge2:SetOperation(s.regop2)
        Duel.RegisterEffect(ge2,0)
    end)
end

--Raise Custom Event
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetLevel()>1 then return end
    if c:GetLevel()<=1 and ((c:IsLocation(LOCATION_HAND)) or (c:IsLocation(LOCATION_DECK)) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())) then
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

--Send to Grave
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_REMOVED,LOCATION_REMOVED,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,PLAYER_ALL,LOCATION_REMOVED)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_REMOVED,LOCATION_REMOVED,2,2,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
    end
end

--Banish until the End Phase
function s.rmfilter(c)
    return c:IsAbleToRemove() and not ((c:IsStatus(STATUS_ACTIVATED)) or (c:IsStatus(STATUS_ACT_FROM_HAND)))
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.rmfilter(chkc) end
    local ct=s[tp]
    if chk==0 then return s[tp]>0 and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,s[tp],nil)
    e:SetLabelObject(g1)
    g1:KeepAlive()
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
    Duel.SetChainLimit(s.chlimit)
end

function s.chlimit(e,ep,tp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return tp==ep or not g:IsContains(e:GetHandler())
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
        local og=Duel.GetOperatedGroup()
        local oc=og:GetFirst()
        for oc in aux.Next(og) do
            oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        end
        og:KeepAlive()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetLabelObject(og)
        e1:SetCountLimit(1)
        e1:SetLabel(Duel.GetTurnCount())
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetCondition(s.retcon)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1,tp)
    end
end

--Return next turn
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    local sg=g:Filter(s.retfilter,nil)
    for tc in aux.Next(sg) do
        if tc:GetFlagEffect(id)~=0 then
            return Duel.GetTurnCount()==e:GetLabel()
        else
            e:Reset()
            return false
        end
    end
end

function s.retfilter(c)
    return c:GetFlagEffect(id)~=0
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    local sg=g:Filter(s.retfilter,nil)
    g:DeleteGroup()
    for tc in aux.Next(sg) do
        local seq=tc:GetPreviousSequence()
        local zone=0x1<<seq
        local p=tc:GetOwner()
        if tc:IsType(TYPE_FIELD) then
            Duel.MoveToField(tc,p,p,LOCATION_FZONE,tc:GetPreviousPosition(),true)
        else
            if seq>4 then
                Duel.SendtoGrave(tc,REASON_RULE+REASON_RETURN)
            else
                Duel.ReturnToField(tc,tc:GetPreviousPosition(),zone,p)
            end
        end
    end
end

function s.regcon1(e,tp,eg,ep,ev,re,r,rp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(SET_AZHIMAOU)
end

function s.regop1(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsSetCard(SET_AZHIMAOU) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
        re:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
        s[tp]=s[tp]+1
    end
end

function s.regop2(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsSetCard(SET_MAGICAL_MUSKET) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
        local val=s[tp]
        if val==0 then val=1 end
        val=val-1
    end
end

function s.regop2(e,tp,eg,ep,ev,re,r,rp)
    re:GetHandler():ResetFlagEffect(id)
end