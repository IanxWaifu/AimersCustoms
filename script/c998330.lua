--Scripted by IanxWaifu
--Gotheatrè Emma
local s,id=GetID()
function s.initial_effect(c)
	--Continuous Add
	local e1=Effect.CreateEffect(c)
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
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ttcon)
	e2:SetTarget(s.tttg)
	e2:SetOperation(s.ttop)
	c:RegisterEffect(e2)
	--discard deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)==0) or (Duel.GetTurnPlayer()==1-tp and Duel.IsPlayerAffectedByEffect(tp,998365) and e:GetHandler():GetFlagEffect(id)==0)
end
function s.filter(c)
	return c:IsSetCard(0x12E5) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g and e:GetHandler():GetFlagEffect(id)==0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.ttcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.GetFlagEffect(tp,998396)>0
end
function s.ttfilter(c)
	return c:IsSetCard(0x12E5)
end
function s.tttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ttfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
	end
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.ttfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
		tc:ReverseInDeck()
		e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12E5) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_DECK,0,1,nil)
	and e:GetHandler():GetFlagEffect(id+1)>=1
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and e:GetHandler():GetFlagEffect(id+1)>=1 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p,d,REASON_EFFECT)
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