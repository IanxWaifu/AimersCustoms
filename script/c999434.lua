--Scripted by IanxWaifu
--Necrotic Encroaching Sorrow
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--Returnto hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rtcon)
	e2:SetTarget(s.rttg)
	e2:SetOperation(s.rtop)
	c:RegisterEffect(e2)
end
s.listed_series={0x129f}
s.listed_names={id,CARD_ZORGA}

function s.counterfilter(c)
	return c:IsSetCard(0x29f)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c)
	return not c:IsSetCard(0x29f)
end
function s.thfilter(c)
	return c:IsSetCard(0x29f) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ZORGA),tp,LOCATION_ONFIELD,0,1,nil) then return end
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end


function s.rtfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSetCard(0x29f) and c:IsControler(tp)
end
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.rtfilter,1,nil,tp)
end

function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		--activate cost
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_TO_GRAVE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCondition(s.drcon)
		e2:SetTarget(s.drtg)
		e2:SetOperation(s.drop)
		Duel.RegisterEffect(e2,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESET_PHASE+PHASE_END,0,99)
	end
end

function s.drfilter(c,e,tp)
	return c:IsCode(id)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drfilter,1,nil,tp) 
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)>0 end
	local g=eg:Filter(s.drfilter,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,#g,#g,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)==0 then return end
	local g=eg:Filter(s.drfilter,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	Duel.ResetFlagEffect(tp,id)
end
