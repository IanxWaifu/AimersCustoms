--Scripted by Aimer
--Zefraalicorn Aurumajespecter
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	--Negate activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--cannot target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

s.listed_series={SET_MAJESPECTER,SET_ZEFRA}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_MAJESPECTER) or c:IsSetCard(SET_ZEFRA) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM 
end

function s.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsSetCard({SET_MAGICAL_MUSKET,SET_ZEFRA}) and c:IsFaceup()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.NegateEffect(ev) 
	end
end

--Check for valid Zefra target (face-up, has at least 1 archetype in its listed_series that exists in Deck)
function s.zefrafilter(c,tp)
	if not (c:IsFaceup() and c:IsSetCard(SET_ZEFRA)) then return false end
	-- loop through listed_series of this card
	local series=c.listed_series
	if not series then return false end
	for _,setcode in ipairs(series) do
		if Duel.IsExistingMatchingCard(s.archetypefilter,tp,LOCATION_DECK,0,1,nil,setcode) then
			return true
		end
	end
	return false
end

--Cost: send this card from hand to Extra Deck (face-up)
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoExtraP(e:GetHandler(),nil,REASON_COST)
end

--Check for valid Zefra target
function s.zefrafilter(c,tp)
	if not (c:IsFaceup() and c:IsSetCard(SET_ZEFRA)) then return false end
	local series=c.listed_series
	if not series then return false end
	for _,setcode in ipairs(series) do
		if Duel.IsExistingMatchingCard(s.archetypefilter,tp,LOCATION_DECK,0,1,nil,setcode) then
			return true
		end
	end
	return false
end

--Search filter
function s.archetypefilter(c,setcode)
	return c:IsSetCard(setcode) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end

--Target
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then 
		return Duel.IsExistingTarget(s.zefrafilter,tp,LOCATION_MZONE,0,1,nil,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.zefrafilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

--Operation
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local series=tc.listed_series
	if not series then return end
	local sg=Group.CreateGroup()
	for _,setcode in ipairs(series) do
		local g=Duel.GetMatchingGroup(s.archetypefilter,tp,LOCATION_DECK,0,nil,setcode)
		sg:Merge(g)
	end
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sel=sg:Select(tp,1,1,nil)
		if #sel>0 then
			Duel.SendtoHand(sel,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sel)
		end
	end
	--Optional: place target into Pendulum Zone
	if tc:IsType(TYPE_PENDULUM) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not tc:IsForbidden() then
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end