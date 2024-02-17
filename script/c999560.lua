--Scripted by IanxWaifu
--Voltaic Artifact-Zuriväl
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_VOLTAIC))
	Aimer.AddVoltaicEquipEffect(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.setcost1)
	e1:SetCondition(s.pcon1)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(s.setcost2)
	e2:SetCondition(s.pcon2)
	c:RegisterEffect(e2)
end
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC_ARTIFACT}

function s.pcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp)
end
function s.pcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,VOLTAICEQUQ) and ((Duel.IsMainPhase() and Duel.GetCurrentChain(true)>=0) or not (Duel.IsMainPhase()) or (Duel.IsTurnPlayer(1-tp)))
	and Duel.GetFlagEffect(tp,999564)==0
end

function s.setcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if not tc:IsFaceup() or tc:IsDisabled() then return false end
	if chk==0 then return tc:IsFaceup() and not tc:IsDisabled() end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end

function s.setcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if not tc:IsFaceup() or tc:IsDisabled() or Duel.GetFlagEffect(tp,VOLTAICEQUQ)>0 then return false end
	if chk==0 then return tc:IsFaceup() and not tc:IsDisabled() and Duel.GetFlagEffect(tp,VOLTAICEQUQ)==0 end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	Duel.RegisterFlagEffect(tp,999564,RESET_PHASE+PHASE_END,0,1)
end

function s.setfilter(c,e,tp)
    return c:IsMonster() and c:IsSetCard(SET_VOLTAIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,zone)
end



function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	local eq=c:GetEquipTarget()
    local seq=c:GetSequence()
	local zone=(1<<seq)
	local check=Duel.CheckLocation(tp,LOCATION_MZONE,seq)
	local b1=true
    local b2=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,zone)
    if chk==0 then return b1 or (#b2>0 and check) end
    local op=0
    if b1 and (#b2>0 and check) then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end
    e:SetLabel(op)
    if op==0 then
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,1-tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,nil,1,1-tp,LOCATION_MZONE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
	end
end


function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	local eq=c:GetEquipTarget()
	if not c:IsRelateToEffect(e) then return end
	if op==0 then
		--ATK/DEF become 0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetTarget(s.indtg)
		e1:SetLabelObject(eq)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
	    e2:SetCode(EFFECT_SET_DEFENSE)
	    c:RegisterEffect(e2)
	else
		local seq=c:GetSequence()
		local zone=(1<<seq)
		local check=Duel.CheckLocation(tp,LOCATION_MZONE,seq)
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,zone)
		if #g>0 and check then 
			local sc=g:Select(tp,1,1,nil):GetFirst()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end


function s.rthop(e, tp, eg, ep, ev, re, r, rp)
    local eq = e:GetLabelObject() -- Retrieve the equipped monster
    local dg = eq:GetColumnGroup():Filter(Card.IsControler, nil, 1 - tp)
    if not e:GetHandler():GetEquipTarget()==eq then return end
    if #dg > 0 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		Duel.Hint(HINT_CARD,0,id)
		if Duel.SendtoHand(dg,nil,REASON_EFFECT)~=0 then
	        Duel.BreakEffect()
			Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
    end
end








function s.rthop(e, tp, eg, ep, ev, re, r, rp)
    local eq = e:GetLabelObject() -- Retrieve the equipped monster
    local dg = eq:GetColumnGroup():Filter(Card.IsControler, nil, 1 - tp)
    if not e:GetHandler():GetEquipTarget()==eq then return end
    if #dg > 0 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		Duel.Hint(HINT_CARD,0,id)
		if Duel.SendtoHand(dg,nil,REASON_EFFECT)~=0 then
	        Duel.BreakEffect()
			Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
    end
end


function s.indtg(e, c)
	local eq=e:GetLabelObject()
    return c:IsMonster() and c:GetColumnGroup():IsContains(eq)
end
