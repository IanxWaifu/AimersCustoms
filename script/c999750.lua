--Azhimaou - Aeternum
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Banish Draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
    aux.GlobalCheck(s,function()
        --Clear Materials from Table
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_PHASE+PHASE_END)
        ge1:SetCountLimit(1,{id,2})
        ge1:SetCondition(s.check_table)
        ge1:SetOperation(s.clear_materials)
        Duel.RegisterEffect(ge1,0)
    end)
end

aeternum_material_table = {}

-- Condition to check if the table contains IDs
function s.check_table(e,tp,eg,ep,ev,re,r,rp)
    return #aeternum_material_table > 0 -- Returns true if the table has IDs
end
function s.clear_materials(e,tp,eg,ep,ev,re,r,rp)
    aeternum_material_table = {} -- Reset the global table
end


function s.sinfilter(c)
    return c:IsSSetable() and c:IsSetCard(SET_AZHIMAOU) and c:IsSpellTrap() and not c:IsCode(id)
end
function s.spfilter(c,e,tp,lv,setct)
    local ct=c:GetLevel()//4
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft>0 and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
    return c:IsSetCard(SET_AZHIMAOU) and c:IsType(TYPE_RITUAL) and c:IsLevelAbove(4) and c:IsLevelBelow(lv) and ft>=ct and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) and setct>=ct
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.sinfilter,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND,0,nil)
    local ctg=g:GetClassCount(Card.GetCode)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.SelectUnselectGroup(g,e,tp,1,ctg,aux.dncheck,chk) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp,ctg*4+3,ctg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(s.sinfilter,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND,0,nil)
    local ctg=sg:GetClassCount(Card.GetCode)
    if #sg<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,#sg*4+3,ctg):GetFirst()
    if not tc then return end
    Duel.ConfirmCards(1-tp,tc)
    local ct=tc:GetLevel()//4
    local ssg=aux.SelectUnselectGroup(sg,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SET)
    if #ssg==0 then return end
    if Duel.SSet(tp,ssg)>0 and ssg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE) then
    if #ssg==1 then
        local trc=ssg:GetFirst()
        Duel.RaiseSingleEvent(trc,EVENT_SSET,e,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL,tp,tp,0)
    else
        Duel.RaiseEvent(ssg,EVENT_SSET,e,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL,tp,tp,0)
    end
        for stz in ssg:Iter() do
            -- Add material to global table
            table.insert(aeternum_material_table,stz:GetCode())
            --Can be activated this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,2))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            stz:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
            stz:RegisterEffect(e2)
        end
        tc:SetMaterial(ssg)
        Duel.BreakEffect()
        if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)==0 then return end
        tc:CompleteProcedure()
    end
end


--return draw
function s.tdfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg>0 then
        Duel.ConfirmCards(1-tp,tg)
        local ct=Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
        if ct>1 then Duel.SortDeckbottom(tp,tp,ct) end
        if ct==#tg then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end