--Scripted by IanxWaifu
--Voltaic Stormwolf, Aaliyah
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	-- Search "Voltaic" Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.tftg)
	e2:SetOperation(s.tfop)
	c:RegisterEffect(e2)
end
   

s.listed_names = {id}
s.listed_series = {SET_VOLTAIC}


function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_COST,tp,tp,0)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsDisabled()
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_COST,tp,tp,0)
end
function s.thfilter(c)
	return c:IsSetCard(SET_VOLTAIC) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
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
		local tc=g:GetFirst()
		local dg=Duel.GetMatchingGroup(Aimer.CanMoveCardToAppropriateZone,tp,0,LOCATION_ONFIELD,nil,1-tp)
		if #dg>0 and tc:IsLocation(LOCATION_HAND) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local tg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(tg)
            local tdg=tg:GetFirst()
            local p=tdg:GetControler()
            Aimer.MoveCardToAppropriateZone(tdg,p)
		end
	end
end

function s.tffilter(c,tp)
	return c:IsSpellTrap() and ((c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or c:IsType(TYPE_FIELD)) and c:IsSetCard(SET_VOLTAIC) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_FIELD),tp,LOCATION_FZONE,0,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if tc then
        if tc:IsType(TYPE_FIELD) then
            Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
        else
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    end
end
