--Kegai - Man’ei no Seishu
--Scripted by Aimer
local s,id=GetID()
function s.initial_effect(c)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--banish replace
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetTarget(s.reptg)
	e3:SetCountLimit(1,{id,1})
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	--Be Material
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(s.targcon)
    e4:SetTarget(s.targtg)
    e4:SetOperation(s.targop)
    c:RegisterEffect(e4)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}

function s.thfilter(c)
	return c:IsSetCard(SET_KEGAI) and c:IsSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.repfilter(c,tp)
	return c:GetDestination()==LOCATION_REMOVED and c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) --[[and c:IsType(TYPE_RITUAL)--]]
		and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end


--be material and send
function s.targcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) and c:GetReasonCard():IsSetCard(SET_KEGAI) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.targfilter(c)
	return c:IsSetCard(SET_KEGAI)
end

function s.targtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.targfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.targfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.targfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.targop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Cannot be targeted by card effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3002)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
