--Neko Chocola & Vanilla Swirl
function c455590.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(455590,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,455590+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c455590.target)
	e1:SetOperation(c455590.operation)
	c:RegisterEffect(e1)
end
function c455590.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1194)
		and Duel.IsExistingTarget(c455590.filter2,tp,LOCATION_MZONE,0,1,c,e,tp,c:GetLevel())
end
function c455590.filter2(c,e,tp,lv)
	local clv=c:GetLevel()
	local code=e:GetHandler()
	return clv>0 and c:IsFaceup() and c:IsSetCard(0x1194) 
		and Duel.IsExistingMatchingCard(c455590.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+clv)
end
function c455590.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x1194) and c:IsType(TYPE_FUSION) and c:GetLevel()==lv and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function c455590.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c455590.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
 local g1=Duel.SelectTarget(tp,c455590.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
 local g2=Duel.SelectTarget(tp,c455590.filter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c455590.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if not tc1:IsRelateToEffect(e) or not tc2:IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(c455590.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc1:GetLevel()+tc2:GetLevel())
	if sg:GetCount()==0 then return end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT+REASON_FUSION)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ssg=sg:Select(tp,1,1,nil)
	local tsg=ssg:GetFirst()
	if tsg and Duel.SpecialSummon(tsg,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tsg:RegisterFlagEffect(455590,RESET_EVENT+0x1fe0000,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tsg)
		e1:SetCondition(c455590.descon)
		e1:SetOperation(c455590.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c455590.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(455590)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function c455590.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end