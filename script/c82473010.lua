--Scripted by Aimer
--Genosynx Khilaguin
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Send 1 "Genosynx" from Deck to GY, then you can Set 1 "Genosynx" S/T with different name
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Opponent's End Phase: banish from GY; return 1 target to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- tp = the player who performed the Set
	for tc in aux.Next(eg) do
		if tc:IsSpellTrap() and not tc:IsSetCard(SET_GENOSYNX) then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
			return
		end
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,tc) return not tc:IsSetCard(SET_GENOSYNX) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2),nil)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_GENOSYNX) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.setfilter(c,code)
	return c:IsSetCard(SET_GENOSYNX) and c:IsSpellTrap() and c:IsSSetable()
		and not c:IsCode(id) and not c:IsCode(code)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc then return end
	if Duel.SendtoGrave(sc,REASON_EFFECT)==0 or not sc:IsLocation(LOCATION_GRAVE) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,sc:GetCode())
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,sc:GetCode())
		local tc=sg:GetFirst()
		if tc then
			Duel.BreakEffect()
			Duel.SSet(tp,tc)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,tc) return not tc:IsSetCard(SET_GENOSYNX) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2),nil)
end




--------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.fldthfilter(c)
	return (c:IsSetCard(SET_GENOSYNX) and c:IsMonster() and c:IsAbleToHand())
		or (c:IsFacedown() and c:IsSpellTrap() and c:IsAbleToHand())
end
function s.ovthfilter(c)
	return c:IsSetCard(SET_GENOSYNX) and c:IsTrap() and c:IsAbleToHand()
end

function s.getovg(tp)
	local g=Group.CreateGroup()
	local xg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,nil)
	for xc in aux.Next(xg) do
		local og=xc:GetOverlayGroup()
		for tc in aux.Next(og) do
			if s.ovthfilter(tc) then
				g:AddCard(tc)
			end
		end
	end
	return g
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) then
			return s.fldthfilter(chkc)
		end
		if chkc:IsControler(tp) and chkc:IsLocation(LOCATION_OVERLAY) then
			return s.ovthfilter(chkc)
		end
		return false
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.fldthfilter,tp,LOCATION_ONFIELD,0,1,nil)
			or s.getovg(tp):GetCount()>0
	end
	local g=Duel.GetMatchingGroup(s.fldthfilter,tp,LOCATION_ONFIELD,0,nil)
	local og=s.getovg(tp)
	if og:GetCount()>0 then g:Merge(og) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if tc:IsLocation(LOCATION_ONFIELD) then
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
		return
	end
	--LOCATION_OVERLAY (attached trap)
	if tc:IsLocation(LOCATION_OVERLAY) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end