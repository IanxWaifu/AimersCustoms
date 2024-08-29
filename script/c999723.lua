--Dragocyene Crystallagmite
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CYENE),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_WATER),1,99)
	c:EnableReviveLimit()
	--Tofield
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tncon)
	e2:SetTarget(s.tntg)
	e2:SetOperation(s.tnop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--disable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(s.disfilter))
	c:RegisterEffect(e4)
	--Redistribute Ice Counters on the field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.pccon)
	e5:SetTarget(s.pctg)
	e5:SetOperation(s.pcop)
	c:RegisterEffect(e5)
	--Shuffle to the Deck
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk,counter_amount) return Aimer.FrostrineCounterCost(e,tp,eg,ep,ev,re,r,rp,chk,3) end )
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end

s.listed_series={SET_ICYENE,SET_DRAGOCYENE}
s.counter_list={COUNTER_ICE}

--Material Check
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_RITUAL) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO and e:GetLabel()==1
end

function s.ttfilter(c,tp)
    return c:IsSpellTrap() and (c:IsCode(999722) or c:IsCode(999707)) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end

function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.ttfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end

function s.tnop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ttfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
    if not tc then return end
    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end

--Negate Eff Filter
function s.disfilter(c)
	return c:GetCounter(COUNTER_ICE)>=5 and c:IsFaceup()
end

--Redistruibute
function s.pcfilter(c)
	return c:GetCounter(COUNTER_ICE)>0
end

function s.pccon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
end

function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCounter(tp,1,1,COUNTER_ICE)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_ICE)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	local sum=0
	for tc in aux.Next(g) do
		local sct=tc:GetCounter(COUNTER_ICE)
		tc:RemoveCounter(tp,COUNTER_ICE,sct,0)
		sum=sum+sct
	end
	local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for i=1,sum do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local sg=dg:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(COUNTER_ICE,1)
	end
end

--Add to hand GY
function s.thfilter(c)
	return c:IsSetCard(SET_CYENE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.thfilter(chkc) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
