--Neko Neko C&V Goth
function c455615.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
		Fusion.AddProcMix(c,true,true,{455552,455554},aux.FilterBoolFunctionEx(Card.IsSetCard,0x1194))
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,455615)
	e1:SetCondition(c455615.negcon)
	e1:SetOperation(c455615.negop)
	c:RegisterEffect(e1)
	--negate 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(455615,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,455615)
	e2:SetCondition(c455615.discon)
	e2:SetTarget(c455615.distg)
	e2:SetOperation(c455615.disop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(455615,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c455615.spcon)
	e3:SetTarget(c455615.sptg)
	e3:SetOperation(c455615.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(0)
	e4:SetCondition(c455615.spcon2)
	c:RegisterEffect(e4)
end
function c455615.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE+LOCATION_ONFIELD)
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and ep~=tp
end
function c455615.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c455615.discon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and rp~=tp
end
function c455615.disfilter(c)
	return c:IsSetCard(0x1194) and c:IsAbleToDeck()
end
function c455615.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c455615.disfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c455615.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c455615.disfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
		Duel.NegateActivation(ev)
		if re:GetHandler():IsRelateToEffect(re) and not eg:IsDisabled() and not eg:IsType(TYPE_NORMAL) and eg:IsLocation(LOCATION_MZONE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		eg:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		eg:RegisterEffect(e2)
		end
	end
end
function c455615.spfilter(c,e,tp)
	return c:IsSetCard(0x1194) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c455615.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(455581) and e:GetHandler():GetBattledGroupCount()>0
end
function c455615.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(455581) and e:GetHandler():GetBattledGroupCount()>0
end
function c455615.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c455615.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)~=0 and e:GetHandler():IsLocation(LOCATION_DECK+LOCATION_EXTRA) 
		and Duel.IsExistingMatchingCard(c455615.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			if Duel.SelectYesNo(tp,aux.Stringid(455615,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,c455615.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
				if tc then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end