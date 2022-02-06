--Scripted by IanxWaifu
--Gotheatrè, Espérer dans les Ténèbres
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.thfilter(c,tp)
	return c:IsSetCard(0x12E5) and not c:IsFaceup() and not c:IsCode(id)
end
function s.actfilter(c,tp)
	return c:IsCode(998395) and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x12E5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g2:GetCount()>0 then
		local td=g2:Select(tp,1,1,nil):GetFirst()
		Duel.BreakEffect()
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(td,0)
		Duel.ConfirmDecktop(tp,1)
		td:ReverseInDeck()
		if not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,998395),tp,LOCATION_FZONE,0,1,nil) and
			Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.actfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
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
							Duel.DisableShuffleCheck()
						else
							fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
							if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
							Duel.DisableShuffleCheck()
						end
					end
					if (tpe&TYPE_FIELD)==TYPE_FIELD then
						aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
						Duel.DisableShuffleCheck()
					else Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true) end
					Duel.Hint(HINT_CARD,0,tc:GetCode())
					tc:CreateEffectRelation(te)
					Duel.DisableShuffleCheck()
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
			Duel.DisableShuffleCheck()
		end
		elseif Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,998395),tp,LOCATION_FZONE,0,1,nil) and
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local sc=sg2:GetFirst()
		if sc then
			Duel.DisableShuffleCheck()
			Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2,true)
			sc:CompleteProcedure()
		end
		Duel.DisableShuffleCheck()
		Duel.SpecialSummonComplete()
	end
	Duel.DisableShuffleCheck()
end 
Duel.DisableShuffleCheck()
end