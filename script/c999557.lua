--Scripted by IanxWaifu
--Voltaic Artifact- Molgrav
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_VOLTAIC))
	Aimer.AddVoltaicEquipEffect(c,id)
	-- Negate Effects of Equipped Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	return not Duel.IsPlayerAffectedByEffect(tp,VOLTAICEQUQ)
end
function s.pcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,VOLTAICEQUQ)
end

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

function s.setcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if tc==nil then return false end
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
	Duel.RegisterFlagEffect(tp,VOLTAICEQUQ,RESET_PHASE+PHASE_END,0,1)
end


function s.tgfilter1(c,e,tp)
	return c:GetColumnGroup():IsExists(s.columnfilter1,1,nil,e,tp) and not c:IsDisabled() and c:IsMonster()
end
function s.tgfilter2(c,e,tp)
	return c:GetColumnGroup():IsExists(s.columnfilter2,1,nil,e,tp) and c:IsDestructable(e) and c:IsSpellTrap()
end
function s.columnfilter1(c,e,tp)
	return c:IsControler(tp) and c==e:GetHandler():GetEquipTarget()
end
function s.columnfilter2(c,e,tp)
	return c:IsControler(tp) and c==e:GetHandler()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMatchingGroup(s.tgfilter1,tp,0,LOCATION_MZONE,nil,e,tp)
	local b2=Duel.GetMatchingGroup(s.tgfilter2,tp,0,LOCATION_SZONE,nil,e,tp)
	if chk==0 then return #b1>0 or #b2>0 end
	local op=0
	if #b1>0 and #b2>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif #b1>0 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,1-tp,LOCATION_MZONE)
	else
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_SZONE)
	end
end

function s.desfilter(c,tp)
    return c:IsSpellTrap() and c:IsControler(1-tp)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if not c:IsRelateToEffect(e) then return end
	if op==0 then
		local g=Duel.GetMatchingGroup(s.tgfilter1,tp,0,LOCATION_MZONE,nil,e,tp)
		local tc=g:GetFirst()
	    for tc in aux.Next(g) do
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
	else 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=c:GetColumnGroup():Filter(s.desfilter,nil,tp)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end




