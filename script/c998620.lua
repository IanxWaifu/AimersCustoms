--Scripted by IanxWaifu
--Tengoku Kijin Ritual
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
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
	e2:SetCost(s.tdcost)
	e2:SetCondition(aux.exccon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end				
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x12EA) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
	and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_HAND,0,1,nil,e,tp)
end
function s.filter2(c,e,tp,code)
    return (code~=998550 and c:IsCode(998550) and c:IsSetCard(0x12EA) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)) or (code==998550 and not c:IsCode(998550) and c:IsSetCard(0x12EA) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER))
end
function s.filter3(c,e,tp)
local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsRitualMonster() and c:IsSetCard(0x12EA) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp)
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_RITUAL)
	if #pg>0 then return end
	local rg1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local code=rg1:GetFirst():GetCode()
	local rg2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
	Duel.SpecialSummon(rg1,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL,tp,tp,false,false,POS_FACEUP)
	Duel.SendtoGrave(rg2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
	local tg=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if tc then
		tc:SetMaterial(rg1+rg2)  
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
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

