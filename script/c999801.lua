--Novalxon Transcela
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Apply Astral Shift
	Aimer.AddAstralShift(c)
	--Special Summon 1 "Novalxon" monster from your hand or banishment
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.SelfRevealCost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--2 Summoned Simultaneously
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.seqcon)
	e2:SetTarget(s.seqtg)
	e2:SetOperation(s.seqop)
	c:RegisterEffect(e2)
	--ASTRAL STATE-- Send S/T on field to GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCondition(s.secon)
	e5:SetTarget(s.setg)
	e5:SetOperation(s.seop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_NOVALXON}
s.listed_names={id}
s.astral_shift={id}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NOVALXON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		-- Check if there are leftmost or rightmost zones available
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
			and (Duel.CheckLocation(tp,LOCATION_MZONE,0) or Duel.CheckLocation(tp,LOCATION_MZONE,4))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=0
	-- Check if leftmost zone is available
	if Duel.CheckLocation(tp,LOCATION_MZONE,0) then zone=zone|0x1 end
	-- Check if rightmost zone is available
	if Duel.CheckLocation(tp,LOCATION_MZONE,4) then zone=zone|0x10 end
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end


--Change Zones
function s.zfilter(c,tp)
	return c:IsSetCard(SET_NOVALXON) and c:IsFaceup() and c:IsControler(tp) and c:IsMonster()
end
function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.zfilter,2,nil,tp) and e:GetHandler():GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==0
end
function s.seqfilter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:GetSequence()<5 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.seqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectTarget(tp,s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.HintSelection(tc,true)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ttp=tc:GetControler()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(ttp,LOCATION_MZONE,ttp,LOCATION_REASON_CONTROL)<=0 then return end
	local p1,p2,i
	if tc:IsControler(tp) then
		i=0
		p1=LOCATION_MZONE
		p2=0
	else
		i=16
		p2=LOCATION_MZONE
		p1=0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
end

--Astral Effect
function s.secon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==1
end
function s.spcfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.setg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.seop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_ASTRAL_EFFECT_PROC,e,0,0,0,0)
	e:GetHandler():RegisterFlagEffect(REGISTER_FLAG_ASTRAL_STATE,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET,0,0)
end
