--Kegai - Kuroshoku no Soka
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    local rparams={filter=aux.FilterBoolFunction(Card.IsSetCard,SET_KEGAI),lvtype=RITPROC_GREATER,
    filter=aux.FilterBoolFunction(Card.IsSetCard,SET_KEGAI),
    extrafil=s.extragroup,
    extraop=s.extraop,
    matfilter=s.matfilter,
    location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,
    forcedselection=s.ritcheck,
    extratg=s.extratg}
    --No Chain Link
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.clcondition1)
    e1:SetTarget(s.target(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e1)
    --Chain Link 2+
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCountLimit(1,{id+EFFECT_COUNT_CODE_OATH,1})
    e2:SetTarget(s.target2(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e2:SetCost(s.cost)
    e2:SetOperation(s.operation2(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e2)
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_NEGATED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=ge1:Clone()
        ge2:SetCode(EVENT_CHAIN_DISABLED)
        Duel.RegisterEffect(ge2,0)
    end)
end

s.listed_series={SET_KEGAI}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
    if re:IsHasCategory(CATEGORY_SUMMON) or re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then return end
    if rp==tp and de and dp~=tp then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
    end
end

function s.fcheck(tp,sg,fc)
    return sg:FilterCount(Card.IsControler,nil,1-tp)<=1
end

-- Extra group for ritual summoning
function s.extragroup(e,tp,mg)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
    local rg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE,nil,e,tp)
    if Duel.GetFlagEffect(tp,id)>0 and #rg>0 then
        return rg
    else return g end
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
   Duel.SendtoDeck(mat,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.matfilter(c,e,tp)
    return c:IsAbleToDeck() and (((c:IsOriginalType(TYPE_MONSTER)) and (c:IsLocation(LOCATION_ONFIELD) or c:IsLocation(LOCATION_REMOVED) or c:IsLocation(LOCATION_GRAVE)))
    or (c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end

function s.ritcheck(e,tp,g,sc)
    return #g>=1 and s.fcheck(tp,g,sc)
end

function s.clcondition1(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetCurrentChain()
    return ct==0
end   


function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    local diff=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
    if diff>=1 then
        --cannot disable
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_FIELD)
        e0:SetRange(LOCATION_ALL)
        e0:SetValue(s.cnvalue)
        e0:SetCode(EFFECT_CANNOT_DISEFFECT)
        e0:SetReset(RESET_CHAIN)
        c:RegisterEffect(e0)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetRange(LOCATION_ALL)
        e1:SetCode(EFFECT_CANNOT_DISABLE)
        e1:SetReset(RESET_CHAIN)
        c:RegisterEffect(e1)
    end
end
function s.target(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local diff=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit end
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_ONFIELD)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
        if diff>=2 then
            Duel.SetChainLimit(s.chlimit)
        end
    end
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
function s.operation(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local diff=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if rit then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
        end
    end
end
function s.cnvalue(e,ct)
    return Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT):GetHandler()==e:GetHandler()
end







function s.target2(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local diff=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit end
        Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_ONFIELD)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
        if diff>=2 then
            Duel.SetChainLimit(s.chlimit)
        end
        if diff>=3 then
            local ng=Group.CreateGroup()
            for i=1,ev do
                local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
                if tgp~=tp and Duel.IsChainNegatable(i) then
                    local tc=te:GetHandler()
                    ng:AddCard(tc)
                end
            end
            Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0)
        end
    end
end
function s.operation2(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local diff=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if rit then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
        end
        if diff>=3 then
            local dg=Group.CreateGroup()
            for i=1,ev do
                local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
                if tgp~=tp then 
                    Duel.NegateActivation(i)
                end
            end
        end
    end
end