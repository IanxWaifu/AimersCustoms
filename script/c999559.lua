--Scripted by IanxWaifu
--Voltaic Artifact-Vranögad
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_VOLTAIC))
	Aimer.AddVoltaicEquipEffect(c,id)
	-- Negate Effects of Equipped Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.setcost1)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
end
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC_ARTIFACT}

function s.setcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc==nil then return false end
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

function s.setfilter(c)
    return c:IsSpellTrap() and not c:IsType(TYPE_EQUIP) and not c:IsType(TYPE_FIELD) and (c:IsSetCard(SET_VOLTAIC) or c:IsSetCard(SET_VOLDRAGO))
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local seq=c:GetEquipTarget():GetSequence()
	local check=Duel.CheckLocation(tp,LOCATION_SZONE,seq)
	local b1=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	local b2=true
	if chk==0 then return (#b1>0 and check) or b2 end
	local op=0
	if (#b1>0 and check) and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif (#b1>0 and check) then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local op=e:GetLabel()
    local seq=c:GetEquipTarget():GetSequence()
	local check=Duel.CheckLocation(tp,LOCATION_SZONE,seq)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if op==0 then
	if #g>0 and check then 
	local sc=g:Select(tp,1,1,nil):GetFirst()
	    Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true,1<<seq)
	    sc:SetStatus(STATUS_ACTIVATE_DISABLED,false)
	    sc:SetStatus(STATUS_SET_TURN,true)
	    Duel.RaiseEvent(sc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	    Duel.ConfirmCards(1-tp,sc)
	    local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		sc:RegisterEffect(e2)
	    end
	else
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.rmtarget)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	e2:SetValue(LOCATION_REMOVED)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2),nil)
	end
end

function s.rmtarget(e,c)
	local cg=c:GetColumnGroup()
	return cg:IsContains(e:GetHandler()) and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end









