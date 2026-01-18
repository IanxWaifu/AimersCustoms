--Kyoshin - Saimyö no Mikoha
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
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rthcon)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
	--Check if this card was used as Ritual Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_ALL)
	e2:SetCondition(s.matcon)
	e2:SetOperation(s.rthop)
	c:RegisterEffect(e2)
	--be spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--Selfsend
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,{id,1})
	e4:SetRange(LOCATION_MZONE|LOCATION_SZONE)
	e4:SetCost(Cost.SelfToGrave)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}
s.ritual_material_required=1

--Check if the resolved chain Special Summoned a Ritual Monster
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and c:IsType(TYPE_RITUAL)
		and c:IsLocation(LOCATION_MZONE)
		--[[and c:IsSummonPlayer(tp)--]]
end
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>1 then return false end
	if not re then return false end
	local g=Duel.GetOperatedGroup()
	return g:IsExists(s.cfilter,1,nil)
end

-- Disable when this card was used as Ritual Material
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetFlagEffect(tp,id)>1 then return false end
    if not re then return false end
    if not (c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_RITUAL)) then return false end
    return c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED)
        or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup())
end

function s.rthfilter(c)
	return c:IsAbleToHand()
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)<1 and Duel.IsExistingTarget(s.rthfilter,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_CARD,0,id)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local tc=Duel.SelectTarget(tp,s.rthfilter,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if tc then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
	    end
	end
end

--Selfreturn
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():IsFusionSummoned()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0
end

function s.setfilter(c,e)
	return c:IsSetCard(SET_KYOSHIN) and c:IsSpellTrap()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loccount=0
	if e:GetHandler():IsLocation(LOCATION_SZONE) then loccount=loccount-1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>loccount and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end

