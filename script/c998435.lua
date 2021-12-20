--Scripted by IanxWaifu
--Gotheatrè, Priscilla
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Top Deck Faceup
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Send monster eff
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.condition)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	--Send attack
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e5:SetCountLimit(1,{id,2})
	e5:SetCost(s.cost)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x12E5)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:GetHandler():IsSetCard(0x12E5)
end
function s.thfilter(c)
	return c:IsSetCard(0x12E5) and not c:IsCode(id) and not c:IsFaceup()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)  end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #hg>0 then
		local tc=hg:GetFirst()
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
		tc:ReverseInDeck()
		if tc:IsFaceup() and tc:IsLocation(LOCATION_DECK) then
			local tg=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
    		local tg2=tg:GetFirst()
			for tg2 in aux.Next(tg) do
	   		local e1=Effect.CreateEffect(c)
       		e1:SetType(EFFECT_TYPE_SINGLE)
       		e1:SetCode(EFFECT_UPDATE_ATTACK)
       		e1:SetValue(300)
       		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
       		tg2:RegisterEffect(e1)
       		local e2=e1:Clone()
       		e2:SetCode(EFFECT_UPDATE_DEFENSE)
        	tg2:RegisterEffect(e2)
		end
			local e2=Effect.CreateEffect(c)
   			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
   			e2:SetCode(EVENT_SUMMON_SUCCESS)
   			e2:SetProperty(EFFECT_FLAG_DELAY)
   			e2:SetReset(RESET_PHASE+PHASE_END,2)
  			e2:SetCondition(s.hcondition)
   			e2:SetTarget(s.htarget)
    		e2:SetOperation(s.hoperation)
    		Duel.RegisterEffect(e2,tp)
    		local e3=e2:Clone()
    		e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    		e3:SetCondition(s.hcondition2)
    		Duel.RegisterEffect(e3,tp)
    		local e4=e2:Clone()
    		e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    		Duel.RegisterEffect(e4,tp)
		end
	end
end
function s.atkfilter(c)
	return c:IsFaceup()  and c:IsSetCard(0x12E5)
end
function s.hcondition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(aux.FilterFaceupFunction(Card.IsSetCard,0x12E5),1,nil)
end
function s.hcondition2(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and eg:GetFirst():IsSetCard(0x12E5)
end
function s.htarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=eg:GetFirst()
    if chk==0 then return tc:IsControler(tp) end
    tc:CreateEffectRelation(e)
end
function s.hoperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=eg:GetFirst()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(300)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
    end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():GetAttack()<re:GetHandler():GetBaseAttack() and re:GetHandler():IsOnField() and rp~=tp
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if not (tc:IsControler(1-tp) or bc:IsControler(1-tp)) then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if (tc:IsFaceup() and tc:IsSetCard(0x12E5) and tc:IsControler(tp) and tc:GetBaseAttack()<tc:GetAttack())
		or (bc:IsFaceup() and bc:IsSetCard(0x12E5) and bc:IsControler(tp) and bc:GetBaseAttack()<tc:GetAttack()) then
		e:SetLabelObject(bc)
		return true
	end
	return false
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end