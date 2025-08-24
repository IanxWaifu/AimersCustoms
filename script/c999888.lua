--Shakudo ni Mebuku Kegaima
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Destroyed/Banished
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thspcon)
    e2:SetTarget(s.thsptg)
    e2:SetOperation(s.thspop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e3)
    --During the Turn---
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetRange(LOCATION_FZONE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(s.ritspcon)
    e4:SetTarget(s.ritsptg)
    e4:SetOperation(s.ritspop)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e5)
    --Register destruction of monsters
    aux.GlobalCheck(s,function()
        s[0]=0
        s[1]=0
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_DESTROYED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=ge1:Clone()
        ge2:SetCode(EVENT_REMOVE)
        Duel.RegisterEffect(ge2,0)
        aux.AddValuesReset(function()
            s[0]=0
            s[1]=0
        end)
    end)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}


function s.checkfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsOriginalType(TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER) and c:IsPreviousControler(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if s.checkfilter(tc,0) then
            local p=tc:GetPreviousControler()
            s[p]=s[p]+1
            -- Apply flag that resets at end phase
            tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
        end
        tc=eg:GetNext()
    end
end


function s.cfilter(c,tp)
    return c:IsSetCard(SET_KEGAI) and c:IsMonster() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.cfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
            --Treat it as a Continuous Spell
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

function s.thspfilter(c,e,tp,ft)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) 
        and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsCanBeEffectTarget(e) and c:IsFaceup() and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsMonster()))
end
function s.onfilter(c)
    return c:IsFaceup() and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_SYNCHRO)) and c:IsMonster() and c:IsSetCard(SET_KEGAI)
end
function s.thspcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.thspfilter,1,nil,e,tp,ft) and Duel.IsExistingMatchingCard(s.onfilter,tp,LOCATION_MZONE,0,1,nil)
end


function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chkc then return eg:IsContains(chkc) and s.thspfilter(chkc,e,tp,ft) end
    if chk==0 then return eg:IsExists(s.thspfilter,1,nil,e,tp,ft) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=eg:FilterSelect(tp,aux.NecroValleyFilter(s.thspfilter),1,1,nil,e,tp,ft)
    Duel.SetTargetCard(g)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    aux.ToHandOrElse(tc,tp,
        function()
            return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
        end,
        function()
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end,
        aux.Stringid(id,3) --"Special Summon it"
    )
end


function s.ritspfilter(c)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsOriginalType(TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER)
end

function s.ritspcon(e,tp,eg,ep,ev,re,r,rp)
    return s[tp]>0 and eg:IsExists(s.ritspfilter,1,nil)
end

function s.ritspfilter2(c,e,tp)
    return c:IsType(TYPE_RITUAL) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetFlagEffect(id)>0
end
function s.ritsptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.ritspfilter2,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.ritspop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ct<=0 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ritspfilter2),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,ct,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end