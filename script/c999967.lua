--Kyoshin - Kegareta Hörin
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon procedure
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ILLUSION),aux.FilterBoolFunctionEx(Card.IsType,TYPE_RITUAL))
	--Place to field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tfcon)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.matcon)
	e2:SetTarget(s.tftg)
	e2:SetOperation(s.tfop)
	c:RegisterEffect(e2)
	--be spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--SelfFusion
	local fparams={handler=c,filter=aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),extrafil=s.fextra,extratg=s.fusextratg,gc=Fusion.ForcedHandler}
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,{id,1})
	e4:SetRange(LOCATION_MZONE|LOCATION_SZONE)
	e4:SetCondition(s.effcon)
	e4:SetTarget(Fusion.SummonEffTG(fparams))
	e4:SetOperation(Fusion.SummonEffOP(fparams))
	c:RegisterEffect(e4)
end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}
s.ritual_material_required=1

--Check if the resolved chain Special Summoned a Ritual Monster
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_RITUAL)
end


-- Disable when this card was used as Ritual Material
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re then return false end
    if not (c:IsReason(REASON_MATERIAL) and c:IsReason(REASON_RITUAL)) then return false end
    return c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED)
        or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup())
end

function s.tffilter(c,tp)
	return not c:IsForbidden() and c:ListsArchetype(SET_KYOSHIN) and (c:IsType(TYPE_FIELD) or (c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0)) and c:CheckUniqueOnField(tp)
end

function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if tc:IsType(TYPE_FIELD) then
		    Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
		else
		    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
 		end
	end
end

--Selffusion
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():IsFusionSummoned()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end

function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0
end

-- Fusion
function s.fextra(e,tp,mg)
    local eg=Group.CreateGroup()
    if Duel.IsPlayerAffectedByEffect(tp,999960) then
        local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
        if #sg>0 then eg:Merge(sg) end
    end
    if #eg>0 then return eg end
    return nil
end

function s.fusextratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_STZONE)
end 

function s.exfilter(c)
    return (c:IsMonster() or c:IsOriginalType(TYPE_MONSTER)) and c:IsSetCard(SET_KYOSHIN) and c:IsAbleToGrave() and c:HasLevel()
end
