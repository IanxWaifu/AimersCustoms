--Sylvestrie Nalupi
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.matcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_SYLVESTRIE}

--Cannot use Self due to discard cost.
function s.forcedselection(e,tp,g,sc)
	local c=e:GetHandler()
	return not g:IsContains(c),g:IsContains(c)
end


--Field Spell Counter
function s.fs_count(tp)
	local ct=0
	local f1=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local f2=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
	if f1 and f1:IsSetCard(SET_SYLVESTRIE) then ct=ct+1 end
	if f2 and f2:IsSetCard(SET_SYLVESTRIE) then ct=ct+1 end
	return ct
end


--Add from GY
function s.ritfilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end

function s.can_add(e,tp)
	return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.do_add(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end



--Ritual Function Helper

function s.get_ritual_funcs(e)
	local c=e:GetHandler()
	local ritual_target_params={handler=c,lvtype=RITPROC_GREATER,filter=function(ritual_c) return ritual_c:IsSetCard(SET_SYLVESTRIE) and ritual_c~=c end,forcedselection=s.forcedselection}
	local ritual_operation_params={handler=c,lvtype=RITPROC_GREATER,filter=function(ritual_c) return ritual_c:IsSetCard(SET_SYLVESTRIE) end}
	local rittg=Ritual.Target(ritual_target_params)
	local ritop=Ritual.Operation(ritual_operation_params)
	return rittg,ritop
end

--Fusion Function Helper
function s.get_fusion_funcs(e)
	local c=e:GetHandler()
	local fparams={handler=c,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_SYLVESTRIE),extrafil=s.fextra,extraop=s.fusextraop,extratg=s.fusextratg}
	local fustg=Fusion.SummonEffTG(table.unpack(fparams))
	local fusop=Fusion.SummonEffOP(table.unpack(fparams))
	return fustg,fusop
end

--Ritual Check
function s.can_ritual(e,tp)
	local rittg,_=s.get_ritual_funcs(e)
	return rittg(e,tp,0,0,0,nil,0,tp,0)
end

--Fusion Check
function s.can_fusion(e,tp)
	local fustg,_=s.get_fusion_funcs(e)
	return fustg(e,tp,0,0,0,nil,0,tp,0)
end



--Apply Valid Effect Checks
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.can_add(e,tp) or s.can_ritual(e,tp) or s.can_fusion(e,tp)
	end
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	local max=s.fs_count(tp)+1
	local applied=0
	local rittg,ritop=s.get_ritual_funcs(e)
	local fustg,fusop=s.get_fusion_funcs(e)
	-- 1. ADD
	if applied<max and s.can_add(e,tp) then
		s.do_add(e,tp)
		applied=applied+1
	end
	-- 2. RITUAL
	if applied<max and rittg(e,tp,eg,ep,ev,re,r,rp,0) then
		Duel.BreakEffect()
		ritop(e,tp,eg,ep,ev,re,r,rp)
		applied=applied+1
	end
	-- 3. FUSION
	if applied<max and fustg(e,tp,eg,ep,ev,re,r,rp,0) then
		Duel.BreakEffect()
		fusop(e,tp,eg,ep,ev,re,r,rp)
		applied=applied+1
	end
end

--Be Material
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:GetReasonCard():IsSetCard(SET_SYLVESTRIE) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SYLVESTRIE) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end