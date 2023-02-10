                                                                                                                                                                                                                                                                                                     --Scripted by IanxWaifu
--Sacred Seal- Second Star Relic
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={0x12A8,0x12A9}

--Apply Continuous
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--chain resolve attach
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAIN_ACTIVATING)
	e1:SetCondition(s.rmcon)
	e1:SetOperation(s.rmop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--activate cost
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_ACTIVATING)
	e2:SetCondition(s.costcon)
	e2:SetTarget(s.costtg)
	e2:SetOperation(s.costop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	--Cannot trigger
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.acttg)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

--Remove
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsType(TYPE_XYZ) and re:GetHandler():IsSetCard(0x12A9)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	if #g<=0 or rp~=tp or not re:GetHandler():IsType(TYPE_XYZ) or not re:GetHandler():IsSetCard(0x12A9) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Hint(HINT_CARD,0,id)
		local sg=g:Select(tp,1,1,nil)
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT) 
	end
end

--Must lose ATK
function s.costcon(e,tp,eg,ep,ev,re,r,rp)
	local eff=re:GetHandler()
    return eff:GetAttack()>=1000 and eff:IsFaceup() and eff:IsOnField() and eff:IsMonster() and eff:IsControler(1-tp) and not eff:IsImmuneToEffect(e)
end
function s.costtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=re:GetHandler()
    if chk==0 then return tc:IsControler(1-tp) end
    tc:CreateEffectRelation(e)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=re:GetHandler()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:GetAttack()<1000 or not tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-1000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
    tc:RegisterEffect(e1)
end

function s.acttg(e,c)
	return c:GetAttack()<1000 and c:IsFaceup()
end


--Equip
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount()
end
function s.eqfilter(c)
	return c:IsSetCard(0x12A8) and c:IsMonster() and not c:IsForbidden() and not c:IsType(TYPE_XYZ)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local tg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if #tg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg=tg:Select(tp,1,1,nil)
		Duel.Equip(tp,tc,sg:GetFirst())
		--Equip limit
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end