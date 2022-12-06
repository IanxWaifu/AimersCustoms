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
	--To hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.thcostfilter(c,tp)
	return c:IsSetCard(0x1A0) and not c:IsPublic()
	and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.tgfilter(c,code)
	return c:IsSetCard(0x1A0) and c:IsAbleToHand() and not c:IsCode(code) 
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
function s.codfilter(c,codes)
	return c:IsSetCard(0x1A0) and c:IsAbleToGrave() and c:IsLevel(7) and c:IsCode(table.unpack(codes))
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=e:GetLabelObject()
    local code=g:GetFirst():GetCode()
    local tc=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,code)
    local sg=tc:Select(tp,1,1,nil):GetFirst()
    if Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0  then 
    	if not sg:IsCode(998920,998921,998922,998923) then return end
	    local mt=Duel.GetMetatable(sg:GetCode())
	    local codes = mt.ordinal_scale
	    local tc2=Duel.GetMatchingGroup(s.codfilter,tp,LOCATION_DECK,0,nil,codes)
	    if #tc2>0 then
        local bg=tc2:Select(tp,1,1,nil)
        local dg2=bg:GetFirst()
        Duel.BreakEffect()
        Duel.SendtoGrave(dg2,REASON_EFFECT)
       end
    end
end

--Return to hand
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end