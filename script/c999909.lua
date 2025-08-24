--Scripted by Aimer
--Hakuryü Shito no Seishin
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate effect: target Spell/Trap or monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)
    --Leave field effect: add card to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

--Filter for activation effect
function s.actfilter(c,e,tp,ft,sft)
    return ((sft>0 and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:CheckActivateEffect(false,false,false)~=nil) or (ft>0 and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false))) 
    and not c:IsCode(id) and c:IsSetCard({SET_KEGAI,SET_KIJIN})
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.actfilter(chkc,e,tp,ft,sft) end
    if chk==0 then return Duel.IsExistingTarget(s.actfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft,sft) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.actfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft,sft)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
   local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    if tc:IsType(TYPE_SPELL+TYPE_TRAP) then
        --Activate
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetCode(EVENT_CHAIN_END)
        e1:SetCountLimit(1)
        e1:SetLabelObject(tc)
        e1:SetOperation(s.faop)
        Duel.RegisterEffect(e1,tp)
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)
    elseif tc:IsType(TYPE_MONSTER) then
        -- Special Summon monster from GY
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local te=tc:GetActivateEffect()
    local tep=tc:GetControler()
    if not te then return end
    local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
    if pre[1] then
        for i,eff in ipairs(pre) do
            local prev=eff:GetValue()
            if type(prev)~='function' or prev(eff,te,tep) then return end
        end
    end
    if tc:GetFlagEffect(id)==0 then return false end
    if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep) then
        Duel.Activate(te)
        Duel.BreakEffect()
        tc:ResetFlagEffect(id)
    end
    e:Reset()
end




--Filter for leave-field effect
function s.thfilter(c)
    return ((c:IsSetCard({SET_KEGAI,SET_KIJIN}) and c:IsLocation(LOCATION_GRAVE)) or (c:IsType(TYPE_RITUAL) and c:IsLocation(LOCATION_DECK))) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
