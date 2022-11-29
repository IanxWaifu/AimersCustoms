function c455625.initial_effect(c)	
	--Fusion Summon
	Fusion.AddProcMix(c,true,true,455554,455552)
	c:EnableReviveLimit()
	--return hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(455625,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c455625.thcon)
	e1:SetTarget(c455625.thtg)
	e1:SetOperation(c455625.thop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(455625,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c455625.spcon)
	e2:SetTarget(c455625.sptg)
	e2:SetOperation(c455625.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(0)
	e3:SetCondition(c455625.spcon2)
	c:RegisterEffect(e3)
end
function c455625.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION
end
function c455625.tfilter(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c455625.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(c455625.tfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c455625.tfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	Duel.SetChainLimit(c455625.chlimit)
end
function c455625.chlimit(e,ep,tp)
	return tp==ep
end
function c455625.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function c455625.spfilter(c,e,tp)
	return c:IsSetCard(0x1194) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(455554) and not c:IsCode(455552)
end
function c455625.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(455581) and e:GetHandler():GetBattledGroupCount()>0
end
function c455625.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(455581) and e:GetHandler():GetBattledGroupCount()>0
end
function c455625.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c455625.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)~=0 and e:GetHandler():IsLocation(LOCATION_DECK+LOCATION_EXTRA) 
		and Duel.IsExistingMatchingCard(c455625.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
		if Duel.SelectYesNo(tp,aux.Stringid(455625,2)) then
			local g=Duel.GetMatchingGroup(c455625.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
			if g:GetCount()>=2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:Select(tp,2,2,nil)
				local tc=sg:GetFirst()
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				tc=sg:GetNext()
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				Duel.SpecialSummonComplete()
			end
		end
	end
end

