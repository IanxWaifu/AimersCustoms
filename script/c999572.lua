--Scripted by IanxWaifu
--Voldragocyene - Passage of Decimation
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Negate the effect of monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC, SET_VOLTAIC_ARTIFACT, SET_VOLDRAGO, SET_DRAGOCYENE}

function s.chfilter(c)
	return c:IsFaceup() and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VOLTAIC_ARTIFACT)
end
function s.chvfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DRAGOCYENE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,nil) or Duel.IsExistingMatchingCard(s.chvfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.ffilter(c)
	return ((c:IsFaceup() and c:IsCanTurnSet()) or c:IsFacedown()) and c:IsOriginalType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.ffilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
    	for tc in aux.Next(g) do
            Aimer.FlipCard(e,tc,tp)
        end
    end
end