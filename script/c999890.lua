--Kegai - Shinpan no Futamata
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate 1 of these effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetCost(s.effcost)
    e1:SetTarget(s.efftg)
    e1:SetOperation(s.effop)
    c:RegisterEffect(e1)
    --Add 1 "Kegai"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(Cost.SelfBanish)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}


function s.tgfilter(c)
    return c:IsSetCard(SET_KEGAI) and c:IsMonster() and not c:IsForbidden()
end
function s.desfilter(c,e)
    return c:IsSetCard(SET_KEGAI) and c:IsFaceup() and c:IsDestructable(e)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(-100)
    local c=e:GetHandler()
    local b1=nil
    if c:IsLocation(LOCATION_HAND) then b1=not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 end
    if not c:IsLocation(LOCATION_HAND) then b1=not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e)
    if chk==0 then return b1 or b2 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local cost_skip=e:GetLabel()~=-100
    local b1=(cost_skip or (not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0))
    local b2=(cost_skip or (not Duel.HasFlagEffect(tp,id+1) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e)))
    if chk==0 then e:SetLabel(0) return b1 or b2 end
    local op=Duel.SelectEffect(tp,
        {b1,aux.Stringid(id,0)},
        {b2,aux.Stringid(id,1)})
    e:SetLabel(op)
    if op==1 then
        if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
    elseif op==2 then
        e:SetCategory(CATEGORY_DESTROY)
        if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_ONFIELD)
    end
end

function s.setfilter(c)
    return c:IsSetCard(SET_KEGAI) and not c:IsCode(id) and c:IsSSetable()
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        --Special Summon 1 "Magistus" or "Witchcrafter" monster from your hand or Deck
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tgfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,1,nil):GetFirst()
        if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET)
            e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
            tc:RegisterEffect(e1)
        end
    elseif op==2 then
        --Destroy 1 "Kegai"
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local tc=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),e):GetFirst()
        if tc and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
            if #sc==0 then return end
            Duel.BreakEffect()
            Duel.SSet(tp,sc)
        end
    end
end

function s.rmfilter(c,e,tp)
    return c:IsAbleToRemove() and c:IsSetCard(SET_KEGAI) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end

function s.thfilter(c,code)
    return c:IsSetCard(SET_KEGAI) and c:IsAbleToHand() and not c:IsCode(code) and not c:IsCode(id)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
    local rc=rg:GetFirst()
    if not rc or Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)==0 or not rc:IsLocation(LOCATION_REMOVED) then return end
    local code=rc:GetCode()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
