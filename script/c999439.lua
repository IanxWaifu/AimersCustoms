--Scripted by IanxWaifu
--Necroticrypt Sigil
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Send 1 monster to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Banish itself and attach from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end

s.listed_series={0x129f}

function s.tgfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.tgfilter(c,tp,cd)
	return c:IsSetCard(0x129f) and c:IsMonster() and c:IsAbleToGrave() 
		and not Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode()) and not c:IsCode(cd)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,3) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,3)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
		s.ApplyEffectToCards(s.cfilter, tp, e)
	end
end

function s.cfilter(c, tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp)
end
function s.ApplyEffectToCards(cfilter, tp, e)
    local c = e:GetHandler()
    local fg1 = Duel.GetOperatedGroup()
    local fg2 = fg1:Filter(cfilter, nil, tp)
    for dc in aux.Next(fg2) do
        local e1 = Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id, 3))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        dc:RegisterEffect(e1)
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_TRIGGER)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
        dc:RegisterEffect(e2)
    end
end

function s.xyzfilter(c)
	return c:IsSetCard(0x129f) and c:IsType(TYPE_XYZ)
end
function s.attachfilter(c)
	return c:IsMonster()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tg=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tg,1,0,0)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g>0 and tc and tc:IsRelateToEffect(e) then
		local mg=g:Select(tp,1,1,nil)
		local oc=mg:GetFirst():GetOverlayTarget()
		Duel.Overlay(tc,mg)
	end
end