--Icyene Citadel Forged of Crystal
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	--Destruction/Banish replacement
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
	--BFG Place 1 Ice Counter
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
	--Redistribute Ice Counters on the field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.pctg)
	e5:SetOperation(s.pcop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_ICYENE}
s.counter_list={COUNTER_ICE}

--Place Counters equal to sent monsters
function s.cfilter(c,tp)
	return c:IsSetCard(SET_CYENE) and c:IsControler(tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.cfilter,nil,tp)
	if ct>0 then
		e:GetHandler():AddCounter(COUNTER_ICE,ct,true)
	end
end

--Des/Ban Replace
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT) and rp==1-tp and (c:GetDestination()==LOCATION_REMOVED or c:GetDestination()==LOCATION_GRAVE) and c:GetCounter(COUNTER_ICE)>0 end
	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		c:RemoveCounter(ep,COUNTER_ICE,1,REASON_EFFECT)
		return true
	else return false end
end

--Place 1 counters on a card
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_ICE)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp,angle_or_delvin)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local sg=g:Select(tp,1,1,nil)
	sg:GetFirst():AddCounter(COUNTER_ICE,1)
end

--Redistruibute
function s.pcfilter(c)
	return c:GetCounter(COUNTER_ICE)>0
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
