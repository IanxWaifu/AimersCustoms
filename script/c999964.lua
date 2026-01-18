--Kansha Naki Köken
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id)
    e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    --Banish Ritual Spell
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.rtftg)
    e1:SetOperation(s.rtfop)
    c:RegisterEffect(e1)
    --Cannot negate the activation of your Fusion Summoning cards/effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)
    --Cannot activate cards/effects when Fusion Summoning
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.limcon)
    e3:SetOperation(s.limop)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCode(EVENT_CHAIN_END)
    e4:SetOperation(s.limop2)
    c:RegisterEffect(e4)
end

s.listed_names={id}
s.listed_series={SET_KEGAI,SET_KYOSHIN}

--Place to S&T Zone
function s.cfilter(c,tp)
    return c:IsSetCard({SET_KEGAI,SET_KYOSHIN}) and c:IsMonster() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.cfilter),tp,LOCATION_HAND|LOCATION_REMOVED|LOCATION_GRAVE,0,nil,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
            --Treat it as a Continuous Trap
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET)
            tc:RegisterEffect(e1)
        end
    end
end


--Banish from GYs

function s.rtfilter(c)
    return c:IsRitualSpell() and c:IsAbleToRemove()
end
function s.rtftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_GRAVE,0,1,nil) 
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.rtfop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
        if #rg>0 then
            Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
        end
    end
end
--Cannot Be Negated
function s.efilter(e,ct)
    local tp=e:GetHandlerPlayer()
    local te,rp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
    if tp~=rp then return false end
    if te:IsHasCategory(CATEGORY_FUSION_SUMMON) then return true end
    local tc=te:GetHandler()
    return tc and tc:IsRitualSpell()
end

--Cannot Activate on Summon
function s.limfilter(c,tp)
    return c:IsSummonPlayer(tp) and (c:IsFusionSummoned() or c:IsRitualSummoned())
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.limfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentChain()==0 then
        Duel.SetChainLimitTillChainEnd(s.chainlm)
    elseif Duel.GetCurrentChain()==1 then
        e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_CHAINING)
        e1:SetOperation(s.resetop)
        Duel.RegisterEffect(e1,tp)
        local e2=e1:Clone()
        e2:SetCode(EVENT_BREAK_EFFECT)
        e2:SetReset(RESET_CHAIN)
        Duel.RegisterEffect(e2,tp)
    end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():ResetFlagEffect(id)
    e:Reset()
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetFlagEffect(id)>0 then
        Duel.SetChainLimitTillChainEnd(s.chainlm)
    end
    e:GetHandler():ResetFlagEffect(id)
end
function s.chainlm(e,rp,tp)
    return tp==rp
end