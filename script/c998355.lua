--Scripted by IanxWaifu
--Gotheatrè Adelia
local s,id=GetID()
function s.initial_effect(c)
	--Continuous Add
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCondition(s.addcon)
	e1:SetTarget(s.addtg)
	e1:SetOperation(s.addop)
	c:RegisterEffect(e1)
	--Declare Attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.rvcon)
	e2:SetTarget(s.rvtg)
	e2:SetOperation(s.rvop)
	c:RegisterEffect(e2)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)==0) or (Duel.GetTurnPlayer()==1-tp and Duel.IsPlayerAffectedByEffect(tp,998365) and e:GetHandler():GetFlagEffect(id)==0)
end
function s.filter(c)
	return c:IsSetCard(0x12E5) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g and e:GetHandler():GetFlagEffect(id)==0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.rvcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.GetFlagEffect(tp,998396)>0
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if #g<=0 then return end
	Duel.ConfirmDecktop(tp,1)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if tc:IsSetCard(0x12E5) then
		if tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSetCard(0x12E5) and tc:IsAbleToGrave() then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT)
	elseif tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0x12E5) then
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
		Duel.DisableShuffleCheck()
		Duel.MoveSequence(tc,0)
		tc:ReverseInDeck()
	elseif not tc:IsSetCard(0x12E5) then
		Duel.DisableShuffleCheck()
		Duel.MoveSequence(tc,1)
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