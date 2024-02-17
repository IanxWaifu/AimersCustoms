--Scripted by IanxWaifu
--Iron Saga - Tetra's Advance
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(id)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetCountLimit(1,{id,1})
	e3:SetLabelObject(e2)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end

s.listed_series={0x12EC}
s.listed_names={id}

function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsLevel(7) and c:IsSetCard(0x12EC) and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsAbleToHand() or (c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	local dt=Duel.SendtoHand(g,nil,REASON_EFFECT)
	if dt==0 then return end
	local dg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if #dg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg=dg:Select(tp,1,dt,nil)
		Duel.HintSelection(sg)
		local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		if #rg>0 then
			Duel.SendtoDeck(rg,nil,2,REASON_EFFECT)
			sg:Sub(rg)
		end
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end

--Normal Summon
function s.sumfilter(c,se)
	return c:IsSummonable(false,se) and c:IsSetCard(0x12EC)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local se=e:GetLabelObject()
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil,se) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil,se):GetFirst()
	if tc then
		Duel.Summon(tp,tc,false,se)
	end
end