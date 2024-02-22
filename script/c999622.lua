--Scripted by IanxWaifu
--Deathrall Pyral Purge
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--link
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}


function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local activateLocation = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep~=tp and Duel.IsChainDisablable(ev)
		and (activateLocation==LOCATION_GRAVE or activateLocation==LOCATION_HAND)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local rc=re:GetHandler()
	local b1=Duel.IsChainDisablable(ev) and not rc:IsDisabled() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_LEGION_TOKEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b2=rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DEATHRALL),tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=nil
	if b1 and not b2 then
		op=1
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	elseif b2 and not b1 then
		op=2
		Duel.SetTargetCard(rc)
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,1-tp,rc:GetLocation())
	elseif b1 and b2 then
		op=3
		Duel.SetTargetCard(rc)
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,1-tp,rc:GetLocation())
	end
	e:SetLabel(op)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local rc=re:GetHandler()
	--Negate that effect
	if op==1 then
		Duel.NegateEffect(ev)
	--Banish that monster
	elseif op==2 then
		if rc:IsRelateToEffect(e) then
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	--Activate both, in sequence
	elseif op==3 then
		if Duel.NegateEffect(ev) then
			Duel.BreakEffect()
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	end
end


function s.lkfilter(c,mg)
	return c:IsSetCard(SET_DEATHRALL) and c:IsLinkSummonable(nil,mg)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local el={}
		local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_MONSTER),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local el={}
	local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_MONSTER),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xg=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
	local tc=xg:GetFirst()
	if tc then
		Duel.LinkSummon(tp,tc,nil,mg)
	end
end

