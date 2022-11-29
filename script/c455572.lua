--エヴォルカイザー・ドルカ
function c455572.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1194),4,2)
	c:EnableReviveLimit()
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c455572.thcost)
	e1:SetTarget(c455572.thtg)
	e1:SetOperation(c455572.thop)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c455572.reptg)
	e2:SetValue(c455572.repval)
	c:RegisterEffect(e2)
	if not c455572.global_check then
		c455572.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		ge1:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		ge1:SetTarget(function (e,c) return e:GetLabelObject():GetLabelObject() end)
		ge1:SetLabelObject(e2)
		ge1:SetValue(LOCATION_DECK)
		Duel.RegisterEffect(ge1,0)
	end
end
function c455572.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c455572.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1194) and c:IsAbleToHand()
end
function c455572.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c455572.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c455572.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,c455572.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 and not g:GetFirst():IsHasEffect(EFFECT_NECRO_VALLEY) and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+0x1ff0000)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			c:RegisterEffect(e2)
		end
	end
end
function c455572.repfilter(c,tp)
	return c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_OVERLAY) 
		and c:GetDestination()==LOCATION_GRAVE and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1194) and c:IsAbleToDeck()
end
function c455572.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return bit.band(r,REASON_EFFECT+REASON_COST+REASON_RELEASE+REASON_ADJUST)~=0
		 and eg:IsExists(c455572.repfilter,1,nil,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(455572,0)) then
		local g=eg:Filter(c455572.repfilter,nil,tp)
		local ct=g:GetCount()
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			g=g:Select(tp,1,ct,nil)
		end
		local tc=g:GetFirst()
		local og=Group.CreateGroup()
		while tc do
			if tc:IsLocation(LOCATION_OVERLAY) then
				og:AddCard(tc)
			end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_DECK)
			e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(455572,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
			tc=g:GetNext()
		end
		if og:GetCount()>0 then
			e:SetLabelObject(og)
		end
		return true
	else return false end
end
function c455572.repval(e,c)
	return false
end
