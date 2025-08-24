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
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(function(e,tp,eg,ep,ev,re) return ep==1-tp and re:IsSpellTrapEffect() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end)
    e3:SetTarget(s.target(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e3:SetOperation(s.operation(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e3)
end

s.ritual_material_required=1
s.listed_names={id}
s.listed_series={SET_KEGAI}

function s.indtg(e,c)
	return c:IsType(TYPE_RITUAL)
end

-- Extra group for ritual summoning
function s.extragroup(e,tp,mg)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,e,tp)
    	if #g>0 then return g
    end
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
   Duel.Destroy(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,LOCATION_MZONE)
end

function s.matfilter(c,e,tp)
    return c:IsDestructable(e) and c==e:GetHandler()
end

function s.ritcheck(e,tp,g,sc)
    local c=e:GetHandler()
    return #g==1 and g:GetFirst()==c and s.fcheck(tp,g,sc)
end

function s.fcheck(tp,sg,fc)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
end

function s.target(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit end
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,LOCATION_MZONE)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
        Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
    end
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
function s.operation(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if rit then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
            Duel.BreakEffect()
            Duel.NegateActivation(ev)
        end
    end
end
