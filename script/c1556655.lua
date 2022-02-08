--Jackpot Shot
--Scripted by IanxWaifu aka Aimer
local s,id=GetID()
function s.initial_effect(c)
	--disable spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TODECK)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and eg:GetCount()==1 and Duel.GetCurrentChain()==0
end
function s.cfilter(c,e,tp,lp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSummonPlayer()==1-tp
		and (not e or c:IsRelateToEffect(e)) and lp>c:GetAttack() and c:GetAttack()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,eg:GetCount(),0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	local atk=tc:GetAttack()
	if atk and atk>0 and Duel.PayLPCost(tp,atk)~=0 then
	Duel.BreakEffect()
	Duel.NegateSummon(tc)
	Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
end
end
