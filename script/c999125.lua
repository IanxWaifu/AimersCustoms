--Wizardrake Malediction
--Scripted by IanxWaifu
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Negate Summons
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--To hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0x12A7}
s.listed_names={id}


function s.cfilter(c)
	return c:IsSetCard(0x12A7) and c:IsFaceup() and c:IsOringalType(TYPE_MONSTER)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER) and ep==1-tp
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc and te:IsActiveType(TYPE_MONSTER) then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				g:AddCard(tc)
			end
		end
		return g:IsContains(chkc) end
	if chk==0 then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc and te:IsActiveType(TYPE_MONSTER) then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				g:AddCard(tc)
			end
		end
		local dg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
		return #g>0 and #g<=#dg
	end
	local g=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if tc and te:IsActiveType(TYPE_MONSTER) then
			local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
			g:AddCard(tc)
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1,i)
		end
	end
  	g:KeepAlive()
    e:SetLabelObject(g)
	local i=g:GetFirst():GetFlagEffectLabel(id)
	local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	if g:GetFirst():IsRelateToEffect(te) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	local dg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if #g>#dg then return end
	if #g>0 and #g<=#dg then
			local ct=dg:Select(tp,#g,#g,nil)
			if ct and Duel.Destroy(ct,REASON_EFFECT)~=0 then
			local sg=g:Select(tp,#ct,#ct,nil)
			local tc=sg:GetFirst()
			if not tc or tc:IsDisabled() then return end
				for tc in aux.Next(sg) do
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e3)
				end
					Duel.AdjustInstantly()
					if not tc:IsDestructable(e) then return end
					Duel.Destroy(tc,REASON_EFFECT)
				end
			sg:DeleteGroup()
		end
	end
end





--Disable Specials
function s.disfilter(c,tp)
	return not c:IsSummonPlayer(tp) and (c:GetSummonLocation()&LOCATION_EXTRA)~=0 and c:IsLocation(LOCATION_MZONE) and not c:IsDisabled()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.disfilter,nil,tp)
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,ct,e:GetHandler()) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,ct,0,0)
	if  re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,ct,0,0)
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.disfilter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	local ct=#g
	if #g>0 then
		local dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,ct,ct,e:GetHandler())
		local tg=dg:GetFirst()
		if tg and Duel.Destroy(tg,REASON_EFFECT)~=0 then
			for tc in aux.Next(eg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			Duel.AdjustInstantly()
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end

--To hand
function s.thfilter(c)
	return c:IsSetCard(0x12A7) and c:IsAbleToHand() and c:IsType(TYPE_PENDULUM)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end