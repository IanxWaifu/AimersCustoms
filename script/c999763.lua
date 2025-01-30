--Azhimaou - Archdaemon Velitrus
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Register Custom Event upon Level Adjustment
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e0:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK)
    e0:SetCode(EVENT_ADJUST)
    e0:SetOperation(s.regop)
    c:RegisterEffect(e0)
    --Allows Negative Levels
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ALLOW_NEGATIVE)
    c:RegisterEffect(e1)
    --Destroy itself upon Custom Event
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CUSTOM+id)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_DECK)
    e2:SetCountLimit(1)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    --Labeled effect coinciding with Self Destruction
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.retcon)
    e3:SetLabelObject(e2)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    --Disable
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3))
    e6:SetCategory(CATEGORY_REMOVE)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_DESTROYED)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1,id)
    e6:SetCondition(s.negcon)
    e6:SetTarget(s.negtg)
    e6:SetOperation(s.negop)
    c:RegisterEffect(e6)
    --Lingering Application necessary to not always be active in every location. Applies during a Ritual Summon to place Flags on the materials, and applies the lingering Effect.
    --Refer to further in script--
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    e7:SetCondition(s.sregcon)
    e7:SetOperation(s.sregop)
    c:RegisterEffect(e7)
    --material check for activ cost
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE)
    e8:SetCode(EFFECT_MATERIAL_CHECK)
    e8:SetValue(s.valcheck)
    e8:SetLabelObject(e7)
    c:RegisterEffect(e8)
end

--Raise Custom Event
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetLevel()>0 then return end
    if c:GetLevel()<=0 and ((c:IsLocation(LOCATION_HAND)) or (c:IsLocation(LOCATION_DECK)) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())) then
        Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
    end
end


function s.valchkfilter(c,e,tp)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsSpellTrap()
end
function s.valcheck(e,c)
    local g=c:GetMaterial()
    local ct=g:Filter(s.valchkfilter,nil)
    e:GetLabelObject():SetLabelObject(ct)
    for tc in aux.Next(ct) do
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    end
    ct:KeepAlive()
end
function s.sregcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabelObject()
end

function s.sregop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=e:GetLabelObject()
    --Activation cost
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_ACTIVATE_COST)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(0xff) 
    e4:SetTargetRange(LOCATION_SZONE,0)
    e4:SetLabelObject(ct)
    e4:SetTarget(s.actcost)
    e4:SetCost(s.costchk)
    e4:SetOperation(s.costop)
    c:RegisterEffect(e4)
end


function s.actcost(e,te,tp)
    local tc=te:GetHandler()
    if tc:GetFlagEffect(id)>0 and tc:IsLocation(LOCATION_SZONE) and tc:IsFacedown() then
        e:SetLabelObject(tc)
        return true
    end
    return false
end

function s.costchk(e,te_or_c,tp)
    local tc=e:GetLabelObject()
    local g=Duel.GetMatchingGroup(s.costopfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,tc,tp)
    return #g>0
end

-- Cost filter (modification to exclude Azhimaou Ritual if only one exists)
function s.costopfilter(c,tp)
    -- Check if it's an "Azhimaou" Ritual Monster
    if c:IsSetCard(SET_AZHIMAOU) and (c:IsRitualMonster() or c:IsType(TYPE_SYNCHRO)) then
        local azhimaouCount=Duel.GetMatchingGroupCount(s.ritfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
        if azhimaouCount==1 then
            return false
        end
    end
    return c:IsAbleToRemoveAsCost()
end

function s.ritfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and (c:IsRitualMonster() or c:IsType(TYPE_SYNCHRO))
end

function s.costop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    local g=Duel.GetMatchingGroup(s.costopfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_ONFIELD,0,tc,tp)
    if tc and #g>1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g:Select(tp,2,2,nil)
        Duel.HintSelection(sg)
        Duel.Remove(sg,POS_FACEUP,REASON_COST)
        tc:ResetFlagEffect(id) 
    end
end


--Self Destroy upon Custom Event
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_RULE)
end

--Special Summon upon Self Destruction
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_TUNER)
end
-- + Return to Deck
function s.tdfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToDeck()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.DisableShuffleCheck()
    if #g<=0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
    if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local tg=dg:Select(tp,1,1,nil)
        Duel.HintSelection(tg,true)
        local tc=tg:GetFirst()
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_CHAIN_END)
        e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetCountLimit(1)
        e1:SetLabelObject(tc)
        e1:SetOperation(s.tdop)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:GetFlagEffect(id)>0 then
        Duel.DisableShuffleCheck()
        tc:ResetFlagEffect(id)
        Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler()==e:GetHandler() and Duel.GetFlagEffect(tp,id)==0
end

--Draw 1 card when an "Azhimaou" makes a card leave the field
function s.negfilter(c)
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==tp and eg:IsExists(s.negfilter,1,nil) and re and re:GetHandler():IsSetCard(SET_AZHIMAOU)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,1)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
