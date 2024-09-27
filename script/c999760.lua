--Azhimaou - Echidnaga
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    -- Special Summon from GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_DECK)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.gspcon)
    e1:SetTarget(s.gsptg)
    e1:SetOperation(s.gspop)
    c:RegisterEffect(e1)
    --Target Ritual and Set
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

end

function s.gspconfilter(c,tp)
    return c:IsSpell() and c:IsSetCard(SET_AZHIMAOU) and c:IsControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.gspconfilter,1,nil,tp)
end
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end


function s.tgfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsRitualMonster() and c:IsFaceup()
end
function s.setfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsNormalTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
        local tg=g:GetFirst()
        if #g>0 then
            Duel.SSet(tp,tg)
            tg:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            --Return it to deck if it leaves the field
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3301)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_DECKBOT)
            tg:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetCode(EFFECT_ACTIVATE_COST)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
            e2:SetRange(0xff) 
            e2:SetTargetRange(LOCATION_SZONE,0)
            e2:SetTarget(s.actcost)
            e2:SetLabelObject(tg)
            e2:SetCost(s.costchk)
            e2:SetOperation(s.costop)
            c:RegisterEffect(e2)
        end
    end
end

--Activation Cost
function s.actcost(e,te,tp)
    return te:GetHandler():GetFlagEffect(id)>0 and te:GetHandler():IsLocation(LOCATION_SZONE) and te:GetHandler():IsFacedown()
end

function s.costchk(e,te_or_c,tp)
    return Duel.CheckLPCost(tp,500)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabelObject():GetFlagEffect(id)>0 then
        Duel.PayLPCost(tp,500)
        e:GetHandler():ResetFlagEffect(id)
    end
end