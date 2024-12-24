--Scripted by IanxWaifu
--Voltaic Artifact- Drangïr
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

function s.tgfilter2(c,e,tp)
	return c:GetColumnGroup():IsExists(s.columnfilter2,1,nil,e,tp)  and c:IsMonster()
end
function s.columnfilter1(c,e,tp)
	return c:IsControler(tp) and c==e:GetHandler():GetEquipTarget()
end
function s.columnfilter2(c,e,tp)
	return c:IsControler(tp) and c==e:GetHandler()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=true
    local b2=true
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end
    e:SetLabel(op)
    if op==0 then
        local c=e:GetHandler()
        local eq=c:GetEquipTarget()
        if eq then
            local cards=eq:GetColumnGroup()
            local tc=cards:GetFirst()
	    	for tc in aux.Next(cards) do
	            if tc:IsControler(1-tp) then
	                Duel.SetChainLimit(s.chainlimit(tc))
	            end
	        end
	    end
	end
end
function s.chainlimit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end

function s.desfilter(c,tp)
    return c:IsSpellTrap() and c:IsControler(1-tp)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	local eq=c:GetEquipTarget()
	if not c:IsRelateToEffect(e) then return end
	if op==0 then
		--Cannot activate Spell/Traps in eqs card's column's Spell & Trap Zones
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,LOCATION_SZONE)
		e1:SetLabelObject(eq)
		e1:SetValue(s.distg)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetLabelObject(eq)
		e2:SetTarget(s.actfilter)
		e2:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e2,tp)
	else 
		--Cannot be used as material for a Fusion/Synchro/Xyz/Link Summon
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetTarget(function(e,c) return e:GetHandler():GetColumnGroup():IsContains(c) end)
		e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		e3:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e3,tp)
	end
end

function s.disfilter(c)
	return c:IsSpellTrap()
end
function s.distg(e,re,tp)
	local tc=re:GetHandler()
	local cc=e:GetLabelObject():GetColumnGroup()
	local cg=cc:Match(s.disfilter,nil,tp)
	return cg and cc:IsContains(tc)
end
function s.actfilter(e,c)
	local cc=e:GetLabelObject():GetColumnGroup()
	local cg=cc:Match(s.disfilter,nil)
	return cg and cc:IsContains(c) and c:IsControler(1-e:GetHandlerPlayer()) and c:IsSpellTrap()
end