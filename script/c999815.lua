--Novalxon Accretion
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    --Special Summon 1 "Novalxon" monster from your hand or banishment
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)
    --Search when an Astral Shift is performed
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_ASTRAL_SHIFT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.astralcon)
    e3:SetTarget(s.applytg)
    e3:SetOperation(s.applyop)
    c:RegisterEffect(e3)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_NOVALXON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        -- Check if there are leftmost or rightmost zones available
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
            and (Duel.CheckLocation(tp,LOCATION_MZONE,0) or Duel.CheckLocation(tp,LOCATION_MZONE,4))
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end

--Special
function s.seqfilter(c)
    local tp=c:GetControler()
    return c:IsFaceup() and c:GetSequence()<7 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local zone=0
    -- Check if leftmost zone is available
    if Duel.CheckLocation(tp,LOCATION_MZONE,0) then zone=zone|0x1 end
    -- Check if rightmost zone is available
    if Duel.CheckLocation(tp,LOCATION_MZONE,4) then zone=zone|0x10 end
    if zone==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
    local zg=Duel.GetMatchingGroup(s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,g:GetFirst())
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)~=0 and #zg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local tc=zg:Select(tp,1,1,nil):GetFirst()
        local p1,p2,i
        if tc:IsControler(tp) then
            i=0
            p1=LOCATION_MZONE
            p2=0
        else
            i=16
            p2=LOCATION_MZONE
            p1=0
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
    end
end

--Astral Event
function s.cfilter(c,tp)
    return c:IsControler(tp)
end
function s.astralcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

--Draw
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)==0 end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)>0 then return end
    Duel.Draw(tp,1,REASON_EFFECT)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

--Set from Deck
function s.setfilter(c)
    return c:IsSetCard(SET_NOVALXON) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id+1)==0 end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id+1)>0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g)
    end
    Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
end

function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
    local draw=s.drtg(e,tp,eg,ep,ev,re,r,rp,0)
    local set=s.settg(e,tp,eg,ep,ev,re,r,rp,0)
    if chk==0 then return draw or set end
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local draw=s.drtg(e,tp,eg,ep,ev,re,r,rp,0)
    local set=s.settg(e,tp,eg,ep,ev,re,r,rp,0)
    local op=-1
    if draw and set then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif draw then
        op=0
    elseif set then
        op=1
    end
    if op==0 then
        s.drop(e,tp,eg,ep,ev,re,r,rp)
    elseif op==1 then
        s.setop(e,tp,eg,ep,ev,re,r,rp)
    end
end
