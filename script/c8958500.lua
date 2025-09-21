--Scripted by Aimer
--Vylon Xi
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_VYLON),1,1)
	--You can only Link Summon "Vylon Xi" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 1. If Special Summoned: Place 1 "Vylon Element"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)
	-- 2. Special Summon 1 "Vylon" from hand or GY, then equip this card to it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 3. Grant effect to Synchro Vylon when equipped
		--Client Hint
	local geflag=Effect.CreateEffect(c)
	geflag:SetDescription(aux.Stringid(id,2))
	geflag:SetType(EFFECT_TYPE_SINGLE)
	geflag:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		--Effect
	local ge=Effect.CreateEffect(c)
	ge:SetDescription(aux.Stringid(id,3))
	ge:SetCategory(CATEGORY_DESTROY)
	ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	ge:SetCode(EVENT_SPSUMMON_SUCCESS)
	ge:SetRange(LOCATION_MZONE)
	ge:SetCountLimit(1,{id,2})
	ge:SetCondition(s.descon)
	ge:SetTarget(s.destg)
	ge:SetOperation(s.desop)
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

CARD_VYLON_ELEMENT=92035412
CARD_VYLON_MATRIX=8958510
s.listed_series={SET_VYLON}

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--You cannot Link Summon "Prank-Kids Meow-Meow-Mu" for the rest of this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se) return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-----------------------------------------------------------
-- (1) Place "Vylon Element"
-----------------------------------------------------------
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
			and Duel.IsExistingMatchingCard(s.vylonelementfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
end
function s.vylonelementfilter(c)
	return c:IsCode(CARD_VYLON_ELEMENT,CARD_VYLON_MATRIX) and not c:IsForbidden()
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.vylonelementfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

-----------------------------------------------------------
-- (2) Special Summon "Vylon" then equip this card
-----------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VYLON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
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
			-- equip limit
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
-- (3) Grant effect target filter
-----------------------------------------------------------
function s.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_SYNCHRO) and e:GetHandler():GetEquipTarget()==c
end

-----------------------------------------------------------
-- Destroy effect (granted)
-----------------------------------------------------------
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	local equipg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_EQUIP) end,tp,LOCATION_SZONE,0,nil)
	if chk==0 then return #g>0 and #equipg>=#g end
	local num=#g
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,num*2,0,LOCATION_ONFIELD)
end

-- group selection constraint
function s.desrescon(g1,g2,num)
    return function(sg,e,tp,mg)
        return sg:FilterCount(function(c) return g1:IsContains(c) end,nil)==num
            and sg:FilterCount(function(c) return g2:IsContains(c) end,nil)==num
    end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g1=eg:Filter(Card.IsControler,nil,1-tp)
    if #g1==0 then return end
    local g2=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_EQUIP) end,tp,LOCATION_SZONE,0,nil)
    if #g2<#g1 then return end
    local num=#g1
    local total=g1:Clone()
    total:Merge(g2)
    local rescon=s.desrescon(g1,g2,num)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=aux.SelectUnselectGroup(total,e,tp,num*2,num*2,rescon,1,tp,HINTMSG_DESTROY)
    if #sg==0 then return end
    Duel.Destroy(sg,REASON_EFFECT)
end

