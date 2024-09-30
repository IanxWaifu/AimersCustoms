--Azhimalefactor Apotheosis
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_AZHIMAOU}

function s.tgfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToGrave() and (c:IsFaceup() or not c:IsOnField())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT) and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==1 and Duel.IsPlayerCanDraw(tp) then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
		local tc=Duel.GetOperatedGroup()
		Duel.ConfirmCards(1-tp,tc)
		local dg=tc:Filter(s.rmfilter,nil)
			if #dg>0 then
			Duel.BreakEffect()
			Duel.HintSelection(dg)
			Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

function s.rmfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_DRAW) and not c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToRemove()
end