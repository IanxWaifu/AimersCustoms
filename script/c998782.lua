--Scripted by IanxWaifu
--Girls’&’Artillery - Quickshot
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.seqcost)
	e2:SetCondition(s.seqcon)
	e2:SetTarget(s.seqtg)
	e2:SetOperation(s.seqop)
	c:RegisterEffect(e2)
end

--Send Filter
function s.sfilter(c,tp)
	return c:IsSetCard(0x12EE) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.sfilter2,tp,LOCATION_DECK,0,1,c)
end
function s.sfilter2(c)
	return c:IsSetCard(0x12EF) and c:IsAbleToGrave()
end

--Column Group Check
function s.cgfilter(c)
	return c:IsSetCard(0x12EE) and c:IsLinkMonster() 
end
function s.cgfilter2(c)
	return c:IsSetCard(0x12EE) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

--Activation Filter Legality
function s.actfilter(c,tp)
	if c:IsCode(998781) then return true end
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x12EF) and not c:IsCode(id) and c:GetActivateEffect():IsActivatable(tp,true,true) 
end


--Choice Effect
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=e:GetHandler():GetColumnGroup()
	local b1=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp,cg) and cg:IsExists(s.cgfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
	if chk==0 then return b1 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end


--Activation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	if e:GetLabel()==2 then return end
	if e:GetLabel()==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local fg=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #fg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local fg2=Duel.SelectMatchingCard(tp,s.sfilter2,tp,LOCATION_DECK,0,1,1,fg:GetFirst())
			fg:Merge(fg2)
			Duel.SendtoGrave(fg,REASON_EFFECT)
		end
	else
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
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
				end
				if (tpe&TYPE_FIELD)==TYPE_FIELD then
					aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
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
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
	if cg:IsExists(s.cgfilter2,1,nil) then
	c:CancelToGrave()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end

function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_LINK) and rc:IsSetCard(0x12EE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
	and e:GetHandler():IsType(TYPE_CONTINUOUS)
end


function s.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
	--Activation legality
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil) end
end
	--Move to Unoccupied
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,seq)
	e:SetLabel(math.log(seq,2))
	local seq2=e:GetLabel()
	if not Duel.CheckLocation(tp,LOCATION_MZONE,seq2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,seq2)
end

