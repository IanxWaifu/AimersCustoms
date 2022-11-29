function c1515.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,1515)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCost(c1515.cost)
	e1:SetTarget(c1515.target)
	e1:SetOperation(c1515.activate)
	c:RegisterEffect(e1)
end
c1515.list={[1710]=1700,[1711]=1719,[1712]=1702,[1713]=1705,[1714]=1709,[1715]=1707}
function c1515.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function c1515.filter1(c,e,tp)
	local code=c:GetCode()
	local tcode=c1515.list[code]
	return tcode and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c1515.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tcode,e,tp)
end
function c1515.filter2(c,tcode,e,tp)
	return c:IsCode(tcode) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function c1515.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c1515.filter1(chkc,e,tp) end
	if chk==0 then 	
	if e:GetLabel()~=1 then return false end
		e:SetLabel(0) return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c1515.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local rg=Duel.SelectTarget(tp,c1515.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetCode())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function c1515.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local code=e:GetLabel()
	local tcode=c1515.list[code]
	local mg1=Duel.GetRitualMaterial(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c1515.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tcode,e,tp,mg1)
	if tc:GetCount()>0 then
		local sp=tc:GetFirst()
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,sp,sp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,sp:GetLevel(),sp)
		sp:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(sp,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		sp:CompleteProcedure()
	end	
end