--Oppicyene Sides of the Spectrum
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Summon Counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Discard Counter
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.ctcost)
	e4:SetTarget(s.cttg2)
	e4:SetOperation(s.ctop2)
	c:RegisterEffect(e4)
	--Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_CYENE}
s.counter_list={COUNTER_ICE,COUNTER_BLAZE}



function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_CYENE) and c:IsSummonPlayer(tp) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_WATER))
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local counter=0
	local att=eg:GetFirst():GetAttribute()
	if att==ATTRIBUTE_FIRE then counter=COUNTER_BLAZE end
	if att==ATTRIBUTE_WATER then counter=COUNTER_ICE end
	e:SetLabel(counter)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,counter)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local counter=e:GetLabel()
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(counter,1)
	end
end

function s.costfilter(c)
	return c:IsMonster() and c:IsDiscardable() and c:IsSetCard(SET_CYENE) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_WATER))
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
	local g=Duel.GetOperatedGroup()
	e:SetLabel(g:GetFirst():GetAttribute())
end

function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local counter=0
	local att=e:GetLabel()
	if att==ATTRIBUTE_FIRE then counter=COUNTER_BLAZE end
	if att==ATTRIBUTE_WATER then counter=COUNTER_ICE end
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,counter)
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	if att==ATTRIBUTE_FIRE then counter=COUNTER_BLAZE end
	if att==ATTRIBUTE_WATER then counter=COUNTER_ICE end
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(counter,1)
	end
end

function s.exfilter(c,lv,att,code,e,tp)
	return c:IsSetCard(SET_CYENE) and c:IsLevelBelow(lv) and c:IsAttribute(att) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsAttribute(ATTRIBUTE_WATER))
end
function s.scfilter(c,e,tp)
	return c:HasLevel() and c:IsSetCard(SET_CYENE) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetAttribute(),c:GetCode(),e,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.scfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.scfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.scfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel(),tc:GetAttribute(),tc:GetCode(),e,tp)
		local sc=sg:GetFirst()
		if sc and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			local att=sc:GetAttribute()
			if att==ATTRIBUTE_FIRE then counter=COUNTER_BLAZE end
			if att==ATTRIBUTE_WATER then counter=COUNTER_ICE end
			sc:AddCounter(counter,1)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)
	end
end

function s.splimit(e,c)
	return not c:IsSetCard(SET_CYENE)
end