--Scripted by IanxWaifu
--Stellarius Aclimation
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--att gain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local check=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local ct=check:GetClassCount(Card.GetAttribute)
	if Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) and ct>=4 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
		local tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local tg=tc:Filter(Card.IsRelateToEffect,nil,e)
		if #tg>0 then
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end

function s.attfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12D9)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.attfilter(chkc) and chkc:IsDifferentAttribute(e:GetLabel()) end
	if chk==0 then return Duel.IsExistingTarget(s.attfilter,tp,LOCATION_MZONE,tp,1,nil) end
	local g=Duel.GetMatchingGroup(aux.AND(s.attfilter,Card.IsCanBeEffectTarget),tp,LOCATION_MZONE,tp,nil,e)
	local att=Duel.AnnounceAnotherAttribute(g,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sel=g:FilterSelect(tp,Card.IsDifferentAttribute,1,1,nil,att)
	Duel.SetTargetCard(sel)
	e:SetLabel(att)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end