--Scripted by Aimer
--Genosynx Aegipan
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	-- Activate from hand permission
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.genosynx_actcon)
	c:RegisterEffect(e0)
	-- Activate the turn it was Set
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_SINGLE)
	e00:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e00:SetCondition(s.genosynx_actcon)
	c:RegisterEffect(e00)
	-- Activate while Set
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.setcost)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	-- Activate from hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.handcost)
	e2:SetCondition(s.handcon)
	e2:SetTarget(s.handtg)
	e2:SetOperation(s.handop)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
	-- marker that points to e1 (Set-route)
	local em1=Effect.CreateEffect(c)
	em1:SetType(EFFECT_TYPE_SINGLE)
	em1:SetRange(LOCATION_ALL)
	em1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	em1:SetCode(GENOSYNX_SET_ACT)  
	em1:SetLabelObject(e1)  
	c:RegisterEffect(em1)
	-- marker that points to e2 (Hand-route)
	local em2=Effect.CreateEffect(c)
	em2:SetType(EFFECT_TYPE_SINGLE)
	em2:SetRange(LOCATION_ALL)
	em2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	em2:SetCode(GENOSYNX_HAND_ACT)
	em2:SetLabelObject(e2)
	c:RegisterEffect(em2)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

-- Shared Genosynx activation condition
function s.genosynx_actcon(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return #g==0 or g:FilterCount(Card.IsSetCard,nil,SET_GENOSYNX)==#g
end

-- Activation conditions
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ((c:IsLocation(LOCATION_SZONE) and c:IsFacedown()) or ((c:GetOverlayTarget()~=nil)))
end

function s.handcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_HAND) or (c:GetOverlayTarget()~=nil)
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local mask=Duel.GetFlagEffectLabel(tp,id) or 0
	if chk==0 then return (mask&0x1)==0 end
	if Duel.GetFlagEffect(tp,id)==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	end
	Duel.SetFlagEffectLabel(tp,id,mask|0x1)
end
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local mask=Duel.GetFlagEffectLabel(tp,id) or 0
	if chk==0 then return (mask&0x2)==0 end
	if Duel.GetFlagEffect(tp,id)==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	end
	Duel.SetFlagEffectLabel(tp,id,mask|0x2)
end
-- Set activation: target 1 card, return to hand
function s.setfilter(c)
	return c:IsAbleToHand()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- Only exclude self if THIS handler is the original Trap card
	local exc=(c:GetOriginalCode()==id) and c or nil
	if chkc then return chkc:IsOnField() and s.setfilter(chkc) and (not exc or chkc~=exc) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc) end
	e:SetLabel(1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end


function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local exc=(c:GetOriginalCode()==id) and c or nil
	if exc==nil then return end
	s.trapmonster(e,tp)
end

-- Hand activation: add 1 "Genosynx" from Deck to hand (except itself)
function s.thfilter(c)
	return c:IsSetCard(SET_GENOSYNX) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	e:SetLabel(2) -- MODE 2: activated from hand -> Set this card in EP
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.handop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local exc=(c:GetOriginalCode()==id) and c or nil
	if exc==nil then return end
	s.trapmonster(e,tp)
end

-- Shared Trap Monster summon + End Phase logic
function s.trapmonster(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT|TYPE_SPIRIT|TYPE_TRAP)
	c:AddMonsterAttributeComplete()
	if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP) then
		local mode=e:GetLabel()
		if mode~=1 and mode~=2 then mode=1 end
		-- store mode for End Phase (1=return to hand, 2=set itself)
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_DISABLE,0,1,mode)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(s.epop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end

function s.epop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mode=c:GetFlagEffectLabel(id)
	-- Activated while Set -> return to hand
	if mode==1 then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	-- Activated from hand -> Set itself
	elseif mode==2 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
