--Scripted by IanxWaifu
--Revelatia - Tempus Scindendi
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x19f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsLocation(LOCATION_GRAVE+LOCATION_HAND)) or (c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
end

function s.rmfilter(c,e,tp)
	return c:IsSetCard(0x19f) and c:IsAbleToRemoveAsCost() 
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x19f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Cannot be Material
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(s.matlimit)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		tc:RegisterEffect(e4,true)
		tc:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		local code=tc:GetCode()
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5:SetCode(EFFECT_CANNOT_ACTIVATE)
		e5:SetTargetRange(1,0)
		e5:SetValue(s.aclimit)
		e5:SetLabel(code)
		e5:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e5,tp)
	end
	Duel.SpecialSummonComplete()
end
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x19f)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:GetHandler():IsOnField() and re:IsActiveType(TYPE_MONSTER)
end
