--Scripted by IanxWaifu
--Revelatia - Orbitalis
local s,id=GetID()
function s.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Material Fusion
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.matcon)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
function s.thfilter(c)
	return c:IsSetCard(0x19f) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
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

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_FUSION and c:GetReasonCard():IsSetCard(0x19f)
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	--Custom Fusion Activation
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x19f),matfilter=s.matfil,extrafil=s.extrafilter,extraop=s.extraop})
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,{id,1})
	e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
	AshBlossomTable=AshBlossomTable or {}
	table.insert(AshBlossomTable,e1)
end

--Material Check
function s.matfil(c,e,tp,chk)
	return (c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE)) or (c:IsAbleToDeck() and c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)) 
end
function s.filter(c)
	return (c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE)) or (c:IsAbleToDeck() and c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)) or (c:IsAbleToGrave() and c:IsLocation(LOCATION_DECK))
end

--Flag Check for 1 Deck Material and Gy banish
function s.checkmat(tp,sg,fc)
	return fc:IsType(TYPE_FUSION) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end

function s.extrafilter(e,tp,mg)
	if Duel.GetFlagEffect(tp,998858)>0 then
		local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end



--Remove Materials
function s.extraop(e,tc,tp,sg)
	local tg=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #tg>0 and Duel.GetFlagEffect(tp,998858)>0 then
	Duel.ResetFlagEffect(tp,998858) end
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED)
	if #rg>0 then
		Duel.SendtoDeck(rg,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end