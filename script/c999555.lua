--Scripted by IanxWaifu
--Voldragocyene, The Voltaicumulonimbus
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Aimer.VoltaicSynchroAddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Aimer.VoltaicSynchroAddProcedure(c,aux.FilterBoolFunctionEx(s.sfilter),2,99,Synchro.NonTuner(nil),1,99)
	--Negate effects during the turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e1:SetCode(EVENT_CHANGE_POS)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetRange(LOCATION_ONFIELD)
    e1:SetCondition(s.scondition1)
    e1:SetOperation(s.dirop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.scondition2)
    e2:SetOperation(s.dirop)
    c:RegisterEffect(e2)
	-- Search "Voltaic" Spell/Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.setcon)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- Target same columns and return to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.rthtg)
	e4:SetOperation(s.rthop)
	c:RegisterEffect(e4)	
end
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC, SET_VOLDRAGO}

function s.sfilter(c,val,scard,sumtype,tp)
	return c:IsSetCard(SET_VOLTAIC,scard,sumtype,tp) or c:IsSetCard(SET_VOLDRAGO,scard,sumtype,tp)
end

function s.scondition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not ((c:GetPreviousPosition() & POS_FACEDOWN) == 0)) and c:IsFaceup()
end
function s.scondition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end

function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--cannot activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,0),nil)
end
function s.disfilter(c)
	return c:IsSpellTrap() or c:IsMonster()
end
function s.distg(e,re,tp)
	local tc=re:GetHandler()
	local cc=e:GetHandler():GetColumnGroup()
	local cg=cc:Match(s.disfilter,nil,tp)
	return cg and cc:IsContains(tc)
end


function s.checkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VOLTAIC)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then
		return false
	end
	local tc=re:GetHandler()
	local cc=e:GetHandler():GetColumnGroup()
	local cg=cc:Match(s.disfilter,nil)
	local rc=re:GetHandler()
	local te, p, loc, seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	local act = te:GetHandler()
	if cc:IsContains(act) then return true end
	return false
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

-- Set to field
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsDisabled()
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_COST,tp,tp,0)
end
function s.setfilter(c)
	return (c:IsSetCard(SET_VOLTAIC) or c:IsSetCard(SET_VOLDRAGO)) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end


function s.rthfilter(c,e)
	return Aimer.VoltaicSameColumns(e,c) and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,0,LOCATION_ONFIELD,1,nil,e) end
	local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,0,LOCATION_ONFIELD,1,ct,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
