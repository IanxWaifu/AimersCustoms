--Scripted by IanxWaifu
--Daedric Relic, Repression
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
	e1:SetTarget(s.rttg)
	e1:SetOperation(s.rtop)
	c:RegisterEffect(e1)
end
function s.rtfilter(c,tp)
	return c:GetColumnGroup():IsExists(s.cfilter,1,nil,tp)
end
function s.cfilter(c,tp)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and (c:IsType(TYPE_XYZ) or c:IsType(TYPE_RITUAL) or c:IsType(TYPE_FUSION))) 
	or (c:IsFaceup() and c:IsLocation(LOCATION_PZONE))) and c:IsSetCard(0x718) and c:IsControler(tp)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and c:IsSetCard(0x718)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_PZONE,0,nil)
	if chk==0 then return #dg>0 and Duel.IsExistingMatchingCard(s.rtfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,0,tp,LOCATION_PZONE)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rtfilter,tp,0,LOCATION_ONFIELD,nil,tp)
	local dg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_PZONE,0,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		if #dg<=0 then return false end
		Duel.BreakEffect()
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
	end
end
