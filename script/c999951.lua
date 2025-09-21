--Kyoshin’s Divination
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
    location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,
    forcedselection=s.ritcheck}
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
    return (c:IsSetCard({SET_KEGAI,SET_KYOSHIN}) and (loc&(LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND))~=0)
        or (c:IsLevel(7) and (loc&(LOCATION_GRAVE|LOCATION_HAND))~=0)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
    return g
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.matfilter(c)
    return c:IsMonster() and c:IsSetCard({SET_KEGAI,SET_KYOSHIN}) and not c:IsForbidden()
end
function s.ritcheck(e,tp,g,sc)
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    -- If this Ritual Spell is activating from the hand/stzone (occupies a zone)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_HAND) then
        ft=ft-1
    end
    return #g>=1 and aux.dncheck(g) and #g<=ft
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if #mat==0 then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<=0 then return end
    if #mat>ft then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        mat=mat:Select(tp,ft,ft,nil)
    end
    for tg in mat:Iter() do
        if Duel.MoveToField(tg,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tg:IsMonsterCard()) then
            -- Treat it as a Continuous Spell
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
            tg:RegisterEffect(e1)
        end
    end
    --Register Flag to allow 1 material from your Deck for the Fusion Summon
    if tc:IsSetCard({SET_KEGAI,SET_KYOSHIN}) then 
        e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
    end
end

--Fusion Summon
function s.fcheck(tp,sg,fc)
    return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
    if e:GetHandler():HasFlagEffect(id) then
        local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
        if eg and #eg>0 then
            return eg,s.fcheck
        end
    end
    return nil
end
function s.exfilter(c)
    return c:IsMonster() and c:IsSetCard({SET_KEGAI,SET_KYOSHIN}) and c:IsAbleToGrave()
end
function s.fusextratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end 

--Actual Ritual Summon+Fusion Combination
function s.target(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK)
    end
end

function s.operation(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if rittg(e,tp,eg,ep,ev,re,r,rp,0) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
            local fparams={handler=c,filter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),extrafil=s.fextra,extratg=s.fusextratg}
            if not (Fusion.SummonEffTG(fparams)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
            Duel.BreakEffect()
            Fusion.SummonEffOP(fparams)(e,tp,eg,ep,ev,re,r,rp)
        end
    end
end
