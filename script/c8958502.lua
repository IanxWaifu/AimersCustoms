--Scripted by Aimer
--Vylon Temple
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Enable equipped Vylon monsters to use Quick Effects (custom event)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(id)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	--Main Phase: Special Summon or Equip from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.limcost)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Triggered Equip when Vylon monster Special Summoned from S/T Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.limcost)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		s[0]=true
		s[1]=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
		--Apply Flag to Restrict Ignitions till End Phase
		local ge3=Effect.GlobalEffect()
	    ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    ge3:SetCode(EVENT_CHAIN_ACTIVATING)
	    ge3:SetOperation(s.checkignition)
	    Duel.RegisterEffect(ge3,0)
	end)

	-- Effect Grants to original Vylon Monsters existing in Real Yugioh
	------------Episilon--------------
	local geflag=Effect.CreateEffect(c)
	geflag:SetDescription(aux.Stringid(id,5))
	geflag:SetType(EFFECT_TYPE_SINGLE)
	geflag:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	local effg1=Effect.CreateEffect(c)
	effg1:SetDescription(aux.Stringid(id,6))
	effg1:SetCategory(CATEGORY_DESTROY)
	effg1:SetType(EFFECT_TYPE_QUICK_O)
	effg1:SetCode(EVENT_FREE_CHAIN)
	effg1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	effg1:SetRange(LOCATION_MZONE)
	effg1:SetCountLimit(1)
	effg1:SetCost(s.effcost1)
	effg1:SetTarget(s.efftg1)
	effg1:SetOperation(s.effop1)
	--Grant the Flag and Effect
	local ge_grant=Effect.CreateEffect(c)
	ge_grant:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ge_grant:SetRange(LOCATION_FZONE)
	ge_grant:SetTargetRange(LOCATION_MZONE,0)
	ge_grant:SetTarget(s.eftg1)
	ge_grant:SetLabelObject(effg1)
	c:RegisterEffect(ge_grant)
	local ge_grantflag=ge_grant:Clone()
	ge_grantflag:SetLabelObject(geflag)
	c:RegisterEffect(ge_grantflag)
	------------Omega------------
	local geflag2=Effect.CreateEffect(c)
	geflag2:SetDescription(aux.Stringid(id,5))
	geflag2:SetType(EFFECT_TYPE_SINGLE)
	geflag2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	local effg2=Effect.CreateEffect(c)
	effg2:SetDescription(aux.Stringid(id,7))
	effg2:SetCategory(CATEGORY_EQUIP)
	effg2:SetType(EFFECT_TYPE_QUICK_O)
	effg2:SetCode(EVENT_FREE_CHAIN)
	effg2:SetRange(LOCATION_MZONE)
	effg2:SetCountLimit(1)
	effg2:SetCost(s.effcost2)
	effg2:SetTarget(s.efftg2)
	effg2:SetOperation(s.effop2)
	--Grant the Flag and Effect
	local ge_grant2=Effect.CreateEffect(c)
	ge_grant2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ge_grant2:SetRange(LOCATION_FZONE)
	ge_grant2:SetTargetRange(LOCATION_MZONE,0)
	ge_grant2:SetTarget(s.eftg2)
	ge_grant2:SetLabelObject(effg2)
	c:RegisterEffect(ge_grant2)
	local ge_grantflag2=ge_grant2:Clone()
	ge_grantflag2:SetLabelObject(geflag2)
	c:RegisterEffect(ge_grantflag2)
	----------Disigma--------
	local geflag3=Effect.CreateEffect(c)
	geflag3:SetDescription(aux.Stringid(id,5))
	geflag3:SetType(EFFECT_TYPE_SINGLE)
	geflag3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	local effg3=Effect.CreateEffect(c)
	effg3:SetDescription(aux.Stringid(id,8))
	effg3:SetCategory(CATEGORY_EQUIP)
	effg3:SetType(EFFECT_TYPE_QUICK_O)
	effg3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	effg3:SetCode(EVENT_FREE_CHAIN)
	effg3:SetRange(LOCATION_MZONE)
	effg3:SetCountLimit(1)
	effg3:SetCost(Cost.AND(Cost.DetachFromSelf(1),s.effcost3))
	effg3:SetTarget(s.efftg3)
	effg3:SetOperation(s.effop3)
	--Grant the Flag and Effect
	local ge_grant3=Effect.CreateEffect(c)
	ge_grant3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ge_grant3:SetRange(LOCATION_FZONE)
	ge_grant3:SetTargetRange(LOCATION_MZONE,0)
	ge_grant3:SetTarget(s.eftg3)
	ge_grant3:SetLabelObject(effg3)
	c:RegisterEffect(ge_grant3)
	local ge_grantflag3=ge_grant3:Clone()
	ge_grantflag3:SetLabelObject(geflag3)
	c:RegisterEffect(ge_grantflag3)

	-- Restrict the activation of Ignition effects for target monsters while this card is face-up
	local restrict=Effect.CreateEffect(c)
	restrict:SetType(EFFECT_TYPE_FIELD)
	restrict:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	restrict:SetCode(EFFECT_CANNOT_ACTIVATE)
	restrict:SetRange(LOCATION_FZONE)
	restrict:SetTargetRange(LOCATION_MZONE,0)
	restrict:SetValue(function(e,re,tp)
	    local c=re:GetHandler()
	    if not s.eftg(e,c) then return false end
	    -- block only Ignition effects
	    return re:IsActiveType(TYPE_MONSTER) and re:IsHasType(EFFECT_TYPE_IGNITION)
	end)
	c:RegisterEffect(restrict)
end

--Global op: if a Vylon Synchro you control on field activates an Ignition, flag it
function s.checkignition(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if rc:IsLocation(LOCATION_MZONE) and rc:IsFaceup() and rc:IsControler(tp) and rc:IsSetCard(SET_VYLON) and rc:IsType(TYPE_SYNCHRO+TYPE_XYZ)
        and re:IsActiveType(TYPE_MONSTER) and re:IsHasType(EFFECT_TYPE_IGNITION) then
        rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end
----------------Effect Grants to Existing Vylons-----------------------------
function s.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and (c:IsOriginalCode(75779210) or c:IsOriginalCode(93157004) or c:IsOriginalCode(39987164) or c:IsOriginalCode(8958511)) and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VYLON) 
end
function s.eftg1(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and ((c:IsOriginalCode(75779210) and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VYLON)) or (c:IsOriginalCode(8958511) and c:GetEquipGroup():IsExists(Card.IsOriginalCode,1,nil,75779210)))
end
function s.eftg2(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and ((c:IsOriginalCode(93157004) and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VYLON)) or (c:IsOriginalCode(8958511) and c:GetEquipGroup():IsExists(Card.IsOriginalCode,1,nil,93157004)))
end
function s.eftg3(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and ((c:IsOriginalCode(39987164) and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VYLON)) or (c:IsOriginalCode(8958511) and c:GetEquipGroup():IsExists(Card.IsOriginalCode,1,nil,39987164)))
end

-------Epsilon-----------
function s.effcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return c:GetFlagEffect(id)==0 and c:GetFlagEffect(id+1)==0
            and c:GetEquipGroup():IsExists(Card.IsAbleToGraveAsCost,1,nil) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=c:GetEquipGroup():FilterSelect(tp,Card.IsAbleToGraveAsCost,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0) -- restrict to controller only
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetTarget(function(e,te,tp) return te:GetHandler()==e:GetHandler() end)
	e1:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_MONSTER) and re:IsHasType(EFFECT_TYPE_IGNITION) end)
	c:RegisterEffect(e1)
    c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.efftg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.effop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-------Omega-------------


function s.eqfilter(c)
	return c:IsSetCard(SET_VYLON) and c:IsMonster() and not c:IsForbidden()
end
function s.effcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:GetFlagEffect(id)==0 and c:GetFlagEffect(id+2)==0 end
     -- Apply a "cannot activate Ignition" effect for the rest of the turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0) -- restrict to controller only
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetTarget(function(e,te,tp) return te:GetHandler()==e:GetHandler() end)
	e1:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_MONSTER) and re:IsHasType(EFFECT_TYPE_IGNITION) end)
	c:RegisterEffect(e1)
    c:RegisterFlagEffect(id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.efftg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Equip(tp,tc,c,true)
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end

-------Disigma------

function s.effcost3(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:GetFlagEffect(id)==0 and c:GetFlagEffect(id+3)==0 end
     -- Apply a "cannot activate Ignition" effect for the rest of the turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0) -- restrict to controller only
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetTarget(function(e,te,tp) return te:GetHandler()==e:GetHandler() end)
	e1:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_MONSTER) and re:IsHasType(EFFECT_TYPE_IGNITION) end)
	c:RegisterEffect(e1)
    c:RegisterFlagEffect(id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.effopfilter3(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
function s.efftg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.effopfilter3(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.effopfilter3,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.effopfilter3,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.effop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsAttackPos() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,tc,c,true)
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end



-------------------------------------------------------------------------------------




--Global Equip Check
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if re:GetActiveType()==TYPE_EQUIP+TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and not tc:IsSetCard(SET_VYLON) then
		s[rp]=true
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=false
	s[1]=false
end


--2. Cost for add effect: lock Special Summons
function s.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD|REASON_COST)
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,4),nil)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_VYLON)
end

function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	if rc:IsSetCard(SET_VYLON) then return false end
	local ty=re:GetActiveType()
	return (ty&TYPE_EQUIP~=0 and ty&TYPE_SPELL~=0)
end


--Filters
function s.vylon_stzone_filter(c)
	return c:IsSetCard(SET_VYLON) and c:IsPreviousLocation(LOCATION_STZONE)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.vylon_stzone_filter,1,nil) and not s[tp]
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(SET_VYLON) and (c:IsMonster() or c:IsType(TYPE_EQUIP)) and not c:IsForbidden() end,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,function(c) return c:IsSetCard(SET_VYLON) and (c:IsMonster() or c:IsType(TYPE_EQUIP)) and not c:IsForbidden() end,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local target=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		if #target>0 then
		    local trc=target:GetFirst() -- monster to equip to
		    local tc=g:GetFirst()
		    -- try to equip tc to trc
		    if Duel.Equip(tp,tc,trc,true) then
		        -- Equip limit on the EQUIP CARD (tc)
		        local e1=Effect.CreateEffect(tc)
		        e1:SetType(EFFECT_TYPE_SINGLE)
		        e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		        tc:RegisterEffect(e1)
		    else
		        Duel.SendtoGrave(tc,REASON_RULE)
		    end
		end
	end
end


function s.vylon_option_filter(c,e,tp)
	return c:IsSetCard(SET_VYLON) and ((c:IsMonster() and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or (not c:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and (c:IsMonster() or c:IsEquipSpell()) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_VYLON),tp,LOCATION_MZONE,0,1,nil)))
end

--Check non-Vylon Equip this turn
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not s[tp]
end

--Special Summon or Equip from Deck
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.vylon_option_filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.vylon_option_filter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	local can_equip=not tc:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(SET_VYLON) and c:IsMonster() end,tp,LOCATION_MZONE,0,1,nil)
	local can_ss=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if not(can_equip or can_ss) then return end
	local choice=can_equip and can_ss and Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) or (can_ss and 0 or 1)
	if choice==0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		local target=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		if #target>0 then
		    local trc=target:GetFirst() -- monster to equip to
		    -- try to equip tc to trc
		    if Duel.Equip(tp,tc,trc,true) then
		        -- Equip limit on the EQUIP CARD (tc)
		        local e1=Effect.CreateEffect(tc)
		        e1:SetType(EFFECT_TYPE_SINGLE)
		        e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		        tc:RegisterEffect(e1)
		    else
		        Duel.SendtoGrave(tc,REASON_RULE)
		    end
		end
	end
end
function s.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
