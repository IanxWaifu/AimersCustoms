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
    location=LOCATION_HAND|LOCATION_DECK,
    forcedselection=s.ritcheck}
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e1:SetOperation(s.operation(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e1)
end

s.listed_series={SET_KEGAI}

--Ritual Summon
function s.rspfilter(c)
    local loc=c:GetLocation()
    return c:IsSetCard({SET_KEGAI,SET_KYOSHIN})
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
    return g
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.matfilter(c)
    return c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard({SET_KEGAI,SET_KYOSHIN})
end
function s.ritcheck(e,tp,g,sc)
    return #g>=1
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if #mat==0 then return end
    Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    --Register Flag to allow 1 material from your Deck for the Fusion Summon
    if tc:IsSetCard({SET_KEGAI,SET_KYOSHIN}) then 
        e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
    end
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
            local fparams={handler=c,filter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON)}
            if not (Fusion.SummonEffTG(fparams)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
            Duel.BreakEffect()
            Fusion.SummonEffOP(fparams)(e,tp,eg,ep,ev,re,r,rp)
        end
    end
end
