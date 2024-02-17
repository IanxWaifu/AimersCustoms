--Scripted by IanxWaifu
--Daedric Relic, Restraints
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.efilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.efilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.efilter,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler(),tp)
	local tc=g:GetFirst()
	Duel.SetChainLimit(function(e,lp,tp) return e:GetHandler()~=tc end)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.efilter(c,tp)
	local cg=c:GetColumnGroup(1,1)
	return cg:IsExists(s.fgfilter,1,nil,tp)
end
function s.fgfilter(c,tp)
	return c:IsSetCard(0x718) and c:IsOriginalType(TYPE_MONSTER) and c:IsFaceup() and c:GetControler()==tp
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.actcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetCondition(s.actcon)
		tc:RegisterEffect(e2)
	end
end
function s.efilter2(c)
	local cg=c:GetColumnGroup(1,1)
	return cg:IsExists(s.fgfilter2,1,nil)
end
function s.fgfilter2(c)
	return c:IsSetCard(0x718) and c:IsOriginalType(TYPE_MONSTER) and c:IsFaceup()
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.efilter2,tp,LOCATION_ONFIELD,0,1,nil)
end