--Scripted by IanxWaifu
--Dragonic Icyene Chains
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	Aimer.AddPersistentProcedure(c,1,s.filter,CATEGORY_DISABLE,EFFECT_FLAG_NO_TURN_RESET,nil,0x1c0,s.condition,nil,s.target,nil,nil,1,true,id,s.desrule)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e0)
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e2)
	--Place Counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	--Add counter2
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.addop2)
	c:RegisterEffect(e4)
end

s.listed_series={SET_ICYENE,SET_DRAGOCYENE}
s.counter_list={COUNTER_ICE}

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DRAGOCYENE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.filter(c)
	return c:IsFaceup() and c:IsNegatable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end

--DestroyRule
function s.desrule(e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	--Destroy this card during your 3rd Standby Phase after activation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetOperation(s.sdesop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		Duel.Destroy(c,REASON_RULE)
	end
end

--Place Counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_ICE,1)
end

function s.addop2(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	for c in aux.Next(eg) do
		if not c:IsCode(id) and c:IsLocation(LOCATION_ONFIELD) then
			count=count+c:GetCounter(COUNTER_ICE)
		end
	end
	if count>0 then
		e:GetHandler():AddCounter(COUNTER_ICE,count)
	end
end