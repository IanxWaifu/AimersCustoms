--Scripted by IanxWaifu
--Silvantís - Beasketeer Phantomshrouder
local s,id=GetID()
function s.initial_effect(c)
	--Perform a Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Attach self
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.equiptg)
	e4:SetOperation(s.equipop)
	c:RegisterEffect(e4)
	--Untarget
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCondition(s.macon)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
s.listed_names={id}
s.listed_series={0x12A8,0x12A9}

--Normal
function s.sumfilter(c)
	return c:IsSetCard(0x12A8) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end

--Send Attach
function s.xyzfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetEquipCount()>0
end

function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local eqg=tc:GetFirst():GetEquipGroup()
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,eqg,1,0,0)
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if not tc or not tc:IsRelateToEffect(e) or tc:GetOverlayCount()==0 or not c:IsRelateToEffect(e) then return end
	local eqg=tc:GetEquipGroup()
	local dg=eqg:Select(tp,1,1,nil)
	local tg=dg:GetFirst()
	if Duel.SendtoGrave(tg,REASON_EFFECT)~=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then 
		Duel.Overlay(tc,c)
	end
end

--Overlay Eff
function s.macon(e)
	local c=e:GetHandler()
	return c:IsSetCard(0x12A9) and c:IsType(TYPE_XYZ)
end


