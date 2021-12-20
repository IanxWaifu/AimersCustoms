--Scripted by IanxWaifu
--Phantom of the Gotheatrè
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect gain extra atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--rem
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12E5))
	e2:SetValue(1)
	e2:SetCondition(s.cond)
	e2:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.cond(e)
	return (Duel.GetTurnPlayer()==e:GetHandlerPlayer()) or (Duel.GetTurnPlayer()==1-tp and Duel.IsPlayerAffectedByEffect(tp,998365))
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ftarget(e,c)
	return not c:IsSetCard(0x12E5)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetTurnCount()~=1 then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,998395,RESET_EVENT+RESET_PHASE+PHASE_END,0,0)
	--Apply Flag
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,id+1)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	e2:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	elseif Duel.GetTurnCount()==1 then
	--Apply Battle Phase First Turn
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_BP_FIRST_TURN)
	e3:SetCountLimit(1,id+2)
	e3:SetValue(1)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	Duel.RegisterFlagEffect(tp,998395,RESET_EVENT+RESET_PHASE+PHASE_END,0,0)
	--Apply Flag
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetTargetRange(1,0)
	e4:SetCountLimit(1,id+3)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	e4:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,998395)>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,998396)>0 then return end
	Duel.RegisterFlagEffect(tp,998396,RESET_EVENT+RESET_PHASE+PHASE_END,0,0)
end

function s.spfilter(c,e,tp)
	local ph=Duel.GetCurrentPhase()
	local top=Duel.GetFieldCard(tp,LOCATION_DECK,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-1)
	return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_DECK) and c:IsFaceup() and c==top)) and c:IsSetCard(0x12E5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and ((Duel.GetTurnPlayer()==tp) or (Duel.GetTurnPlayer()==1-tp and Duel.IsPlayerAffectedByEffect(tp,998365)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then 
		Duel.ConfirmDecktop(tp,1)
		Duel.DisableShuffleCheck()
		local rt=Duel.GetDecktopGroup(tp,1):GetFirst()
		if rt:IsSetCard(0x12E5) then
			Duel.BreakEffect()
			Duel.ShuffleDeck(tp)
			Duel.MoveSequence(rt,0)
			rt:ReverseInDeck()
			Duel.ConfirmDecktop(tp,1)
		elseif not rt:IsSetCard(0x12E5) then 
			Duel.BreakEffect()
			Duel.ShuffleDeck(tp)
			Duel.MoveSequence(rt,1)
		end
	end
end