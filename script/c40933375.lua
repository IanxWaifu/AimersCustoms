local s,id=GetID()
function s.initial_effect(c)
	--inaff
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,2,e:GetHandler())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local ph=Duel.GetCurrentPhase()
	for tc in aux.Next(dg) do
		if tc:IsRelateToEffect(e) and tc:IsOnField() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+(ph)+RESET_EVENT+0x1fc0000)
		e1:SetValue(s.efilter)
		tc:RegisterEffect(e1)
		end
	end
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end