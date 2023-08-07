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
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.pencon)
	e3:SetCost(s.pencost)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	--Pen Place/Add
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.pptg)
	e4:SetOperation(s.ppop)
	c:RegisterEffect(e4)
end
s.listed_series={0x718,0x12A7,0xFA0}
s.listed_names={id,999180,999181}
s.listed_ritual_mat={999180}

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


function s.ppfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and (c:IsAbleToRemove() or c:IsDestructable(e))
end
function s.ppfilterdes(c,e)
	return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and c:IsDestructable(e)
end
function s.ppfilterrem(c)
	return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and c:IsAbleToRemove()
end
function s.thfilter(c)
	return c:IsRace(RACE_FIEND|RACE_WARRIOR|RACE_SPELLCASTER) and not c:IsForbidden() and c:IsType(TYPE_PENDULUM)
end
function s.checkfilter(c)
	return c:IsRace(RACE_FIEND|RACE_WARRIOR|RACE_SPELLCASTER) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.pptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ppfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e) and 
		((Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.CheckPendulumZones(tp)) or Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_DECK,0,1,nil)) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
function s.ppop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.ppfilterdes,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e)
	local b2=Duel.IsExistingMatchingCard(s.ppfilterrem,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil)
	local c2=Duel.CheckPendulumZones(tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else op=Duel.SelectOption(tp,aux.Stringid(id,2))+1 
		end
		e:SetLabel(op)
		if op==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tc=Duel.SelectMatchingCard(tp,s.ppfilterdes,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e)
			e:SetCategory(CATEGORY_DESTROY)
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
			if Duel.Destroy(tc,REASON_EFFECT)>0 then
				local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				local tg=g:GetFirst()
				Duel.BreakEffect()
				local c1=tg:IsAbleToHand()
				local op2=0
				if c1 and c2 then
					op2=3
				elseif c1 then
					op2=Duel.SelectOption(tp,aux.Stringid(id,3))
				else op2=Duel.SelectOption(tp,aux.Stringid(id,3))+1 end
				e:SetLabel(op2)
				if op2==3 then
				aux.ToHandOrElse(tg, tp,
				    function()
				        return not tg:IsForbidden()
				    end,
				    function()
				            Duel.MoveToField(tg, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
				    end,
				    aux.Stringid(id, 4) -- "To PZone"
				)
			elseif c1 and not c2 then 
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			else 
				Duel.MoveToField(tg, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
			end
		end
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local tc=Duel.SelectMatchingCard(tp,s.ppfilterrem,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
				e:SetCategory(CATEGORY_REMOVE)
				Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
				if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
				local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				local tg=g:GetFirst()
				Duel.BreakEffect()
				local c1=tg:IsAbleToHand()
				local op2=0
				if c1 and c2 then
					op2=3
				elseif c1 then
					op2=Duel.SelectOption(tp,aux.Stringid(id,3))
				else op2=Duel.SelectOption(tp,aux.Stringid(id,3))+1 end
				e:SetLabel(op2)
				if op2==3 then
				aux.ToHandOrElse(tg, tp,
				    function()
				        return not tg:IsForbidden()
				    end,
				    function()
				            Duel.MoveToField(tg, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
				    end,
				    aux.Stringid(id, 4) -- "To PZone"
				)
			elseif c1 and not c2 then 
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			else 
				Duel.MoveToField(tg, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
			end
		end
	end
end