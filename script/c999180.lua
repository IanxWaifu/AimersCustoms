-- Regalian Second Princess - Zurieyna
-- Scripted by IanxWaifu
local s,id=GetID()

function s.initial_effect(c)
    -- Add effect: Normal Summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1) 
    -- Destroy PZone
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- Function for Normal Summon effect
function s.thfilter(c,tp)
    return (c:IsCode(999181) or c:IsCode(999182)) and c:IsAbleToHand() 
end
function s.filter1(c)
    return c:IsCode(999181) and c:IsAbleToHand() 
end
function s.filter2(c)
    return c:IsCode(999182) and c:IsAbleToHand() 
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #g1>0 and #g2>0 and Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1) then
   	local dg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local dg2=g2:Select(tp,1,1,nil)
		dg1:Merge(dg2)
		Duel.SendtoHand(dg1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,dg1)
elseif #g3>0 or (#g1>0 and not #g2>0) or (#g2>0 and not #g1>0) or (not (Duel.GetFieldCard(tp,LOCATION_PZONE,0) or not (Duel.GetFieldCard(tp,LOCATION_PZONE,1)))) then
		local dg1=g3:Select(tp,1,1,nil)
		Duel.SendtoHand(dg1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,dg1)
	end
end




-- Function for Pendulum effect
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	 Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end