--Neko Tease
function c455600.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATK&DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(455600,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c455600.condition)
	e2:SetTarget(c455600.target)
	e2:SetOperation(c455600.operation)
	c:RegisterEffect(e2)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(455600,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c455600.ccon)
	e3:SetCountLimit(1,455600)
	e3:SetTarget(c455600.ctg)
	e3:SetOperation(c455600.cop)
	c:RegisterEffect(e3)
end
function c455600.filter(c)
	return c:IsSetCard(0x1194) and c:IsType(TYPE_MONSTER)
end
function c455600.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c455600.filter,1,nil)
end
function c455600.rfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1194)
end
function c455600.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.IsExistingMatchingCard(c455600.rfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function c455600.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c455600.rfilter,tp,LOCATION_MZONE,0,nil)
	local atk=eg:FilterCount(c455600.filter,nil)*100
	local tc=g:GetFirst()
	if g:GetCount()>0 then
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
		end
	end
end
function c455600.cfilter(c)
	return c:IsSetCard(0x1194) and c:IsType(TYPE_FUSION)
end
function c455600.ccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c455600.cfilter,1,nil)
end
function c455600.spfilter(c,e,tp)
	return c:IsSetCard(0x1194) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c455600.adfilter(c,e,tp)
	return c:IsSetCard(0x1194) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function c455600.ctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c455600.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp))
	local b2=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c455600.adfilter,tp,LOCATION_DECK,0,1,nil,e,tp))
		if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(455600,2),aux.Stringid(455600,3))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(455600,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(455600,3))+1
	end
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end


function c455600.cop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local pg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c455600.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local ptc=pg:GetFirst()
		if ptc then
			Duel.SpecialSummon(ptc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c455600.adfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		end
	end
end