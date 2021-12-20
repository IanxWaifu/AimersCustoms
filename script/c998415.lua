--Scripted by IanxWaifu
--Gotheatrè Harmoniques Grises Vintage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12E5)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.actfilter(c,tp)
	return c:IsSetCard(0x12E5) and c:IsCode(998395) and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.actfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	local tc=sg:GetFirst()
	if tc then
	Duel.HintSelection(sg)
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	if bit.band(tpe,TYPE_FIELD)~=0 and not tc:IsType(TYPE_FIELD) and not tc:IsFacedown() then
		local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,5)
		if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			fc=Duel.GetFieldCard(tp,LOCATION_FZONE,5)
			if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		else
			fc=Duel.GetFieldCard(tp,LOCATION_FZONE,5)
			if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		end
	end
	Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	tc:CreateEffectRelation(te)
	if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
		tc:CancelToGrave(false) 	
	end
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local etc=g:GetFirst()
		while etc do
			etc:CreateEffectRelation(te)
			etc=g:GetNext()
		end
	end
	if op then op(te,tp,eg,ep,ev,re,r,rp) end
	tc:ReleaseEffectRelation(te)
	if etc then	
		etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
			end
		end
		end
		if tc and tc:IsLocation(LOCATION_FZONE) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local b=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		local op=1
		if b then 
			op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,2))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
		end
		if op==0 then
			Duel.ConfirmDecktop(tp,1)
			Duel.DisableShuffleCheck()
			local rt=Duel.GetDecktopGroup(tp,1):GetFirst()
				if rt:IsSetCard(0x12E5) then
				Duel.BreakEffect()
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(rt,0)
				rt:ReverseInDeck()
				Duel.ConfirmDecktop(tp,1)
			elseif not rt:IsSetCard(0x12E5) then 
				Duel.BreakEffect()
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(rt,1)
			end
		else
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12E5))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		end
		Duel.DisableShuffleCheck()
	end
	Duel.DisableShuffleCheck()
end