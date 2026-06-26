--Scripted by Aimer
--Sylvestrie and the Eave of the Verdantrie
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Shuffle and Place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SYLVESTRIE}

function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand() and c:IsSetCard(SET_SYLVESTRIE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.ffilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsType(TYPE_FIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)>0
		and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ffilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc=dg:Select(tp,1,1,nil):GetFirst()
			if not tc then return end
			local op=Duel.SelectEffect(tp,{true,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
			local target_player=op==1 and tp or 1-tp
			local fc=Duel.GetFieldCard(target_player,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
			end
			Duel.MoveToField(tc,tp,target_player,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end


function s.tdfilter(c,tp)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsType(TYPE_FIELD) and c:IsFaceup() and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.plfilter(c,code)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and not c:IsCode(code)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.tdfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local code=tc:GetCode()
	if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,code)
		local sc=sg:GetFirst()
		if sc then
			local op=Duel.SelectEffect(tp,{true,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
			local target_player=op==1 and tp or 1-tp
			local fc=Duel.GetFieldCard(target_player,LOCATION_FZONE,0)
			if fc then Duel.SendtoGrave(fc,REASON_RULE) end
			Duel.MoveToField(sc,tp,target_player,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end