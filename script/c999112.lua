--Wizardrake Elaine
--Scripted by IanxWaifu
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Cannot be targeted by opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--change race
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(s.rctg)
	e2:SetOperation(s.rcop)
	c:RegisterEffect(e2)
	--Special Summon Proc
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--ED to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,2})
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(s.edtg)
	e4:SetOperation(s.edop)
	c:RegisterEffect(e4)
end
s.listed_series={0x12A7}
s.listed_names={id}
--Battle Protection
function s.target(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsStatus(STATUS_SPSUMMON_TURN) and (c:GetSummonType()==SUMMON_TYPE_FUSION or c:GetSummonType()==SUMMON_TYPE_PENDULUM)
end

--Change Race
function s.rcfilter(c)
	return c:IsFaceup() and c:GetSummonType()==SUMMON_TYPE_PENDULUM and not c:IsRace(RACE_DRAGON)
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rcfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rcfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.rcfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

--Special Proc
function s.spfilter(c)
	return c:IsDestructable() and c:IsSetCard(0x12A7) and c:IsFaceup() and not c:IsCode(id)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

--ED to hand
function s.edfilter(c)
	return c:IsSetCard(0x12A7) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and c:IsFaceup() and not c:IsCode(id)
end
function s.edtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.edfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.edop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.edfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end