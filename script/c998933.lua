--Scripted by IanxWaifu
--Iron Saga - Tetra Direct
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Send replace
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--Banish and Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

function s.repfilter(c,e,tp)
	return c:IsSetCard(0x1A0) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetDestination()==LOCATION_HAND and c:IsMonster()
	and  Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
end
function s.chkfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1A0) and c:IsCanBeEffectTarget(e) and c:GetLevel()==7
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1A0) and c:GetLevel()==7 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.reptestfilter(c,e,tp)
	return c:IsSetCard(0x1A0) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e) and  c:IsMonster() and c:GetLevel()==7
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (r&REASON_EFFECT+REASON_COST)~=0 and re and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsSetCard(0x1A0) and eg:IsExists(s.repfilter,1,nil,e,tp) end
	local g3=Duel.GetMatchingGroup(s.reptestfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local tg=Duel.SelectMatchingCard(tp,s.reptestfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local tg2=tg:GetFirst()
		e:GetHandler():SetCardTarget(tg2)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		return true
	else return false end
	if not e:GetHandler():IsRelateToEffect(e) then return end
end
function s.repval(e,c)
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end

--Banish and Search
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1A0)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil) 
end
function s.thfilter(c)
	return c:IsLevel(4) and c:IsSetCard(0x1A0) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
