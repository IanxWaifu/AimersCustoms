--Scripted by IanxWaifu
--Voltaic Artifact-Primordial Core
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--pendulum become quick
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(VOLTAICPENDQ)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	--once per turn quick monster
	local e4=e3:Clone()
	e4:SetCode(VOLTAICMONQ)
	c:RegisterEffect(e4)
	--once per turn quick equip
	local e5=e3:Clone()
	e5:SetCode(VOLTAICEQUQ)
	c:RegisterEffect(e5)
end
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC_ARTIFACT}

function s.posfilter(c)
	return c:IsSetCard(SET_VOLTAIC) and c:IsOriginalType(TYPE_MONSTER) and c:IsCanChangePosition()
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_ONFIELD,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
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

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(SET_VOLTAIC) or c:IsSetCard(SET_VOLDRAGO)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end