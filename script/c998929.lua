--Scripted by IanxWaifu
--Iron Saga - Mobilize
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.acttg)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)
	--Negate Effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Banish+Draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

--Activate to Field
function s.actfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS+TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true) and c:IsSetCard(0x1A0)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 and not e:GetHandler():IsRelateToEffect(e) then return end
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.actfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=dg:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		local te=tc:GetActivateEffect()
		if not te then return end
		local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
		if pre[1] then
			for i,eff in ipairs(pre) do
				local prev=eff:GetValue()
				if type(prev)~='function' or prev(eff,te,tp) then return end
			end
		end
		if tc then
		Duel.HintSelection(sg)
			te:UseCountLimit(tp,1)
			local tpe=tc:GetType()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			local loc=LOCATION_SZONE
			if (tpe&TYPE_FIELD)~=0 then
				loc=LOCATION_FZONE
				local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
				if Duel.IsDuelType(DUEL_1_FIELD) then
					if fc then Duel.Destroy(fc,REASON_RULE) end
					fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
					if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				else
					fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
					if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				end
			end
			if (tpe&TYPE_FIELD)==TYPE_FIELD then
				Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
				else Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true) end
				Duel.Hint(HINT_CARD,0,tc:GetCode())
				tc:CreateEffectRelation(te)
				if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
					tc:CancelToGrave(false)
				end
			if te:GetCode()==EVENT_CHAINING then
				local chain=Duel.GetCurrentChain()-1
				local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
				local tc=te2:GetHandler()
				local g=Group.FromCards(tc)
				local p=tc:GetControler()
				if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
				if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
			elseif te:GetCode()==EVENT_FREE_CHAIN then
				if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
				if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
				if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
			end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			tc:SetStatus(STATUS_ACTIVATED,true)
			if not tc:IsDisabled() then
				if te:GetCode()==EVENT_CHAINING then
					local chain=Duel.GetCurrentChain()-1
					local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
					local tc=te2:GetHandler()
					local g=Group.FromCards(tc)
					local p=tc:GetControler()
					if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
				elseif te:GetCode()==EVENT_FREE_CHAIN then
					if op then op(te,tp,eg,ep,ev,re,r,rp) end
				else
					local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
					if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
				end
			else
				--insert negated animation here
			end
			Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
			if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
				Duel.Equip(tp,tc,g:GetFirst())
			end
			tc:ReleaseEffectRelation(te)
			if etc then
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
		end
	end
end


--Negate Targeted Cards Effects
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1A0)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil) 
end
function s.nfilter(c)
	return (c:IsFaceup() and not c:IsDisabled()) or c:IsFacedown()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.nfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.nfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.nfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		--Cannot activate its effects
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(3302)
		e0:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_CANNOT_TRIGGER)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0)
		if tc:IsFaceup() and not tc:IsDisabled() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end

--Banish+Draw
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_EFFECT)
end
function s.drfilter(c)
	return c:IsSetCard(0x1A0) and c:IsAbleToRemove()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Draw(p,d,REASON_EFFECT)
	end
end