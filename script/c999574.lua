--Scripted by IanxWaifu
--Voltaic Sentinel, Faisal
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	--[[Aimer.VoltaicSynchroAddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)--]]
	Aimer.VoltaicSynchroAddProcedure(c,aux.FilterBoolFunctionEx(s.sfilter),1,1,Synchro.NonTuner(nil),1,99)
	--Negate Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.cgcon)
	e1:SetTarget(s.cgtg)
	e1:SetOperation(s.cgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.cgcon2)
    c:RegisterEffect(e2)
	--Draw 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.drcon)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	local e10=e3:Clone()
	e10:SetType(EFFECT_TYPE_QUICK_O)
	e10:SetCode(EVENT_FREE_CHAIN)
	e10:SetCondition(s.mqecon3)
	e10:SetCost(s.drcost2)
	c:RegisterEffect(e10)
	--Negate Spell/Trap
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
		ge2:SetCode(EVENT_MOVE)
		ge2:SetCondition(s.gtg_cd)
		ge2:SetTarget(s.gtg_tg)
		ge2:SetOperation(s.gtg_op)
		Duel.RegisterEffect(ge2,0)
	end)		
end
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC, SET_VOLDRAGO}

function s.sfilter(c,val,scard,sumtype,tp)
	return c:IsSetCard(SET_VOLTAIC,scard,sumtype,tp) or c:IsSetCard(SET_VOLDRAGO,scard,sumtype,tp)
end

function s.cgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not ((c:GetPreviousPosition() & POS_FACEDOWN) == 0)) and c:IsFaceup()
end
function s.cgcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.cgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.cgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end


-- Cost for Quicks
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) and c:IsFaceup() and c:IsDisabled()
end

function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_COST,tp,tp,0)
end
function s.drcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_COST,tp,tp,0)
	Duel.RegisterFlagEffect(tp,999563,RESET_EVENT+RESET_PHASE+PHASE_END,0,0)
end
function s.mqecon3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsDisabled() and Duel.IsPlayerAffectedByEffect(tp,VOLTAICMONQ) and ((Duel.IsMainPhase() and Duel.GetCurrentChain(true)>=0) or not (Duel.IsMainPhase()) or (Duel.IsTurnPlayer(1-tp)))
	and Duel.GetFlagEffect(tp,999563)==0
end

--Draw 1 Card
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
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
    if not c then return end
    local p=c:GetControler()
    if Duel.GetFlagEffect(p,999575)>0 then return end
    local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsNegatableSpellTrap),p,LOCATION_SZONE,LOCATION_SZONE,nil)
    if #sg==0 then return end
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetHintTiming(TIMINGS_CHECK_MONSTER_E,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,{id,2})
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetLabelObject(c)
    e1:SetCondition(s.facon)
    e1:SetOperation(s.faop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_CHANGE_POS)
    c:RegisterEffect(e2)
    c:RegisterFlagEffect(id,0,0,1)
end


function s.facon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffect(id)~=0 and tc:IsLocation(LOCATION_MZONE) and eg:IsContains(e:GetHandler()) and tc:IsFacedown()
end

function s.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local tep=tc:GetControler()
    tc:RegisterFlagEffect(999575,RESET_PHASE+PHASE_END,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsNegatableSpellTrap),tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local dc=sg:Select(tp,1,1,nil):GetFirst()
		if not dc then return end
		Duel.HintSelection(dc,true)
		Duel.BreakEffect()
		Duel.NegateRelatedChain(dc,RESET_TURN_SET)
		--Negate its effects
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		dc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		dc:RegisterEffect(e2)
        Duel.BreakEffect()
        tc:ResetFlagEffect(id)
    end
    e:Reset()
end


function s.gtg_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsNegatableSpellTrap),tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if chk==0 then return #sg>0 end
end




