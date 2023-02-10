--Scripted by IanxWaifu
--Abeyancy of the Temple
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.dcost)
	e2:SetTarget(s.dtg)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x12A8,0x12A9}

function s.filter(c)
	return c:IsSetCard(0x12A8) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end
function s.eqfilter(c)
	return c:IsSetCard(0x12A8) and c:IsMonster() and not c:IsForbidden() and not c:IsType(TYPE_XYZ)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local tc=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
		local tg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
		if c:IsFaceup() and c:IsRelateToEffect(e) and #tc>0 and #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1))  then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local sg=tc:Select(tp,1,1,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local sg2=tg:Select(tp,1,1,nil)
			local b1=sg:GetFirst() and sg:GetFirst():IsCanBeXyzMaterial()
			local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			local op=0
			if b1 and b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			elseif b1 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2))
			else
				op=Duel.SelectOption(tp,aux.Stringid(id,3))
			end
			if op==2 then return end
			if op==0 then
				Duel.BreakEffect()
				Duel.Equip(tp,sg:GetFirst(),sg2:GetFirst())
				--Equip limit
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sg:GetFirst():RegisterEffect(e1)
			else
				Duel.BreakEffect()
				Duel.Overlay(sg2:GetFirst(),sg:GetFirst())
			end
		end
	end
end


function s.xyzfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.CheckRemoveOverlayCard(tp,0,0,2,REASON_COST,dg) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.RemoveOverlayCard(tp,0,0,2,2,REASON_COST,dg)
end
function s.setfilter(c)
	return c:IsSetCard(0x12A9) and c:IsSSetable()
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		g:GetFirst():RegisterEffect(e2)
	end
end