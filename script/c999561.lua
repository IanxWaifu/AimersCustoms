--Scripted by IanxWaifu
--Voltaic Artifact-Vouröis
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

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return true end
    local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    e:SetLabel(op)
end


function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	local eq=c:GetEquipTarget()
	if not c:IsRelateToEffect(e) then return end
	if op==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCountLimit(1,{id,2})
		e1:SetLabelObject(eq)
		e1:SetOperation(s.rthop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	else
		--Cannot be targeted and gain 1000 ATK
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.indtg)
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(s.indtg)
		e3:SetValue(1000)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
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
    return c:IsMonster() and c:GetColumnGroup():IsContains(e:GetHandler()) and c:IsSetCard(SET_VOLTAIC)
end
