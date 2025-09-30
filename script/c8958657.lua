--Scripted by Aimer
--Evilswarm Zefraboros
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	Xyz.AddProcedure(c,nil,5,3,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats,s.xyzop)
	--Apply 1 "lswarm" monster's effect that activates on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayGroup()~=0 end)
	e1:SetTarget(s.applytg)
	e1:SetOperation(s.applyop)
	c:RegisterEffect(e1)
	--Return cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rttg)
	e2:SetOperation(s.rtop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_ZEFRA,SET_LSWARM}


-- utility to safely run an effect function (condition/target)
function s.runfn(fn,eff,tp,chk)
	return not fn or fn(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,nil,REASON_EFFECT,PLAYER_NONE,chk)
end

-- filter for cards that have applicable effects
function s.applyfilter(c,e,tp)
	if not ((c:IsSetCard(SET_LSWARM) and not c:IsSetCard(SET_STEELSWARM)) and c:IsMonster() and c:IsAbleToRemove()) then return false end
	for _,eff in ipairs({c:GetOwnEffects()}) do
		if eff:GetCode()~=EFFECT_SPSUMMON_PROC and s.runfn(eff:GetCondition(),eff,tp,0) and s.runfn(eff:GetTarget(),eff,tp,0) then
			return true
		end
	end
	return false
end

-- target function: only checks that a valid card exists
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.applyfilter,tp,LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp)
	end
end

function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.applyfilter,tp,LOCATION_GRAVE|LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local effs,options = {},{}
	for _,eff in ipairs({tc:GetOwnEffects()}) do
		if s.runfn(eff:GetCondition(),eff,tp,0) and s.runfn(eff:GetTarget(),eff,tp,0) then
			table.insert(effs,eff)
			table.insert(options,{true,eff:GetDescription() or 0})
		end
	end
	if #effs==0 then return end
	local opidx = #options==1 and 1 or Duel.SelectEffect(tp,table.unpack(options))
	local te = effs[opidx]
	if not te then return end
	Duel.Hint(HINT_OPSELECTED,1-tp,te:GetDescription())
	tc:CreateEffectRelation(e)
	if tc:IsRelateToEffect(e) and tc:IsAbleToRemove() then
		Duel.BreakEffect()
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
	local targ_fn = te:GetTarget()
	if targ_fn then s.runfn(targ_fn,e,tp,1) end
	local op = te:GetOperation()
	if op then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		op(e,tp,eg,ep,ev,re,r,rp)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end




function s.cfilter(c)
	return c:IsSetCard(SET_LSWARM) and c:IsAbleToGraveAsCost()
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_LSWARM,lc,SUMMON_TYPE_XYZ,tp) and c:GetOverlayGroup()==0
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if tc then
		Duel.SendtoGrave(tc,REASON_COST)
		return true
	else return false end
end

--Check for detach
function s.mfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- check for Zefra/lswarm returnables
function s.thfilter(c)
	return (c:IsSetCard(SET_LSWARM) or c:IsSetCard(SET_ZEFRA)) and c:IsAbleToHand()
end

-- target
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then
		if #g==0 then return false end
		local mg=Group.CreateGroup()
		for tc in aux.Next(g) do
			mg:Merge(tc:GetOverlayGroup())
		end
		if #mg==0 then return false end
		local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil)
		local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g1==0 or #g2==0 then return false end
		local maxct=math.min(#mg,#g1,#g2)
		return maxct>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil,tp)
	if #g==0 then return end
	local mg=Group.CreateGroup()
	for tc in aux.Next(g) do
		mg:Merge(tc:GetOverlayGroup())
	end
	if #mg==0 then return end
	local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g1==0 or #g2==0 then return end
	local maxct=math.min(#mg,#g1,#g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local og=aux.SelectUnselectGroup(mg,e,tp,1,maxct,s.rescon,1,tp,HINTMSG_REMOVEXYZ)
	if #og==0 then return end
	local ct=#og
	Duel.SendtoGrave(og,REASON_EFFECT)
	-- check that all detached actually left the overlay
	local detached=0
	for tc in aux.Next(Duel.GetOperatedGroup()) do
		if tc:IsPreviousLocation(LOCATION_OVERLAY) then detached=detached+1 end
	end
	if detached<ct then return end -- if not all left overlay, stop
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g3=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil)
	local sg=g3:Select(tp,ct,ct,nil)
	if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg2=g2:Select(tp,ct,ct,nil)
		if #sg2>0 then
			Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		end
	end
end


--Return filter
function s.thfilter(c)
	if c:IsLocation(LOCATION_EXTRA) and not c:IsFaceup() then return false end
	return c:IsSetCard({SET_ZEFRA,SET_LSWARM}) and c:IsMonster() and c:IsAbleToHand()
end
