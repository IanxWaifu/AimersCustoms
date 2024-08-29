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
            if tc:IsMonster() then
                local chpos=0
                local pos=tc:GetPosition()
                local isFaceup=(pos&POS_FACEUP)~=0
                local isFacedown=(pos&POS_FACEDOWN_DEFENSE)~=0
                if isFaceup then
                    chpos=POS_FACEDOWN_DEFENSE
                elseif isFacedown then
                    -- Choose between POS_FACEUP_ATTACK and POS_FACEUP_DEFENSE
                    chpos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
                end
                Duel.ChangePosition(tc,chpos)
            else
                local chpos=0
                local pos=tc:GetPosition()
                local isFaceup=(pos&POS_FACEUP)~=0
                local isFacedown=(pos&POS_FACEDOWN)~=0
                if isFaceup then
                    chpos=POS_FACEDOWN
                elseif isFacedown then
                    chpos=POS_FACEUP
                end
                if chpos==POS_FACEDOWN then
                    Duel.ChangePosition(tc,chpos)
                    Duel.RaiseSingleEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
                    Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
                elseif chpos==POS_FACEUP then
                    Duel.ChangePosition(tc,chpos)
                    Duel.RaiseSingleEvent(tc,EVENT_CHANGE_POS,e,REASON_EFFECT,tp,tp,0)
                    Duel.RaiseEvent(tc,EVENT_CHANGE_POS,e,REASON_EFFECT,tp,tp,0)
                end
            end
        end
    end
end