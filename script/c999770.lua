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
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Fusion from GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_AZHIMAOU}

function s.tgfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToGrave() and (c:IsFaceup() or not c:IsOnField())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT) and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==1 and Duel.IsPlayerCanDraw(tp) then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
		local tc=Duel.GetOperatedGroup()
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)  
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

--Fusion Summon

function s.exfilter(c,e,tp,sg)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_AZHIMAOU) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
end

function s.cfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToRemove() and c:IsSpellTrap() and not c:IsCode(id)
end
function s.rescon(sg,e,tp,mg)
	local countmatch=#sg==sg:GetClassCount(Card.GetCode)
	return countmatch and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg),not countmatch
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,c)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) and c:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,c)
    if #g==0 or not c:IsAbleToRemove() then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	sg:AddCard(c)
	local fdg=sg:Filter(aux.AND(Card.IsFacedown,Card.IsOnField),nil)
	if #fdg>0 then
		Duel.ConfirmCards(1-tp,fdg)
	end
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	local ssg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #ssg>0 then
		Duel.SpecialSummon(ssg,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		ssg:GetFirst():CompleteProcedure()
	end
end