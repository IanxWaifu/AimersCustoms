--Scripted by IanxWaifu
--Gotheatrè Elizabeth
local s,id=GetID()
function s.initial_effect(c)
	--Continuous Spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
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
	--To Hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.addcon)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)==0) or (Duel.GetTurnPlayer()==1-tp and Duel.IsPlayerAffectedByEffect(tp,998365) and e:GetHandler():GetFlagEffect(id)==0)
end
function s.cfilter1(c,e,tp)
	return c:IsSetCard(0x12E5) and c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp,c:GetCode())		
end
function s.cfilter2(c,e,tp,code)
	return c:IsSetCard(0x12E5) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_ONFIELD,0,nil,e,tp,c:GetCode())
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp,c:GetCode())
	e:SetLabel(g:GetFirst():GetCode())
	local tc=g:GetFirst()
	if tc and c:GetFlagEffect(id)==0 and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter2),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp,e:GetLabel())
		if #g2>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
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
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.ttfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.DisableShuffleCheck()
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
		tc:ReverseInDeck()
		e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end



function s.addfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x12E5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsReason(REASON_EFFECT) 
	and c:IsPreviousLocation(LOCATION_DECK)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.addfilter,1,nil,tp) and e:GetHandler():GetFlagEffect(id+1)>=1
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:FilterSelect(tp,s.addfilter,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) and tc:IsAbleToHand() then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
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
function s.atkfilter(c)
	return c:IsFaceup()  and c:IsSetCard(0x12E5)
end
function s.hcondition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(aux.FaceupFilter(Card.IsSetCard,0x12E5),1,nil)
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