--Scripted by IanxWaifu
--Kijin, Shodo Sakusen no Jötunn
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Negate Eff
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	--Be Material
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+2)
	e5:SetCondition(s.matcon)
	e5:SetTarget(s.mattg)
	e5:SetOperation(s.matop)
	c:RegisterEffect(e5)
end
function s.actfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true,true) and c:IsSetCard(0x12EA)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
	Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
	local sg=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
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
		Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
		if (tpe&TYPE_FIELD)==TYPE_FIELD then
			Duel.MoveSequence(tc,5)
		end
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



function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x12EA)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.negfilter1(c,e)
	return c:IsType(TYPE_TRAP) and c:IsNegatableMonster()
end
function s.negfilter2(c,e)
	return c:IsType(TYPE_SPELL) and c:IsNegatableMonster()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
		local g1=Duel.GetMatchingGroup(s.negfilter1,tp,0,LOCATION_ONFIELD,nil,e)
		local g2=Duel.GetMatchingGroup(s.negfilter2,tp,0,LOCATION_ONFIELD,nil,e)
		if tc:IsType(TYPE_SPELL) and #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		Duel.BreakEffect()
		local df=g1:Select(tp,1,1,nil)
		Duel.HintSelection(df)
		local dg=df:GetFirst()
		Duel.NegateRelatedChain(dg,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dg:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dg:RegisterEffect(e2)
		if dg:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dg:RegisterEffect(e3)
			end
	elseif tc:IsType(TYPE_TRAP) and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		Duel.BreakEffect()
		local df=g2:Select(tp,1,1,nil)
		Duel.HintSelection(df)
		local dg=df:GetFirst()
		Duel.NegateRelatedChain(dg,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dg:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		dg:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dg:RegisterEffect(e3)
			end
		end	
	end
end

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_RITUAL and c:GetReasonCard():IsSetCard(0x12EA)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=1 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local b1=tc:IsAbleToGrave()
	local b2=tc:IsAbleToRemove()
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,5))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,6))+1
	end
	if op==2 then return end
	if op==0 then
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end