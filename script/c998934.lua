--Scripted by IanxWaifu
--Iron Saga - Ruins of Reconception
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
	--Negate Effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x1A0) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		if not tc:IsRelateToEffect(e) and not tc:IsFaceup() then return end
			Duel.BreakEffect()
			local mt = tc:GetMetatable()
			--effect gain
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetCategory(CATEGORY_TOHAND)
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetCountLimit(1,{id,1})
			e1:SetProperty(EFFECT_FLAG_DELAY)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCost(s.announcecost)
			e1:SetLabelObject(mt.ordinal_scale)
			e1:SetTarget(s.sptg2)
			e1:SetOperation(s.spop2)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1,true)
	end
end

function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end


function s.tablefilter(c,e,tp,codes)
	return c:IsSetCard(0x1A0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and codes and c:IsCode(table.unpack(codes))
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local codes = e:GetLabelObject()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.tablefilter,tp,LOCATION_DECK,0,1,nil,e,tp,codes) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local codes = e:GetLabelObject()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tablefilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,codes)
	local tg=g:GetFirst()
	if Duel.SpecialSummonStep(tg,0,tp,tp,false,false,POS_FACEUP) then
		tg:RegisterFlagEffect(998932,RESET_EVENT+RESETS_STANDARD,0,0)
	end
	Duel.SpecialSummonComplete()
end

function s.cfilter(c)
	return c:IsSetCard(0x1A0) and c:IsAbleToRemoveAsCost()
end

function s.repfilter(c,e,tp)
	return c:IsSetCard(0x1A0) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetDestination()==LOCATION_HAND and c:IsMonster()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1A0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
--Replace and Reduce
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) 
	and (r&REASON_EFFECT+REASON_COST)~=0 and re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x1A0) and eg:IsExists(s.repfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
		g:AddCard(e:GetHandler())
			local tc=eg:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE)
			tc:RegisterEffect(e2)
			local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
			if Duel.Remove(g,POS_FACEUP,REASON_COST)~=0 and #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local dg=g3:Select(tp,1,1,nil)
			Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		return true
	else return false end
end
function s.repval(e,c)
	return true
end
