--Scripted by IanxWaifu
--2nd Iron Saga Chronicle - Maelstrom
local s,id=GetID()
function s.initial_effect(c)
	--Return and SP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--To Grave + Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--Return in the End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1105)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(Spirit.MandatoryReturnCondition)
	e3:SetTarget(Spirit.MandatoryReturnTarget)
	e3:SetOperation(Spirit.ReturnOperation)
	c:RegisterEffect(e3)
	--Optional return in case of "SPIRIT_MAYNOT_RETURN" effects
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCondition(Spirit.OptionalReturnCondition)
	e4:SetTarget(Spirit.OptionalReturnTarget)
	c:RegisterEffect(e4)
	--Effects that register the flags
	local feffs={}
	for _,event in ipairs{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP} do
		local fe1=Effect.CreateEffect(c)
		fe1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		fe1:SetCode(event)
		fe1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		fe1:SetOperation(Spirit.SummmonRegister)
		c:RegisterEffect(fe1)
		table.insert(feffs,fe1)
	end
	return e3,e4,table.unpack(feffs)
end
s.listed_series={0x12EC}
s.ordinal_scale={998920,998922}
Spirit={}
FLAG_SPIRIT_RETURN=2

function Spirit.SummmonRegister(e,tp,eg,ep,ev,re,r,rp)
	local event=e:GetCode()
	local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END
	if event~=EVENT_FLIP_SUMMON_SUCCESS and event~=EVENT_FLIP then
		reset=reset&~(RESET_TEMP_REMOVE|RESET_LEAVE)
	end
	e:GetHandler():RegisterFlagEffect(FLAG_SPIRIT_RETURN,reset,0,1)
end

function Spirit.CommonCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(FLAG_SPIRIT_RETURN)>0 and not c:IsHasEffect(EFFECT_SPIRIT_DONOT_RETURN) and e:GetHandler():GetFlagEffect(998932)==0
end

function Spirit.MandatoryReturnCondition(e,tp,eg,ep,ev,re,r,rp)
	return Spirit.CommonCondition(e) and not e:GetHandler():IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN) and e:GetHandler():GetFlagEffect(998932)==0
end

function Spirit.MandatoryReturnTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function Spirit.OptionalReturnCondition(e,tp,eg,ep,ev,re,r,rp)
	return Spirit.CommonCondition(e) and e:GetHandler():IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN) and e:GetHandler():GetFlagEffect(998932)==0
end

function Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function Spirit.ReturnOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
	return c:IsCode(998921,998920,998922) and c:IsSetCard(0x12EC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(998932,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		--leave replace
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e1:SetCode(EFFECT_SEND_REPLACE)
		e1:SetTarget(s.reptg)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (r&REASON_EFFECT)~=0 and re and re:IsActiveType(TYPE_MONSTER) end
	return true
end


function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(998932)>0
end
function s.tgfilter(c)
	return c:IsSetCard(0x12EC) and c:IsAbleToGrave()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>1
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)

end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg1=g:Select(tp,1,1,nil)
	g:Remove(Card.IsCode,nil,tg1:GetFirst():GetCode())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg2=g:Select(tp,1,1,nil)
	tg1:Merge(tg2)
	if Duel.SendtoGrave(tg1,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local des=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
		if #des>0 then
			Duel.Destroy(des,REASON_EFFECT)
		end
	end
end