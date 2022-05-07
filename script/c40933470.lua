--Mecha Girl Aueriann
function c40933470.initial_effect(c)
	--add send
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40933470,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,40933470)
	e1:SetTarget(c40933470.target)
	e1:SetOperation(c40933470.operation)
	c:RegisterEffect(e1)
	--Banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40933470,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40933470+1)
	e2:SetCost(c40933470.atkcost)
	e2:SetOperation(c40933470.atkop)
	c:RegisterEffect(e2)
end

function c40933470.filter(c)
	return c:IsSetCard(0x3052) and not c:IsCode(40933470) and c:IsAbleToHand()
	and Duel.IsExistingMatchingCard(c40933470.sfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function c40933470.sfilter(c,code)
	return c:IsSetCard(0x3052) and not c:IsCode(code)
end
function c40933470.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40933470.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c40933470.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c40933470.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c40933470.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local tg=Duel.SelectMatchingCard(tp,c40933470.sfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
	local tg2=tg:GetFirst()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tg2,REASON_EFFECT)~=0 and tg2:IsLocation(LOCATION_GRAVE) then
		Duel.BreakEffect()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end


function c40933470.costfilter(c)
	return c:IsSetCard(0x3052) and c:IsAbleToRemoveAsCost()
end
function c40933470.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c40933470.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c40933470.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c40933470.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3052)
end
function c40933470.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c40933470.afilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)
		e1:SetValue(300)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
