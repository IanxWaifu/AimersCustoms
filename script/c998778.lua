--Scripted by IanxWaifu
--Girls'&'Arms - Sirenne
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x12EE),2,2,s.lcheck)
	c:EnableReviveLimit()
	--Negate Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	aux.DoubleSnareValidity(c,LOCATION_SZONE)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon2)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--Lose ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.atk)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
function s.cfilter(c,seq,p)
	return c:IsFaceup() and c:IsSetCard(0x12EE) and c:IsColumn(seq,p,LOCATION_SZONE) 
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_TRAP+TYPE_SPELL) then return false end
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and (loc&LOCATION_SZONE==0 or rc:IsControler(1-p)) then
		if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
			seq=rc:GetSequence()
			loc=LOCATION_SZONE
		else
			seq=rc:GetPreviousSequence()
			loc=rc:GetPreviousLocation()
		end
	end
	return loc&LOCATION_SZONE==LOCATION_SZONE and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,seq,p) and e:GetHandler():GetFlagEffect(id)==0
end

function s.cfilter2(c,seq,p)
	return c:IsFaceup() and c:IsSetCard(0x12EE) and c:IsColumn(seq,p,LOCATION_MZONE)
end
function s.sendfilter(c,e,tp)
	return c:IsSetCard(0x12EF) and c:IsAbleToGrave() and c:IsType(TYPE_CONTINUOUS)
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return loc==LOCATION_MZONE and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,seq,p) and e:GetHandler():GetFlagEffect(id)==0
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_SZONE,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.Hint(HINT_CARD,0,id) 
		local tg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_SZONE,0,1,1,nil,tp)
		local tc=tg:GetFirst()
		Duel.SendtoGrave(tc,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.NegateEffect(ev)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end


function s.atk(e,_c)
	return _c:GetColumnGroup():IsExists(function(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsLinkMonster() and c:IsSetCard(0x12EE) and c:GetMutualLinkedGroupCount()>=1
		end,1,_c,e:GetHandlerPlayer())
end