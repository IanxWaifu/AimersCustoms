--Novalxon Chronosia
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
	--ASTRAL STATE-- Send 1 "Novalxon" from Deck to GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCondition(s.tgcon)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_NOVALXON}
s.listed_names={id}
s.astral_shift={id}

function s.cfilter(c,e,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToRemove() and c:IsSetCard(SET_NOVALXON)
	and Duel.IsExistingMatchingCard(s.cdspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end

function s.cdspfilter(c,e,tp,code)
	return not c:IsCode(code) and c:IsSetCard(SET_NOVALXON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=0
	-- Check if leftmost zone is available
	local lz=Duel.CheckLocation(tp,LOCATION_MZONE,0)
	if lz then zone=zone|0x1 end
	-- Check if rightmost zone is available
	local rz=Duel.CheckLocation(tp,LOCATION_MZONE,4)
	if rz then zone=zone|0x10 end
	if zone==0 then return end
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,e,tp)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #sg>=1 and Duel.IsExistingMatchingCard(s.cdspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sg:GetFirst():GetCode())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=0
	local lz=Duel.CheckLocation(tp,LOCATION_MZONE,0)
	if lz then zone=zone|0x1 end
	local rz=Duel.CheckLocation(tp,LOCATION_MZONE,4)
	if rz then zone=zone|0x10 end
	if zone==0 then return end
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,e,tp)
	if not lz or not rz then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=sg:FilterSelect(tp,function(c) return c:IsLocation(LOCATION_MZONE) and (c:GetSequence()==0 or c:GetSequence()==4) end,1,1,nil)
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local fg=Duel.SelectMatchingCard(tp,s.cdspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g:GetFirst():GetCode())
			if #fg>0 then
				fg:AddCard(c)
				Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP,0x1|0x10)
			end
		end
	elseif lz or rz then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=sg:Select(tp,1,1,nil)
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local fg=Duel.SelectMatchingCard(tp,s.cdspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g:GetFirst():GetCode())
			if #fg>0 then
				fg:AddCard(c)
				Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP,0x1|0x10)
			end
		end
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
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==1
end
function s.tgfilter(c)
	return c:IsSetCard(SET_NOVALXON) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_ASTRAL_EFFECT_PROC,e,0,0,0,0)
	e:GetHandler():RegisterFlagEffect(REGISTER_FLAG_ASTRAL_STATE,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET,0,0)
end
