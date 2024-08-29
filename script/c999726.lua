--Dragocyene Hailstrom
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Shuffle 3 and place counters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

function s.counterfilter(c)
    return c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.counterfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    local max_remove=math.min(15,g:GetSum(Card.GetCounter,COUNTER_ICE))
    local max_ct=math.floor(max_remove/3)
    local target_ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    local ct=math.min(max_ct,math.floor(target_ct))
    if chk==0 then return #g>0 and ct>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.counterfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    local max_remove=math.min(15,g:GetSum(Card.GetCounter,COUNTER_ICE))
    local max_ct=math.floor(max_remove/3)
    local target_ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    local ct=math.min(max_ct,math.floor(target_ct))
    if ct<=0 then return end
    local removed=0
    for i=1,ct do
        local select_ct=3
        local sg=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,COUNTER_ICE,select_ct,REASON_EFFECT)
        if #sg==0 then break end
        sg:GetFirst():RemoveCounter(tp,COUNTER_ICE,select_ct,REASON_EFFECT)
        removed=removed+select_ct
        -- Prompt the player to decide if they want to continue removing counters
        if removed<ct*3 and not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then break end
    end
    if removed>0 then
        local dcount=removed/3
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,dcount,dcount,c)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end

--Shuffle and place counters
function s.tdfilter(c)
	return c:IsSetCard(SET_CYENE) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_ICE)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	if #tg<=0 or #dg==0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 and #dg>0 then
		Duel.BreakEffect()
		for i=1,ct do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sg=dg:Select(tp,1,1,nil)
			sg:GetFirst():AddCounter(COUNTER_ICE,1)
		end
	end
end