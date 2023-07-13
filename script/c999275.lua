--Scripted by IanxWaifu
--Daemon of Ruin, Skálithë
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(function(_,c) return c:IsSetCard(0x718) end)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.setcost)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Special
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.spcost)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	---Summon Succ
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.sccon)
	e4:SetTarget(s.sctg)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)		
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x718) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end


function s.cfilter(c,tp)
	local c=e:GetHandler()
	if not (c and c:IsAbleToRemoveAsCost()) then return false end
	if not c:IsLocation(LOCATION_PZONE) then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	else
		return c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,true)
	end
end
function s.setfilter(c,ignore)
	return (c:IsSetCard(0x719) and c:IsSpellTrap() and c:IsSSetable(ignore)) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end




function s.cfilter(c,tp)
	local c=e:GetHandler()
	if not (c and c:IsAbleToRemoveAsCost()) then return false end
	if not c:IsLocation(LOCATION_MZONE) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp)
	else
		return c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil,true,e,tp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x718) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end


function s.cgfilter(c)
	return c:IsSetCard(0x718)
end
function s.sccon(e,c)
	local cg=e:GetHandler():GetColumnGroup() and e:GetHandler():GetColumnGroup(1,1)
	return cg:IsExists(s.cgfilter,1,nil)
end


function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	local b2=(Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) and Duel.IsPlayerCanDraw(tp,1))
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if chk==0 then return (b1 and #g>0) or b2 end
	local op=0
	if (b1 and #g>0)  and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif (b1 and #g>0)  then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,LOCATION_ONFIELD+LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end

function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	else 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
		local ctg=g:GetCount()
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct==ctg then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
