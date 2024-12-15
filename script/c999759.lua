--Azhimaou - Sybaris
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
    e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
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
    return c:IsTrap() and c:IsSetCard(SET_AZHIMAOU) and c:IsControler(tp) and c:IsPreviousPosition(POS_FACEUP)
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
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        --Banish it when it leaves the field
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
        c:RegisterEffect(e1,true)
    end
end


function s.tgfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsRitualMonster() and c:IsFaceup()
end
function s.setfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsQuickPlaySpell() and c:IsSSetable()
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
            e2:SetLabel(tc:GetCode())
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

-- Cost check and operation logic based on card ID
function s.costchk(e,te_or_c,tp)
    local tc=e:GetLabelObject()
    local code=e:GetLabel()
    if code==999751 then
        return Duel.CheckLPCost(tp,500)
    elseif code==999762 or code==999763 then
        local g=Duel.GetMatchingGroup(s.costopfilter,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE,0,tc,tp,code)
        return #g>0
    end
    return false
end

function s.costop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    local code=e:GetLabel()
    if code==999751 then
        if tc:GetFlagEffect(id)>0 then
            Duel.PayLPCost(tp,500)
            tc:ResetFlagEffect(id)
        end
    elseif code==999762 then
        local g=Duel.GetMatchingGroup(s.costopfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,tc,tp,code)
        if tc and #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local sg=g:Select(tp,1,1,nil)
            Duel.HintSelection(sg)
            Duel.SendtoGrave(sg,REASON_COST)
            tc:ResetFlagEffect(id)
        end
    elseif code==999763 then
        local g=Duel.GetMatchingGroup(s.costopfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_ONFIELD,0,tc,tp,code)
        if tc and #g>1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=g:Select(tp,2,2,nil)
            Duel.HintSelection(sg)
            Duel.Remove(sg,POS_FACEUP,REASON_COST)
            tc:ResetFlagEffect(id)
        end
    end
end

-- Common cost filter with id-based check
function s.costopfilter(c,tp,code)
    if c:IsSetCard(SET_AZHIMAOU) and (c:IsRitualMonster() or c:IsType(TYPE_SYNCHRO)) then
        local azhimaouCount=Duel.GetMatchingGroupCount(s.ritfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
        if azhimaouCount==1 then
            return false
        end
    end
    if code==999762 then
        return c:IsAbleToGraveAsCost()
    elseif code==999763 then
        return c:IsAbleToRemoveAsCost()
    end
    return false
end

function s.ritfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and (c:IsRitualMonster() or c:IsType(TYPE_SYNCHRO))
end
