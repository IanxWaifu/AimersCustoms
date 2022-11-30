--Scripted by IanxWaifu
--Wizardrake Conviction
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Destroy Place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
end

--Destroy
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x12A7) and c:IsDestructable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g2>0 and aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,chk) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.rfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_DESTROY)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #sg>0 and Duel.Destroy(sg,REASON_EFFECT)>0 and #dg>0 then
		local rg=sg:Filter(s.rfilter,nil)
		if #rg>0 then
			local count=rg:GetCount()
			Duel.BreakEffect()
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tc=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,count,nil)
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end

--Pend Place
function s.penfilter(c)
	return c:IsOriginalType(TYPE_PENDULUM) and c:IsOriginalType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0):Select(tp,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_DECK,0,nil)
		local tc=sg:Select(tp,1,1,nil)
		local tc2=tc:GetFirst()
		if tc2 then
			Duel.MoveToField(tc2,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
