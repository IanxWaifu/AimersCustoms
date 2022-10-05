--Scripted by IanxWaifu
--Iron Saga - Sought Deliverance
local s,id=GetID()
function s.initial_effect(c)
	--Negate Spell/Trap or effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Negate SPSummoned Monsters effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon2)
	e2:SetTarget(s.negtg2)
	e2:SetOperation(s.negop2)
	c:RegisterEffect(e2)
end
--Negate S/T Effects
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x1A0)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.NegateRelatedChain(tc,RESET_TURN_SET)~=0 and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,998924),tp,LOCATION_ONFIELD,0,1,nil) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local tg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
			if #tg>0 then
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
			end
		end
	end
end
--Negate Monsters Effects
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x1A0)
end
function s.negfilter(c,tp)
	return not c:IsSummonPlayer(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.negtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.negfilter,nil,tp)
	local ct=#g
	if chk==0 then return ct>0 end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,ct,0,0)
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.negfilter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,998924),tp,LOCATION_ONFIELD,0,1,nil) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local tg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
			if #tg>0 then
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
			end
		end
	end
end