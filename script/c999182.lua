-- Dragonic Released Zurieyna
-- Scripted by IanxWaifu
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	--Unaffected by Opponent Card Effects
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(s.uncon)
	e2:SetValue(s.unval)
	c:RegisterEffect(e2)
	--pendulum summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.pencon)
	e3:SetCost(s.pencost)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
function s.uncon(e)
	local tp=e:GetHandler():GetControler()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not tc1 or not tc2 then return false end
	return tc1:GetLeftScale()==tc2:GetRightScale()
end
function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end

--PendSummon
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.spfilter(c,e,tp,lsc,rsc)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false) and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and c:GetLevel()>lsc and c:GetLevel()<rsc
end
function s.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local lsc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
		local rsc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if not (lsc and rsc) then return false end
		lsc=lsc:GetLeftScale()
		rsc=rsc:GetRightScale()
		if lsc>rsc then lsc,rsc=rsc,lsc end
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,nil,e,tp,lsc,rsc)
		if e:GetLabel()==100 then return aux.SelectUnselectGroup(sg,e,tp,2,2,s.spcheck,0) end
		return Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_HAND)
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local lsc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rsc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (lsc and rsc) then return end
	lsc=lsc:GetLeftScale()
	rsc=rsc:GetRightScale()
	if lsc>rsc then lsc,rsc=rsc,lsc end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,nil,e,tp,lsc,rsc)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #sg~=2 or #dg<2 then return end
		if Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)
	end
end
