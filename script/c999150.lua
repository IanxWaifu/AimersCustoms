--Scripted by IanxWaifu
--Jareláie - Beasketeer Flamestrider
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--effect gain 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
	-- Equip self
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.equipcon)
	e3:SetTarget(s.equiptg)
	e3:SetOperation(s.equipop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={0x12A8,0x12A9}

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x12A8) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and #g2>0 and Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local dg=g:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
		Duel.SendtoGrave(dg,REASON_EFFECT)
	end
end

function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IMMEDIATELY_APPLY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.matcon)
	e1:SetCountLimit(1,{id,2})
	e1:SetTarget(s.mattg)
	e1:SetOperation(s.matop)
	e1:SetLabelObject(c)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and sc:GetFlagEffect(id)>0 and e:GetHandler():IsSetCard(0x12A9)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	sc:ResetFlagEffect(id)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return false end
	Duel.Hint(HINT_CARD,0,id)
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if #g1==0 or #g2==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local mg=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=g2:Select(tp,1,1,nil):GetFirst()
	if Duel.Overlay(tc,mg)~=0 then 
	Duel.SendtoGrave(sc,REASON_COST)
	Duel.RaiseSingleEvent(sc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end

--Equip self
function s.equipcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount() and c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12A9)
end
function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then
		return
	end
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
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end