--Gotheatrè, Julianné
--Scripted by Aimer
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetValue(SUMMON_TYPE_RITUAL)
	c:RegisterEffect(e1)
	--Opponent's BP is treated as your Additional BP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(998365)
	e2:SetCondition(s.bpcon)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--You take no battle damage from battles involving your Gotheatre
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return c:IsSetCard(0x12E5) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Activate Phantom of the Gotheatre from the Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.actcon)
	e4:SetTarget(s.acttg)
	e4:SetOperation(s.actop)
	c:RegisterEffect(e4)
	--Special from Deck
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(s.spdcon)
	e5:SetTarget(s.spdtg)
	e5:SetOperation(s.spdop)
	c:RegisterEffect(e5)
end

--Ritual Summon
function s.spfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x12E5) and c:IsMonster()
		and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.stgfilter,tp,LOCATION_DECK,0,1,nil,tp)
end

function s.stgfilter(c,tp)
	local stg=Duel.GetFieldCard(tp,LOCATION_DECK,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-1)
	return stg:IsFaceup() and stg:IsSetCard(0x12E5) and stg==c
end


function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rmg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,c,tp)
	local smg=Duel.GetMatchingGroup(s.stgfilter,tp,LOCATION_DECK,0,nil,tp)
	local stg=Duel.GetFieldCard(tp,LOCATION_DECK,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-1)
	return ft>-1 and #rmg>0 and #smg>0 and aux.SelectUnselectGroup(rmg:Clone():Merge(smg),e,tp,2,2,function(sg,e,tp,mg)
		return sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) and sg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE) end,0,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,c,tp)
	local g2=Duel.GetMatchingGroup(s.stgfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g==0 or #g2==0 then return false end
	local sg=aux.SelectUnselectGroup(g:Clone():Merge(g2),e,tp,2,2,function(sg,e,tp,mg)
		return sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) and sg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE) end,1,tp,HINTMSG_SELECT)
	if #sg==2 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end


function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    local rmg=g:Filter(function(c) return not c:IsLocation(LOCATION_DECK) end,nil)
    c:SetMaterial(g)
    Duel.Remove(rmg,POS_FACEUP,REASON_COST)
    g:Sub(rmg)
    Duel.SendtoGrave(g,REASON_COST)
    g:DeleteGroup()
end


--Opponent's BP is treated as your Additional BP
function s.bpcon(e,c)
	local p=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer(1-p)
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer(tp)
end
function s.actfilter(c,tp)
	return c:IsSetCard(0x12E5) and c:IsCode(998395) and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
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
	Duel.DisableShuffleCheck()
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
end

--Special from Deck
function s.spdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.spdfilter(c,e,tp)
	return c:IsSetCard(0x12E5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spdfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spdfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end