--Scripted by IanxWaifu
--Naidenía - Beasketeer Lightbearer
local s,id=GetID()
function s.initial_effect(c)
	--Reveal Normal
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- Equip self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.equiptg)
	e2:SetOperation(s.equipop)
	c:RegisterEffect(e2)
	--Idndes)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(s.macon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={0x12A8,0x12A9}

--Reveal Summon
function s.sumfilter(c,e,tp)
	return c:IsSetCard(0x12A8) and not c:IsPublic()
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),e,tp)
	g:GetFirst():CreateEffectRelation(e)
	g:AddCard(c)
	g:KeepAlive()
	e:SetLabelObject(g)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) 
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	local g=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject():Filter(s.spfilter,nil,e,tp)
	if #g==2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
	g:DeleteGroup()
end

--Detach Equip
function s.xyzfilter(c,tp)
	return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if not tc or not tc:IsRelateToEffect(e) or tc:GetOverlayCount()==0 or not c:IsRelateToEffect(e) then return end
	if tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)~=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then 
	Duel.Equip(tp,c,tc)
	c:SetCardTarget(tc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end


--Equip Eff
function s.macon(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsSetCard(0x12A9) and c:IsType(TYPE_XYZ)
end


