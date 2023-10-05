--Scripted by IanxWaifu
--Necroticrypt Gateway
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Target Send
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.scon)
	e2:SetTarget(s.stg)
	e2:SetOperation(s.sop)
	c:RegisterEffect(e2)
	--banish
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(s.setcond)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end

s.listed_series={0x129f,0x29f}
s.listed_names={id}



function s.thcostfilter(c, tp)
    return c:IsSetCard(0x129F) and c:IsAbleToHand() and c:IsMonster()
        and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil, c:GetCode())
end

function s.tgfilter(c, code)
    return c:IsSetCard(0x29F) and c:IsAbleToGrave() and not c:IsCode(code) and c:IsMonster()
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e)  then return end
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.thcostfilter, tp, LOCATION_DECK, 0, nil, tp)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
    local tc = Duel.GetMatchingGroup(s.thcostfilter, tp, LOCATION_DECK, 0, nil, tp):Select(tp, 1, 1, nil):GetFirst()
    if tc and Duel.SendtoHand(tc, nil, REASON_EFFECT) ~= 0 then
        local code = tc:GetCode()
        local tg = Duel.GetMatchingGroup(s.tgfilter, tp, LOCATION_DECK, 0, nil, code)
        if #tg > 0 then
            local dg = tg:Select(tp, 1, 1, nil)
            Duel.BreakEffect()
            Duel.SendtoGrave(dg, REASON_EFFECT)
        end
        end
    end
end

function s.checkfilter(c)
    return c:IsSetCard(0x129F) and c:IsType(TYPE_XYZ)
end
function s.scon(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.checkfilter, tp, LOCATION_MZONE, 0, nil)
    
    for tc in aux.Next(g) do
        local mg = tc:GetOverlayGroup()
        if mg:IsExists(s.oppfilter, 1, nil, e:GetHandlerPlayer()) then
            return true
        end
    end
    
    return false
end

function s.oppfilter(c,tp)
    return c:GetOwner()~=tp
end
function s.sfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsSpellTrap() and s.filter(chkc) and chkc:IsController(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.sfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc, REASON_EFFECT)
	end
end


function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x129F) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end


function s.setcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()==tp
end
function s.rthfilter(c)
	return c:IsSetCard(0x129F) and c:IsMonster() and c:IsAbleToHand()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.rthfilter,tp,LOCATION_GRAVE,0,nil)
	if Duel.GetFlagEffect(tp,id)>0 or #g<=0 then return end
	if Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and #g>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local tc=g:Select(tp,1,1,nil)
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end