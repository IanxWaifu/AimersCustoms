--Scripted by IanxWaifu
--Iron Saga - Catalyst
local s,id=GetID()
function s.initial_effect(c)
	--Reveal and Add
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end

function s.thcostfilter(c,tp)
	return c:IsSetCard(0x1a0) and not c:IsPublic()
	and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.tgfilter(c,code)
	return c:IsSetCard(0x1a0) and c:IsAbleToHand() and not c:IsCode(code) 
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND,0,1,1,c,tp)
	e:SetLabel(g:GetFirst():GetCode())
	g:KeepAlive()
	e:SetLabelObject(g)
	Duel.SetTargetCard(g)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local code=e:GetLabel()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,code) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.codfilter(c,code2)
--[[	local c=e:GetHandler()--]]
	local code2=c:GetCode()
	if code2==998920 then return c:IsCode(998923) and c:IsCode(998921) end
	if code2==998921 then return c:IsCode(998920) and c:IsCode(998922) end
	if code2==998922 then return c:IsCode(998921) and c:IsCode(998923) end
	if code2==998923 then return c:IsCode(998922) and c:IsCode(998920) end
	return code2 and c:IsSetCard(0x1A0) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	local code=g:GetFirst():GetCode()
	local tc=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,code)
	local code2=tc:GetFirst():GetCode()
	local tc2=Duel.GetMatchingGroup(s.codfilter,tp,LOCATION_DECK,0,nil,code2)
	local sg=tc:Select(tp,1,1,nil)
	local dg=sg:GetFirst()
	if Duel.SendtoHand(dg,nil,REASON_EFFECT)~=0 and dg:IsCode(998920) or dg:IsCode(998921) or dg:IsCode(998922) or dg:IsCode(998923) and tc2:GetCount()>0 then 
		local bg=tc2:Select(tp,1,1,nil)
		local dg2=bg:GetFirst()
		Duel.BreakEffect()
		Duel.SendtoHand(dg2,nil,REASON_EFFECT)
	end
	g:DeleteGroup()
end