--Scripted by IanxWaifu
--Gotheatrè Désarroi et Corbeau Perdu
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetCondition(s.condition)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x12E5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and eg:IsExists(s.filter,1,nil,tp)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsSetCard(0x12E5)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(s.avfilter)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetReset(RESET_EVENT+PHASE_END)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	Duel.RegisterEffect(e2,tp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabelObject()
	if ac and ac:IsRelateToBattle() then
		local atk=ac:GetAttack()
		local def=ac:GetDefense()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ac:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(def/2)
		ac:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		ac:RegisterEffect(e3,true)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		ac:RegisterEffect(e4,true)
		local e5=e3:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		ac:RegisterEffect(e5,true)
		local e6=e3:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		ac:RegisterEffect(e6,true)
		ac:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not ac then return false end
	e:SetLabelObject(ac)
	return ac:IsControler(1-tp) and bc:IsFaceup() and bc:IsSetCard(0x12E5) and bc:IsControler(tp)
end
function s.avfilter(e,c)
	return c:IsSetCard(0x12E5) 
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.spfilter(c,e,tp,turn)
	return c:IsSetCard(0x12E5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetTurnID()==turn
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local turn=Duel.GetTurnCount()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,turn) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local turn=Duel.GetTurnCount()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,turn)
	if #g>0 and	Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		g:GetFirst():RegisterEffect(e1,true)
	end
end