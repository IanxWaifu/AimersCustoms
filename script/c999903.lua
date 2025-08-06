--Kegai - Hakuryü Aratame
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    Aimer.KegaiAddSynchroMaterialEffect(c)
	--synchro summon
	Aimer.KegaiSynchroAddProcedure(c,nil,1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_RITUAL),1,1)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	local rparams={filter=aux.FilterBoolFunction(Card.IsSetCard,SET_KEGAI),lvtype=RITPROC_GREATER,
    filter=aux.FilterBoolFunction(Card.IsSetCard,SET_KEGAI),
    extrafil=s.extragroup,
    extraop=s.extraop,
    matfilter=s.matfilter,
    location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,
    forcedselection=s.ritcheck,
    extratg=s.extratg}
	--indes
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(function(e)
        local g=Duel.GetMatchingGroup(s.statfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
        local stat=g:GetClassCount(Card.GetCode)*-100
        return stat end)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(function(e,tp,eg,ep,ev,re) return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev) end)
    e3:SetTarget(s.target(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e3:SetOperation(s.operation(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e3)
end

function s.statfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_KEGAI) and c:IsOriginalType(TYPE_MONSTER)
end

-- Extra group for ritual summoning
function s.extragroup(e,tp,mg)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,e,tp)
    	if #g>0 then return g
    end
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
   Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,tp,LOCATION_MZONE)
end

function s.matfilter(c,e,tp)
    return c:IsAbleToRemove() and c==e:GetHandler()
end

function s.ritcheck(e,tp,g,sc)
    local c=e:GetHandler()
    return #g==1 and g:GetFirst()==c and s.fcheck(tp,g,sc)
end

function s.fcheck(tp,sg,fc)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
end

function s.disfilter(c,tp)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:GetSummonPlayer()==tp and not c:IsDisabled()
end
function s.target(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit and eg:IsExists(s.disfilter,1,nil,1-tp) end
        Duel.SetTargetCard(eg)
        local g=eg:Filter(s.disfilter,nil,1-tp)
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,tp,LOCATION_MZONE)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
    end
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
function s.operation(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        local gpt=Duel.GetTargetCards(e)
        if rit then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
            Duel.BreakEffect()
            for neg in aux.Next(gpt) do
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                neg:RegisterEffect(e1,true)
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                neg:RegisterEffect(e2,true) 
            end
        end
    end
end