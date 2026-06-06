--Kyoshin Punity
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
    local rparams={handler=c,
    lvtype=RITPROC_GREATER,
    filter=s.rspfilter,
    extrafil=s.extragroup,
    extraop=s.extraop,
    matfilter=s.matfilter,
    location=LOCATION_HAND|LOCATION_DECK|LOCATION_STZONE,
    forcedselection=s.ritcheck}
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.actcost)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e1:SetOperation(s.operation(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e1)
    -- Activity Counter for Special Summons
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.spsumfilter)
end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}
s.ritualmatidlist=
{   [68295149] = true,
    [87054946] = true,
    [73898890] = true}

--Limit Check
function s.spsumfilter(c)
    if not c:IsSummonLocation(LOCATION_EXTRA) then return true end
    local mt=c:GetMetatable()
    return c:IsSetCard(SET_KYOSHIN) or (mt and mt.ritual_material_required and mt.ritual_material_required>=1)
end

-- Cost
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    -- Extra Deck Restriction
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
end

function s.splimit(e,c)
    if not c:IsLocation(LOCATION_EXTRA) then return false end
    local mt=c:GetMetatable()
    local code=c:GetCode()
    return not (c:IsSetCard(SET_KYOSHIN) or (mt and mt.ritual_material_required and mt.ritual_material_required>=1) or s.ritualmatidlist[code])
end

--Ritual Summon
function s.rspfilter(c)
    local loc=c:GetLocation()
    return c:IsSetCard(SET_KYOSHIN)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
    return g
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.matfilter(c)
    return c:IsOriginalType(TYPE_MONSTER) and --[[c:IsSetCard(SET_KYOSHIN) and--]] c:HasLevel()
end
function s.ritcheck(e,tp,g,sc)
    return #g>=1
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if #mat==0 then return end
    Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    --Register Flag to allow 1 material from your Deck for the Fusion Summon
    if tc:IsSetCard(SET_KYOSHIN) then 
        e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
    end
end

--Fusion Summon
function s.fextra(e,tp,mg)
    local eg=Group.CreateGroup()
    if Duel.IsPlayerAffectedByEffect(tp,999960) then
        local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
        if #sg>0 then eg:Merge(sg) end
    end
    if #eg>0 then return eg end
    return nil
end

function s.fusextratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_STZONE)
end 

function s.exfilter(c)
    return (c:IsMonster() or c:IsOriginalType(TYPE_MONSTER)) and c:IsSetCard(SET_KYOSHIN) and c:IsAbleToGrave() and c:HasLevel()
end

--Actual Ritual Summon+Fusion Combination
function s.target(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
    end
end

function s.operation(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if rittg(e,tp,eg,ep,ev,re,r,rp,0) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
            local fparams={handler=c,filter=aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),extrafil=s.fextra,extratg=s.fusextratg}
            if not (Fusion.SummonEffTG(fparams)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
            Duel.BreakEffect()
            Fusion.SummonEffOP(fparams)(e,tp,eg,ep,ev,re,r,rp)
        end
    end
end
