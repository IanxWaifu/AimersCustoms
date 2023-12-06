--Scripted by IanxWaifu
--Voltaic Vanguard, Rovarik
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--special summon faceup
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SSET)
    c:RegisterEffect(e2)
    --special summon faceup
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SSET)
    c:RegisterEffect(e4)
    --Same Column Destroy
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CHANGE_POS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,1})
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.cgcon)
	e5:SetTarget(s.cgtg)
	e5:SetOperation(s.cgop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetCondition(s.cgcon2)
    c:RegisterEffect(e6)
    --destroy replace
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_DESTROY_REPLACE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTarget(s.reptg)
	e7:SetOperation(s.repop)
	e7:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e7)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHANGE_POS)
		ge1:SetCondition(s.gtg_cd)
		ge1:SetTarget(s.gtg_tg)
		ge1:SetOperation(s.gtg_op)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetCondition(s.gtg_cd)
		ge2:SetTarget(s.gtg_tg)
		ge2:SetOperation(s.gtg_op)
		Duel.RegisterEffect(ge2,0)
	end)
end
 
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC}


function s.spcfilter(c, tp)
    return c:IsSetCard(SET_VOLTAIC) and c:IsOriginalType(TYPE_MONSTER) and ((not ((c:GetPreviousPosition() & POS_FACEUP) == 0)) and c:IsFacedown()) and c:IsControler(tp)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local combinedPositions = 0
    local g = eg:Filter(s.spcfilter, nil, tp)
   
    for card in aux.Next(g) do
        local prevPos = card:GetPreviousPosition()
        
        if prevPos & POS_FACEUP > 0 then
            if card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | POS_FACEUP_ATTACK
            elseif not card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | card:GetPreviousPosition()
            end
        elseif prevPos & POS_FACEDOWN > 0 then
            if card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | POS_FACEDOWN_DEFENSE
            elseif not card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | card:GetPreviousPosition()
            end
        end
    end

    e:SetLabel(combinedPositions)
    return combinedPositions ~= 0
end


function s.spcfilter2(c, tp)
    return c:IsSetCard(SET_VOLTAIC) and c:IsOriginalType(TYPE_MONSTER) and ((not ((c:GetPreviousPosition() & POS_FACEDOWN) == 0)) and c:IsFaceup()) and c:IsControler(tp)
end

function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
    local combinedPositions = 0
    local g = eg:Filter(s.spcfilter2, nil, tp)
   
    for card in aux.Next(g) do
        local prevPos = card:GetPreviousPosition()
        
        if prevPos & POS_FACEUP > 0 then
            if card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | POS_FACEUP_ATTACK
            elseif not card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | POS_FACEUP_DEFENSE
            end
        elseif prevPos & POS_FACEDOWN > 0 then
            if card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | POS_FACEDOWN_DEFENSE
            elseif not card:IsLocation(LOCATION_PZONE) then
                combinedPositions = combinedPositions | POS_FACEDOWN_DEFENSE
            end
        end
    end

    e:SetLabel(combinedPositions)
    return combinedPositions ~= 0
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, e:GetLabel())
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, LOCATION_HAND)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, e:GetLabel())
    end
end

function s.cgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not ((c:GetPreviousPosition() & POS_FACEDOWN) == 0)) and c:IsFaceup()
end
function s.cgcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPosition(POS_FACEUP)
end
function s.cgfilter(c,g)
	return g:IsContains(c)
end
function s.cgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=e:GetHandler():GetColumnGroup()
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,cg)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.cgop(e,tp,eg,ep,ev,re,r,rp)
	local cg=e:GetHandler():GetColumnGroup()
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.cgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,cg)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end


--crazy facedown effect procing
function s.checkfilter(c)
	return c:IsOriginalCode(id) and c:IsFacedown() and c:IsLocation(LOCATION_MZONE)
end
function s.gtg_cd(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.checkfilter,1,nil,id) 
end
function s.gtg_op(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.checkfilter,nil,id)
	local c=g:GetFirst()
	local p=c:GetControler()
	if Duel.GetFlagEffect(p,999555)>0 then return end
	while c do
		if not Duel.CheckLocation(p,LOCATION_PZONE,0) and not Duel.CheckLocation(p,LOCATION_PZONE,1) then return end
		    local e1=Effect.CreateEffect(c)
		    e1:SetType(EFFECT_TYPE_QUICK_O)
		    e1:SetCode(EVENT_FREE_CHAIN)
		    e1:SetHintTiming(TIMINGS_CHECK_MONSTER_E,TIMINGS_CHECK_MONSTER_E)
		    e1:SetCountLimit(1)
		    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		    e1:SetRange(LOCATION_MZONE)
		    e1:SetLabelObject(c)
		    e1:SetCondition(s.facon)
		    e1:SetOperation(s.faop)
		    c:RegisterEffect(e1)
		    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		break
	end
	c=g:GetNext()
end


function s.facon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffect(id)~=0
end
function s.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local tep=tc:GetControler()
    tc:RegisterFlagEffect(999555,RESET_PHASE+PHASE_END,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        Duel.BreakEffect()
        tc:ResetFlagEffect(id)
    end
    e:Reset()
end



function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(SET_VOLTAIC) and not c:IsForbidden()
end
function s.gtg_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end

--destroy replace

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(SET_VOLTAIC) and not c:IsReason(REASON_REPLACE) 
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsDisabled() then return false end
	if chk==0 then return c:IsCanTurnSet() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_EFFECT+REASON_REPLACE,tp,tp,0)
	Duel.RaiseEvent(e:GetHandler(),EVENT_MSET,e,REASON_EFFECT+REASON_REPLACE,tp,tp,0)
end