--Scripted by IanxWaifu
--Revelatia - Prefectus
local s,id=GetID()
function s.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetCountLimit(1,{id,2})
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(s.condition)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)

--[[	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)--]]
end
--Return to hand and Add Temporum
function s.filter(c)
	return c:IsCode(998857) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x19f)
end
function s.actfilter(c,tp)
	return c:IsCode(998855) and c:GetActivateEffect():IsActivatable(tp,true) 
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end 
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=sg:GetFirst()
	local te=tc:GetActivateEffect()
	if not te then return end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
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
		if (tpe&TYPE_FIELD)==TYPE_FIELD then
			Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true) end
		end
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		tc:CreateEffectRelation(te)
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


--Effect Resolve Negate
function s.cdfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsSetCard(0x19f) and c:IsMonster() and c:IsType(TYPE_FUSION)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local category=re:GetCategory()
	local ex,tg,tc=Duel.GetOperationInfo(ev,category)
	if rp==tp then return false end
	if category==CATEGORY_DESTROY or category==CATEGORY_RELEASE or category==CATEGORY_TOGRAVE or category==CATEGORY_REMOVE or category==CATEGORY_TODECK or category==CATEGORY_TOHAND then return true end
	return ex and tg~=nil and tc+tg:FilterCount(s.cdfilter,nil,tp)-#tg>0 and e:GetHandler():IsAbleToRemove()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) and re:GetHandler() and ((re:GetHandler():IsFaceup() and not re:GetHandler():IsDisabled()) or re:GetHandler():IsType(TYPE_TRAPMONSTER)) then
		if Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)>0 then 
		Duel.NegateEffect(ev)
		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_SINGLE)
		e8:SetCode(EFFECT_DISABLE)
		e8:SetReset(RESET_EVENT+RESETS_STANDARD)
		re:GetHandler():RegisterEffect(e8,true)
		local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetType(EFFECT_TYPE_SINGLE)
		e9:SetCode(EFFECT_DISABLE_EFFECT)
		e9:SetReset(RESET_EVENT+RESETS_STANDARD)
		re:GetHandler():RegisterEffect(e9,true)
		end
	end
end
