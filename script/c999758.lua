--Azhimaou - Avernus
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.sptg)
    e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
    e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--Check if the card was activated this turn
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsCode(999750) then
		rc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,0)
	end
end
function s.chkfilter(c)
	return c:IsCode(999750) and c:GetFlagEffect(id)>0 and c:IsAbleToDeck()
end

function s.aeternummaterialcheck(card)
    local card_id = card:GetCode()
    for _, id in ipairs(aeternum_material_table) do
        if id == card_id then
            return true -- Card is in the aeternum_material_table
        end
    end
    return false -- Card is not in the aeternum_material_table
end

function s.sinfilter(c)
    return c:IsSSetable() and c:IsSetCard(SET_AZHIMAOU) and c:IsSpellTrap() and not c:IsCode(id) and (c:IsType(TYPE_QUICKPLAY) or c:IsNormalTrap()) and not s.aeternummaterialcheck(c)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsType(TYPE_RITUAL) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.sinfilter,tp,LOCATION_DECK,0,nil)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.chkfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
        and Duel.IsExistingTarget(s.chkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.chkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(s.sinfilter,tp,LOCATION_DECK,0,nil)
    local rtc=Duel.GetFirstTarget()
    if #sg<=0 or not rtc:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if not tc then return end
    Duel.ConfirmCards(1-tp,tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local ssg=sg:Select(tp,1,1,nil)
    if #ssg==0 then return end
    local tg=ssg:GetFirst()
    if Duel.SSet(tp,tg)>0 and ssg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE) then
       Duel.RaiseSingleEvent(tg,EVENT_SSET,e,REASON_EFFECT+REASON_FUSION+REASON_MATERIAL,tp,tp,0)
        --Can be activated this turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        tg:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
        tg:RegisterEffect(e2)
        tc:SetMaterial(tg)
        Duel.BreakEffect()
        if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)==0 then return end
        tc:CompleteProcedure()
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_CHAIN_END)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetCountLimit(1)
        e3:SetLabelObject(rtc)
        e3:SetOperation(s.tdop)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
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