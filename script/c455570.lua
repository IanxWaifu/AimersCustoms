function c455570.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,{455552,455554},aux.FilterBoolFunctionEx(Card.IsSetCard,0x1194))
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(455570,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetTarget(c455570.rmtg)
	e1:SetOperation(c455570.rmop)
	c:RegisterEffect(e1)
	--ToDeck Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(455570,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c455570.tdcon)
	e2:SetTarget(c455570.tdtg)
	e2:SetOperation(c455570.tdop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(455570,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c455570.spcon)
	e3:SetTarget(c455570.sptg)
	e3:SetOperation(c455570.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(0)
	e4:SetCondition(c455570.spcon2)
	c:RegisterEffect(e4)
end
function c455570.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function c455570.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local og=Duel.GetOperatedGroup()
		local oc=og:GetFirst()
		while oc do
			if oc:IsControler(tp) then
				oc:RegisterFlagEffect(455570,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
			else
				oc:RegisterFlagEffect(455570,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
			end
			oc=og:GetNext()
		end
		og:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetCondition(c455570.retcon)
		e1:SetOperation(c455570.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c455570.retfilter(c)
	return c:GetFlagEffect(455570)~=0
end
function c455570.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c455570.retop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.SelectOption(tp,aux.Stringid(455570,4),aux.Stringid(455570,5))
	e:SetLabel(opt)
	local g=e:GetLabelObject()
	local sg=g:Filter(c455570.retfilter,nil)
	if sg:GetCount()>1 and sg:GetClassCount(Card.GetPreviousControler)==1 then
		local ft=Duel.GetLocationCount(sg:GetFirst():GetPreviousControler(),LOCATION_MZONE)
		if ft==1 then
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			if e:GetLabel()==0 then
			e:SetCategory(CATEGORY_TODECK)
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
			else
			Duel.ReturnToField(tc)
			end
			sg:RemoveCard(tc)
		end
	end
	local tc=sg:GetFirst()
	while tc do
	if e:GetLabel()==0 then
		e:SetCategory(CATEGORY_TODECK)
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		else
		Duel.ReturnToField(tc)
		end
		tc=sg:GetNext()
	end
end
function c455570.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e and e:GetHandler():IsSetCard(0x1194)
end
function c455570.tdfilter(c)
	return c:IsFaceup() and c:GetAttack()>0 and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
function c455570.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c455570.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c455570.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c455570.tdfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c455570.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 and not tc:IsDisabled() and tc:IsControler(1-tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e3)
	end
end
function c455570.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
function c455570.spfilter(c,e,tp)
	return c:IsSetCard(0x1194) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c455570.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(455581) and e:GetHandler():GetBattledGroupCount()>0
end
function c455570.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(455581) and e:GetHandler():GetBattledGroupCount()>0
end
function c455570.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c455570.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)~=0 and e:GetHandler():IsLocation(LOCATION_DECK+LOCATION_EXTRA) 
		and Duel.IsExistingMatchingCard(c455570.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			if Duel.SelectYesNo(tp,aux.Stringid(455570,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,c455570.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
				if tc then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end