--Neko Maple
function c455550.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,455550)
	e1:SetCondition(c455550.hspcon)
	e1:SetOperation(c455550.hspop)
	c:RegisterEffect(e1)
	--cos
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89312388,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,455551)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c455550.atg)
	e2:SetOperation(c455550.aop)
	c:RegisterEffect(e2)
end
function c455550.spfilter(c)
	return c:IsSetCard(0x1194) and c:IsAbleToDeckAsCost() and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function c455550.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=-1 then return false end
	if ft<=0 then
		return Duel.IsExistingMatchingCard(c455550.spfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
	else return Duel.IsExistingMatchingCard(c455550.spfilter,tp,0x16,0,1,e:GetHandler()) end
end
function c455550.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		local g=Duel.SelectMatchingCard(tp,c455550.spfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler())
		Duel.SendtoDeck(g,nil,1,REASON_COST)
	else
		local g=Duel.SelectMatchingCard(tp,c455550.spfilter,tp,0x16,0,1,1,e:GetHandler())
		Duel.SendtoDeck(g,nil,1,REASON_COST)
	end
end
function c455550.filter1(c,tp)
	return c.material and c:IsSetCard(0x1194) and Duel.IsExistingMatchingCard(c455550.filter2,tp,LOCATION_DECK,0,1,nil,c)
end
function c455550.filter2(c,fc)
	if c:IsForbidden() or not c:IsAbleToHand() then return false end
	return c:IsCode(table.unpack(fc.material))
end
function c455550.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c455550.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c455550.aop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=Duel.SelectMatchingCard(tp,c455550.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if cg:GetCount()==0 then return end
	Duel.ConfirmCards(1-tp,cg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c455550.filter2,tp,LOCATION_DECK,0,1,1,nil,cg:GetFirst())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end