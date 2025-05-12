--Scripted by IanxWaifu
--Shio to Suna ★ Barbara
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	Aimer.ShiotoSunaAddProcedure(c,id,s)
	--pendulum summon
	Pendulum.AddProcedure(c)
	c:EnableUnsummonable()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_REVIVE_LIMIT)
	e0:SetCondition(s.rvlimit)
	c:RegisterEffect(e0)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.addcon)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
	--Place
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,{id,4})
	e5:SetCondition(s.actcon)
	e5:SetTarget(s.acttg)
	e5:SetOperation(s.actop)
	c:RegisterEffect(e5)
	--Turn Summon Scale Change
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,5))
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(s.sumcon)
	e7:SetOperation(s.sumop)
	c:RegisterEffect(e7)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.rvlimit(e)
	return not e:GetHandler():IsLocation(LOCATION_HAND) and not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or ((st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and c:IsLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_PZONE) and c:IsReason(REASON_DESTROY) and c:IsFaceup())
end
function s.descon(e)
	return e:GetHandler():GetLeftScale()<=0
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsReason(REASON_BATTLE) and re and e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
function s.addfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x12F0) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


function s.actfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetActivateEffect():IsActivatable(tp,true) and c:IsSetCard(0x12F0)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
	Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) and e:GetHandler():GetFlagEffect(id)==0 end 
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


function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount() and not e:GetHandler():IsReason(REASON_RETURN) 
end

function s.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12F0)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_PZONE,0,nil)
	if chk==0 then return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_ADJUST,nil,nil,true)
	if #g>0 then
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	local t={}
	local p=1
	for i=1,2 do
		if i then
			t[p]=i
			p=p+1
		end
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(ac)
end
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ac=e:GetLabel()
	local op=0
	if tc:GetLeftScale()==0 and ac>0 then
	--Force Positive
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(ac)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	tc:RegisterEffect(e2)
	--Force Negative
	elseif tc:GetLeftScale()==1 and ac==2 then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(ac)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	tc:RegisterEffect(e2)
	--Optional
elseif not (tc:GetLeftScale()==1 and ac==2) and not (tc:GetLeftScale()==0 and ac>0) then
	local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_LSCALE)
	if op==0 then
		e3:SetValue(ac)
		else e3:SetValue(-ac) end
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_RSCALE)
	tc:RegisterEffect(e4)
	end
end


function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,{id,5})
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
end