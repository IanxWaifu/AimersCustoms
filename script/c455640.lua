--Neko Neko C&V Samurai
function c455640.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,{455552,455554},aux.FilterBoolFunctionEx(Card.IsSetCard,0x1194))
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(455640,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,455640)
	e1:SetCondition(c455640.atkcon)
	e1:SetTarget(c455640.atktg)
	e1:SetOperation(c455640.atkop)
	c:RegisterEffect(e1)
	--ToDeck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94380860,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,455641)
	e2:SetTarget(c455640.tdtg)
	e2:SetOperation(c455640.tdop)
	c:RegisterEffect(e2)
end
function c455640.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function c455640.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function c455640.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c455640.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function c455640.tffilter(c,tp)
	return c:IsSetCard(0x1194) and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS or c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:GetActivateEffect():IsActivatable(tp)
end
function c455640.atkfilter2(c)
	return c:IsFaceup() and c:GetAttack()~=c:GetBaseAttack()
end
function c455640.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c455640.atkfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
      while tc do
        local atk=tc:GetAttack()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
	if Duel.GetMatchingGroupCount(c455640.atkfilter2,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>=3 then
	local g2=Duel.GetMatchingGroup(c455640.tffilter,tp,LOCATION_DECK,0,nil,tp)
	if g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(455640,1)) then 
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sc=g2:Select(tp,1,1,nil):GetFirst()
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=sc:GetActivateEffect()
			local tep=sc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			Duel.RaiseEvent(sc,EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
function c455640.tdfilter(c)
	return c:GetAttack()~=c:GetBaseAttack()
end
function c455640.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c455640.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c455640.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c455640.tdfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c455640.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end