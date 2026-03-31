--Scripted by Aimer
--Genosynx Kirenir
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
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.setcost)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	-- Activate from hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
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

-- Set activation: Special Summon 1 "Genosynx" monster or Trap as a monster, from hand/GY
function s.ssmonfilter(c,e,tp)
	return c:IsSetCard(SET_GENOSYNX) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.sstrapfilter(c,tp)
	if not (c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_TRAP)) then return false end
	if c:IsForbidden() then return false end
	return Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK)
end

function s.ssfilter(c,e,tp)
	if c:IsMonster() then
		return s.ssmonfilter(c,e,tp)
	else
		return s.sstrapfilter(c,tp)
	end
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	e:SetLabel(1) -- MODE 1: activated while Set -> return this card to hand in EP
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if tc:IsMonster() then
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		else
			tc:AddMonsterAttribute(TYPE_EFFECT|TYPE_SPIRIT|TYPE_TRAP)
			tc:AddMonsterAttributeComplete()
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_BEAST)
			e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
			tc:RegisterEffect(e1,true)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e3:SetValue(ATTRIBUTE_DARK)
			tc:RegisterEffect(e3,true)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CHANGE_LEVEL)
			e4:SetValue(4)
			tc:RegisterEffect(e4,true)
			local e5=e1:Clone()
			e5:SetCode(EFFECT_SET_BASE_ATTACK)
			e5:SetValue(1000)
			tc:RegisterEffect(e5,true)
			local e6=e1:Clone()
			e6:SetCode(EFFECT_SET_BASE_DEFENSE)
			e6:SetValue(1000)
			tc:RegisterEffect(e6,true)
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local exc=(c:GetOriginalCode()==id) and c or nil
	if exc==nil then return end
	s.trapmonster(e,tp)
end

-- Hand activation: negate 1 face-up card, also lock Special Summons until end of next turn (except Genosynx)
function s.negfilter(c)
	return c:IsFaceup()
end

function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- Only exclude self if THIS handler is the original Trap card
	local exc=(c:GetOriginalCode()==id) and c or nil
	if chkc then return chkc:IsOnField() and s.negfilter(chkc)  and (not exc or chkc~=exc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc) end
	e:SetLabel(2) -- MODE 2: activated from hand -> Set this card in EP
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(SET_GENOSYNX)
end

function s.handop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e3,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local exc=(c:GetOriginalCode()==id) and c or nil
	if exc==nil then return end
	s.trapmonster(e,tp)
end

-- Shared Trap Monster summon + End Phase logic (this card)
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
