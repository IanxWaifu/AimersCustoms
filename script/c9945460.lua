--Zodiakieri Taurus
local s,id=GetID()
function c9945460.initial_effect(c)
	--spirit return
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c9945460.splimit)
	c:RegisterEffect(e1)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9945460,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c9945460.settg)
	e2:SetCountLimit(1,9945461)
	e2:SetOperation(c9945460.setop)
	c:RegisterEffect(e2)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9945460,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c9945460.cost)
	e3:SetTarget(c9945460.actg)
	e3:SetCountLimit(3,9945460)
	e3:SetOperation(c9945460.acop)
	c:RegisterEffect(e3)
end
function c9945460.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x12D7)
end
function c9945460.setfilter(c)
	return c:IsSetCard(0x12D7) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c9945460.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c9945460.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c9945460.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c9945460.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
	end
end
function c9945460.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(9945460)==0 end
	e:GetHandler():RegisterFlagEffect(9945460,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
end
--[[function c9945460.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x12D7) and not (c:IsStatus(STATUS_SET_TURN) and c:IsType(TYPE_QUICKPLAY+TYPE_TRAP)) and not c:IsFaceup()
		and c:CheckActivateEffect(false,false,false)~=nil
end
function c9945460.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9945460.filter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil) end
end--]]



--activate
function c9945460.actfilter(c,e,tp)
	local type_spell=TYPE_SPELL
	local type_trap=TYPE_TRAP
	if not c:IsType(type_spell|type_trap) then return end
	return c:IsSetCard(0x12D7) and c:CheckActivateEffect(false,false,false)~=nil and c:IsType(TYPE_SPELL+TYPE_TRAP) and not (c:IsStatus(STATUS_SET_TURN) and c:IsType(TYPE_QUICKPLAY+TYPE_TRAP)) and not c:IsFaceup()
end
function c9945460.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
 	if loc==0 then return false end
	if chk==0 then return loc>0 and Duel.IsExistingMatchingCard(c9945460.actfilter,tp,loc,0,1,nil,e,tp) end
end
function c9945460.acop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
  	if loc==0 then return false end
    local g=Duel.GetMatchingGroup(c9945460.actfilter,tp,loc,0,nil,e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    --activate
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_CHAIN_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(sc)
    e1:SetOperation(c9945460.faop)
    Duel.RegisterEffect(e1,tp)
    sc:RegisterFlagEffect(9945550,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)

end
function c9945460.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local te=tc:GetActivateEffect()
    local tep=tc:GetControler()
    if not te then return end
	local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if pre[1] then
		for i,eff in ipairs(pre) do
			local prev=eff:GetValue()
			if type(prev)~='function' or prev(eff,te,tep) then return end
		end
	end
	if tc:GetFlagEffect(9945550)==0 then return false end
	if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep) then
        Duel.Activate(te)
        Duel.BreakEffect()
        tc:ResetFlagEffect(9945550)
    end
    e:Reset()
end

--[[function c9945460.acop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
	local sg=Duel.SelectMatchingCard(tp,c9945460.filter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil)
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
		if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
		if (tpe&TYPE_FIELD)==TYPE_FIELD and not tc:IsLocation(LOCATION_FZONE) then
			Duel.MoveSequence(tc,5)
		end
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		tc:CreateEffectRelation(te)
		if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
			tc:CancelToGrave(false)
			if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
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
end--]]