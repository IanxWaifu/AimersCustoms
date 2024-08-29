function c1703.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Move
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1703,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(2,1703)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c1703.seqtg)
	e2:SetOperation(c1703.seqop)
	c:RegisterEffect(e2)
	--Equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1703,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,1704)
	e3:SetTarget(c1703.target)
	e3:SetOperation(c1703.operation)
	c:RegisterEffect(e3)
	--Add
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1703,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,1705)
	e4:SetCondition(c1703.acon)
	e4:SetTarget(c1703.atg)
	e4:SetOperation(c1703.aop)
	c:RegisterEffect(e4)
end
function c1703.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function c1703.seqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=0
	if s==1 then nseq=0
	elseif s==2 then nseq=1
	elseif s==4 then nseq=2
	elseif s==8 then nseq=3
	else nseq=4 end
	Duel.MoveSequence(tc,nseq)
end
function c1703.tcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6A4) and Duel.IsExistingMatchingCard(c1703.ecfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
function c1703.ecfilter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x6D6) and c:CheckEquipTarget(tc)
end
function c1703.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c1703.tcfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c1703.tcfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1703,0))
	Duel.SelectTarget(tp,c1703.tcfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end
function c1703.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local ec=Duel.SelectMatchingCard(tp,c1703.ecfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc):GetFirst()
		if ec then
			Duel.Equip(tp,ec,tc)
		end
	end
end
function c1703.cfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x6D6)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_EQUIP)~=0
end
function c1703.acon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1703.cfilter,1,nil,tp)
end
function c1703.afilter(c,e,tp)
	return c:IsSetCard(0x708) and c:IsAbleToHand() and c:IsLocation(LOCATION_DECK)
end
function c1703.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1703.afilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c1703.aop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c1703.afilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end