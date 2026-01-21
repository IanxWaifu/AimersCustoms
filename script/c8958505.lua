--Scripted by Aimer
--Vylon Lambda
local s,id=GetID()
function s.initial_effect(c)
	--1. Send Vylon from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--2. Equip when sent from Monster Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.eqcon)
	e2:SetCost(Cost.PayLP(500))
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--3. Ignition while equipped
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.eqcost2)
	e3:SetTarget(s.eqtg2)
	e3:SetOperation(s.eqop2)
	c:RegisterEffect(e3)
end

--Filters
function s.tgfilter(c)
	return c:IsSetCard(SET_VYLON) and c:IsFaceup() and c:IsAbleToHand()
end
function s.eqfilter(c)
	return c:IsSetCard(SET_VYLON) and c:IsMonster() and c:IsFaceup()
end
function s.eqfilter2(c,tp)
	return c:IsSetCard(SET_VYLON) and (c:IsMonster() or c:IsEquipSpell()) and not c:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1
end

--1. Send Vylon from Deck to GY
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then 
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--2. Equip when sent from Monster Zone
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()==LOCATION_MZONE
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,c,tc)
		--equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

function s.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
--3. Ignition while equipped
function s.eqcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if ec then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local mc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if mc then
			Duel.Equip(tp,ec,mc,true)
			local e1=Effect.CreateEffect(ec)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			ec:RegisterEffect(e1)
		end
	end
end



function s.lpcostval(e,re,rp,val)
	if not re then return val end
	local rc=re:GetHandler()
	if re:IsMonsterEffect() and rc:IsSetCard(SET_VYLON)  then return 0 end
	return val
end



function s.GetTotalActivateCost(tp,te)
	local LP_COSTS={[74064212]=500,[38679204]=500,[1281505]=500,[75886890]=500,[8958505]=500,[8958507]=1000}
    local total=LP_COSTS[te:GetHandler():GetCode()] or 0
    for _,eff in ipairs(Duel.GetPlayerEffect(tp,EFFECT_ACTIVATE_COST)) do
        local h=eff:GetHandler()
        local extra=LP_COSTS[h:GetCode()]
        if extra then total=total+extra end
    end
    return total
end

function s.lptg(e,te,tp)
    local lp=s.GetTotalActivateCost(tp,te)
    if lp>0 then e:SetLabel(lp) return true end
    return false
end

function s.lpop(e,tp)
    local lp=e:GetLabel() or 0
    if lp>0 then Duel.Recover(tp,lp,REASON_EFFECT) end
end
