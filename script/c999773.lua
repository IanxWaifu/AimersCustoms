--Azhimaou - Lascarmin
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixRep(c,true,true,s.ffilter,1,99,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_AZHIMAOU))
    --Disable
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    -- Send replace effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_SEND_REPLACE)
    e2:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    e2:SetCondition(s.repcon)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    c:RegisterEffect(e2)
end

--Fusion Materials
function s.ffilter(c,fc,sumtype,sub,mg,sg)
    return (c:IsMonster() and c:IsType(TYPE_RITUAL|TYPE_SYNCHRO,fc,sumtype,fc:GetControler())) and c:GetCode(fc,sumtype,fc:GetControler())>0 and (not sg or #sg>0 and not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,fc:GetControler()),fc,sumtype,fc:GetControler()))
end
function s.fusfilter(c,code,fc,sumtype,sub1,sub2)
    return c:IsSummonCode(fc,sumtype,fc:GetControler(),code) 
end


-- Condition: Check if the monster was Fusion Summoned
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- Filter for valid targets (must be face-up, not disabled, and can be targeted)
function s.negtgfilter(c)
    return c:IsNegatable()
end

-- Targeting function: Select cards to DISABLE based on Fusion materials
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local tg=Duel.GetMatchingGroup(s.negtgfilter,tp,0,LOCATION_ONFIELD,nil)
    local count=0
    local mat=c:GetMaterial()
    -- Count Ritual/Synchro monsters used for Fusion Summon
    for tc in aux.Next(mat) do
        if tc:IsType(TYPE_RITUAL) or tc:IsType(TYPE_SYNCHRO) then
            count=count+1
        end
    end
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.negtgfilter(chkc) end
    if chk==0 then return #tg>0 and count>0 and Duel.IsExistingTarget(s.negtgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    local trg=Duel.SelectTarget(tp,s.negtgfilter,tp,0,LOCATION_ONFIELD,1,count,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,trg,count,0,0)
end

-- Negation operation: DISABLE the effects of the targeted cards
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetTargetCards(e)
    for tc in aux.Next(g) do
        if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
            if tc:IsType(TYPE_TRAPMONSTER) then
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e3)
            end
        end
    end
end




function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsAbleToDeckOrExtraAsCost() 
end


function s.spcfilter(c,tp)
    if c:GetControler()==1-tp or not (c:IsSetCard(SET_AZHIMAOU)) or not (c:IsRitualMonster() or c:IsType(TYPE_SYNCHRO)) then return false end
    if Duel.GetFlagEffect(tp,id)==0 and (c:IsRitualMonster() or c:IsType(TYPE_SYNCHRO)) and c:IsSetCard(SET_AZHIMAOU) then
        return true
    end
    return false
end


function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if not c:IsFaceup() and not c:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) then return false end
    if chk==0 then return eg:IsExists(s.spcfilter,1,nil,tp) and c:IsAbleToDeckOrExtraAsCost() end
    if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_CARD,0,id)
        local g=eg:Filter(s.spcfilter,nil,tp) 
        for tc in g:Iter() do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(4) 
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
        Duel.SendtoDeck(c,nil,2,REASON_REPLACE+REASON_COST)
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        return true
    else return false end
end

function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repfilter(c,tp)
    return c:IsSetCard(SET_AZHIMAOU) and (c:IsRitualMonster() or c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
end
