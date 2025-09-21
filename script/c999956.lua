--Kyoshin - Enbu no Yorihime
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon procedure
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ILLUSION),aux.FilterBoolFunctionEx(Card.IsType,TYPE_RITUAL))
	--Negate after Ritual Monster is Special Summoned by effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Check if this card was used as Ritual Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_ALL)
	e2:SetCondition(s.matcon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}

--Check if the resolved chain Special Summoned a Ritual Monster
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:IsType(TYPE_RITUAL)
		and c:IsLocation(LOCATION_MZONE)
		--[[and c:IsSummonPlayer(tp)--]]
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>2 then return false end
	if not re then return false end
	local g=Duel.GetOperatedGroup()
	return g:IsExists(s.cfilter,1,nil)
end

-- Disable when this card was used as Ritual Material
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetFlagEffect(tp,id)>2 then return false end
    if not re then return false end
    if not (c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_RITUAL)) then return false end
    return c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED)
        or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup())
end

function s.disfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)<2 and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local tc=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	    if tc and tc:IsFaceup() and not tc:IsDisabled() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	        local e1=Effect.CreateEffect(e:GetHandler())
	        e1:SetType(EFFECT_TYPE_SINGLE)
	        e1:SetCode(EFFECT_DISABLE)
	        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	        tc:RegisterEffect(e1)
	        local e2=Effect.CreateEffect(e:GetHandler())
	        e2:SetType(EFFECT_TYPE_SINGLE)
	        e2:SetCode(EFFECT_DISABLE_EFFECT)
	        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	        tc:RegisterEffect(e2)
	    end
	end
end