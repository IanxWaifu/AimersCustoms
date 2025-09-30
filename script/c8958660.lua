--Scripted by Aimer
--Ex-Exosister Irae
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(s.ovfilter),4,2)
	--Indestructible against certain monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	--Banish from hand if summoned with Zefra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--Revive or add if summoned with Exosister
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thspcon)
	e3:SetTarget(s.thsptg)
	e3:SetOperation(s.thspop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_ZEFRA,SET_EXOSISTER}

function s.ovfilter(c,tp,lc)
	return c:IsSetCard(SET_ZEFRA,lc,SUMMON_TYPE_XYZ,tp) or c:IsSetCard(SET_EXOSISTER,lc,SUMMON_TYPE_XYZ,tp)
end

-- Indestructibility condition: monsters from GY/Extra Deck
function s.indval(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and (rc:IsSummonLocation(LOCATION_GRAVE) or rc:IsSummonLocation(LOCATION_EXTRA))
end

-- Check if summoned using Zefra material
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,SET_ZEFRA)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local sg=g:RandomSelect(tp,1)
	local tc=sg:GetFirst()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		--Return during End Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsLocation(LOCATION_REMOVED) then
		Duel.SendtoHand(tc,tc:GetOwner(),REASON_EFFECT)
	end
end

-- Check if summoned using Exosister material
function s.thspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsStatus(STATUS_SPSUMMON_TURN)
		and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,SET_EXOSISTER)
end
function s.thspfilter(c,e,tp)
	return c:IsSetCard(SET_EXOSISTER) or c:IsSetCard(SET_ZEFRA)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,
		function(c) return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function(c) Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,2))
end