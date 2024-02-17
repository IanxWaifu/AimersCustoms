--Scripted by IanxWaifu
--Voltaic Artifact-Vranögad
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Return PZones or Negate Effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC,SET_VOLDRAGO}

--Search Voltaic Monster
function s.filter(c)
	return (c:IsSetCard(SET_VOLTAIC) or c:IsSetCard(SET_VOLDRAGO)) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.posfilter(c)
	return c:IsSetCard(SET_VOLTAIC) and c:IsMonster() and c:IsCanChangePosition()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)>0
		and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		local dg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local dg2=dg:Select(tp,1,1,nil)
			Duel.HintSelection(dg2)
			local chpos=0
			local pos=dg2:GetFirst():GetPosition()
			local isFaceup=(pos&POS_FACEUP)~=0
			local isFacedown=(pos&POS_FACEDOWN_DEFENSE)~=0
			if isFaceup then
			    chpos=POS_FACEDOWN_DEFENSE
			elseif isFacedown then
			    -- Choose between POS_FACEUP_ATTACK and POS_FACEUP_DEFENSE
			    chpos=Duel.SelectPosition(tp,dg2:GetFirst(),POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
			end
			Duel.ChangePosition(dg2,chpos)
		end
	end
end


--Option Select
function s.disfilter(c)
	return c:IsSetCard(SET_VOLTAIC) and c:IsMonster() and not c:IsDisabled() and c:IsFaceup()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)
	local b2=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return b1>0 or #b2>0 end
	local op=0
	if b1>0 and #b2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND)
		local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	else
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,b1,1,tp,LOCATION_MZONE)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	else 
		local g=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end