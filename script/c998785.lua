--Scripted by IanxWaifu
--Girls'&'Arms - Raensaki
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x12EE),2,3,s.lcheck)
	c:EnableReviveLimit()
	--Negate Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Prvent attack target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	--Effect gain
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(2,id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.announcecost)
	e3:SetCondition(s.cgcon)
	e3:SetTarget(s.cgtg)
	e3:SetOperation(s.cgop)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	--Effect gain
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(2,id)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(s.announcecost)
	e5:SetCondition(s.cgcon2)
	e5:SetTarget(s.cgtg2)
	e5:SetOperation(s.cgop)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(s.eftg2)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_LINK,lc,sumtype,tp)
end
--Negate Target Condition
function s.cfilter(c,p)
	return c:IsFaceup() and c:IsLinkMonster() and c:GetMutualLinkedGroupCount()>=1
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():GetFlagEffect(id)==0
end
--Send S/T to Negate
function s.sendfilter(c,e,tp)
	return c:IsSetCard(0x12EF) and c:IsAbleToGrave() and c:IsType(TYPE_SPELL+TYPE_TRAP) and ((c:IsLocation(LOCATION_SZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_DECK))
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_SZONE+LOCATION_DECK,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.Hint(HINT_CARD,0,id) 
		local tg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_SZONE+LOCATION_DECK,0,1,1,nil,tp)
		local tc=tg:GetFirst()
		Duel.SendtoGrave(tc,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.NegateEffect(ev)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end

--Attack Target Condition
function s.atkcon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end

--Effect Gain - Target Destruction
function s.eftg(e,c)
	local g=e:GetHandler():GetLinkedGroup()
	return c:IsSetCard(0x12EE) and g:IsContains(c) and c:GetMutualLinkedGroupCount()==0
end
function s.eftg2(e,c)
	local g=e:GetHandler():GetLinkedGroup()
	return c:IsSetCard(0x12EE) and g:IsContains(c) and c:GetMutualLinkedGroupCount()>0
end
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.cgfilter(c,g)
	return g:IsContains(c)
end
function s.cgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	local c=e:GetHandler()
	if chkc then return s.cgfilter(chkc,cg) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(s.cgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),cg) and e:GetHandler():IsReleasableByEffect()  end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.cgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),cg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.cgtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	local c=e:GetHandler()
	if chkc then return s.cgfilter(chkc,cg) and chkc:IsOnField() end
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.IsExistingTarget(s.cgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),cg) and e:GetHandler():IsReleasableByEffect()  end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	local g=Duel.SelectTarget(tp,s.cgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),cg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.cgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsReleasableByEffect() then return end
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	if Duel.Release(c,REASON_EFFECT)>0 and tc and tc:IsRelateToEffect(e) then 
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--Quick Effect Checks
function s.cgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()==0
end
function s.cgcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
