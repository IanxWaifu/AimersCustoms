--Scripted by Aimer
--Vylon Chi
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_VYLON),2,2)
	-- 1. Ignition: Special Summon 1 "Vylon" then equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 2. GY Trigger: Equip from GY when any Synchro Monster is Special Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- 3. Granted Effect: opponent activates card/effect → banish + destroy 1 Vylon equip
	--Client Hint
	local geflag=Effect.CreateEffect(c)
	geflag:SetDescription(aux.Stringid(id,2))
	geflag:SetType(EFFECT_TYPE_SINGLE)
	geflag:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	--Effect
	local ge=Effect.CreateEffect(c)
	ge:SetDescription(aux.Stringid(id,3))
	ge:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	ge:SetType(EFFECT_TYPE_QUICK_O)
	ge:SetCode(EVENT_CHAINING)
	ge:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	ge:SetRange(LOCATION_MZONE)
	ge:SetCountLimit(1,{id,2})
	ge:SetCondition(s.grantcon)
	ge:SetTarget(s.granttg)
	ge:SetOperation(s.grantop)
	--Grant the Flag and Effect
	local ge_grant=Effect.CreateEffect(c)
	ge_grant:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ge_grant:SetRange(LOCATION_STZONE)
	ge_grant:SetTargetRange(LOCATION_MZONE,0)
	ge_grant:SetTarget(s.eftg)
	ge_grant:SetLabelObject(ge)
	c:RegisterEffect(ge_grant)
	local ge_grantflag=ge_grant:Clone()
	ge_grantflag:SetLabelObject(geflag)
	c:RegisterEffect(ge_grantflag)
end

s.listed_series={SET_VYLON}

-----------------------------------------------------------
-- (1) Ignition: Special Summon then Equip
-----------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VYLON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.Equip(tp,c,sc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(function(e,c) return c==sc end)
			c:RegisterEffect(e1)
		end
	end
end

-----------------------------------------------------------
-- (2) GY Equip Trigger
-----------------------------------------------------------
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==tc end)
		c:RegisterEffect(e1)
	end
end

-----------------------------------------------------------
-- (3) Grant Effect filter
-----------------------------------------------------------
function s.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_SYNCHRO) and e:GetHandler():GetEquipTarget()==c
end

-----------------------------------------------------------
-- Granted Effect: Banish and destroy simultaneously
-----------------------------------------------------------
function s.grantcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActivated() and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end

function s.granttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_EQUIP) end,tp,LOCATION_SZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,re:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_SZONE)
end

function s.grantop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc or not tc:IsRelateToEffect(re) then return end
	local vg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_EQUIP) end,tp,LOCATION_SZONE,0,nil)
	if #vg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=vg:Select(tp,1,1,nil)
	Duel.BreakEffect()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	Duel.Destroy(dg,REASON_EFFECT)
end

