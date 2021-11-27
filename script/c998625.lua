--Scripted by IanxWaifu
--Harunijro Kijin Release
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end				
function s.filter1(c,e,tp)
	return Duel.GetMZoneCount(tp,c)>-1 and ((c:IsLocation(LOCATION_HAND)) or (c:IsFaceup() and c:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD)))
	and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,e,tp,c:GetCode())
	and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_HAND,0,1,nil,e,tp) and c:IsSetCard(0x12EA) and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_RITUAL)
end
function s.filter2(c,e,tp,code)
    return (c:IsSetCard(0x12EA) and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and code~=998550 and c:IsCode(998550) and not c:IsType(TYPE_RITUAL)) or
     (c:IsSetCard(0x12EA) and c:IsAbleToRemove() and c:IsType(TYPE_MONSTER) and code==998550 and not c:IsCode(998550) and not c:IsType(TYPE_RITUAL))
     and ((c:IsLocation(LOCATION_HAND)) or (c:IsFaceup() and c:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD))) 
end
function s.filter3(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsSetCard(0x12EA) and c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 then return end
	local rg1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil,e,tp)
	local code=rg1:GetFirst():GetCode()
	local rg2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil,e,tp,code)
	rg1:Merge(rg2)
	Duel.Remove(rg1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
	local tg=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if tc then
		tc:SetMaterial(rg1)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp)
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
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
			if fc then Duel.Destroy(fc,REASON_RULE) end
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		else
			fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		end
	end
	Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
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
end
end
end
function s.actfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.actfilter(c,tp,cd)
	return c:IsSetCard(0x12EA) and c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true)
		and not Duel.IsExistingMatchingCard(s.actfilter2,tp,LOCATION_ONFIELD,0,1,nil,c:GetCode()) and not c:IsCode(cd)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12EA) and c:IsAbleToRemoveAsCost()
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,0,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
