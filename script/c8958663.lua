--Scripted by Aimer
--Exosister Levina
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz Summon procedure
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- (1) Quick Effect: send all monsters in EMZ to GY, draw 1 for each sent
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- (2) Main Phase: detach 2 materials from your Xyz Monster(s);
	-- take 1 “Exosister” monster from Deck or GY and add or Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- (1) Quick Effect: send EMZ monsters to GY, draw for each
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ)
		and c:IsStatus(STATUS_SPSUMMON_TURN)
		and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,SET_EXOSISTER)
end
function s.emzfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()>=5 and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.emzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.emzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=#g
	if ct==0 or not Duel.IsPlayerCanDraw(tp,ct) then return end
	local sent=Duel.SendtoGrave(g,REASON_EFFECT)
	if sent>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,sent,REASON_EFFECT)
	end
end

-- (2) Main Phase: detach 2 materials; search/add or special summon
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_COST)
end

function s.thfilter(c,e,tp)
	return c:IsSetCard(SET_EXOSISTER) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g==0 then return end
	local tc=g:GetFirst()
	Duel.BreakEffect()
	aux.ToHandOrElse(tc,tp,
		function(c)
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(c)
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)

	-- Restrict Special Summons for rest of turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_EXOSISTER)
end
