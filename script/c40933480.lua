--Mecha Girl Capsule
function c40933480.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40933480,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,40933480)
	e1:SetCost(c40933480.tdcost)
	e1:SetTarget(c40933480.tdtg)
	e1:SetOperation(c40933480.tdop)
	c:RegisterEffect(e1)
end
function c40933480.tdfilter(c)
	return c:IsSetCard(0x3052) and c:IsAbleToRemoveAsCost()
end
function c40933480.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c40933480.tdfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c40933480.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c40933480.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function c40933480.tdop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		local tc=g:GetFirst()
		if g:GetCount()>0 and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsSetCard(0x3052) and tc:IsType(TYPE_MONSTER) then
			tc:RegisterFlagEffect(40933480,RESET_EVENT+RESETS_STANDARD,0,0)  
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetOperation(c40933480.spop)
			e1:SetReset(EVENT_PHASE+PHASE_MAIN1,2)
			Duel.RegisterEffect(e1,tp)
			tc:CreateEffectRelation(e1)
	end
end
function c40933480.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:GetFlagEffect(40933480)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end