--Scripted by IanxWaifu
--Klementinè - Beasketeer Gaiatrooper
local s,id=GetID()
function s.initial_effect(c)
	--Special
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Attach self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	--effect gain 
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.matcon)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={0x12A8,0x12A9}
--Special
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x12A9) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Duel Effect Gain to Detach
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.applycon)
	e1:SetOperation(s.applyop)
	e1:SetLabelObject(c)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
function s.applycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) 
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	--Detach Equip Duel Op
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.efcon)
	e1:SetOperation(s.efop)
	e1:SetLabelObject(c)
	Duel.RegisterEffect(e1,tp)
end

function s.checkfilter(c,e,xyz)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local xyz=e:GetLabelObject()
	return xyz:GetFlagEffect(id)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local xyz=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(s.checkfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local mg=g:Select(tp,1,1,nil)
	local mg2=mg:GetFirst()
	Duel.RaiseSingleEvent(xyz,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	xyz:ResetFlagEffect(id)
	Duel.Equip(tp,xyz,mg2)
	xyz:SetCardTarget(mg2)
	xyz:ResetFlagEffect(id)
	local e1=Effect.CreateEffect(xyz)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(mg2)
	xyz:RegisterEffect(e1)
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end



--Attach
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) then
		c:CancelToGrave()
		Duel.Overlay(tc,c)
	end
end
