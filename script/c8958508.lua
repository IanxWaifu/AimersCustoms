--Vylon Gamma
local s,id=GetID()
function s.initial_effect(c)
	--Synchro procedure
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,4,3,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats)
	--Can only be Special Summoned once per turn
	c:SetSPSummonOnce(id)
	--Shuffle any #
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.qcon1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.qcon2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_VYLON}

--Become Quick
function s.qcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not Duel.IsPlayerAffectedByEffect(tp,8958502) or not c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VYLON) 
end
function s.qcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsPlayerAffectedByEffect(tp,8958502) and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VYLON) 
end

--Materials
function s.vylonfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:IsEquipSpell() and c:IsSetCard(SET_VYLON)
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON,lc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_SYNCHRO,lc,SUMMON_TYPE_XYZ,tp) and c:GetEquipGroup():IsExists(s.vylonfilter,1,nil,tp) 
end

--Shuffle and Position Change
function s.tdfilter(c)
	return c:IsSetCard(SET_VYLON) and c:IsAbleToDeck() and (c:IsEquipSpell() or c:IsSynchroMonster())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,0,1-tp,1)
end

function s.setfilter(c)
	return c:IsMonster() and c:IsCanTurnSet()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,#g,nil)
	if #sg==0 then return end
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		--Get how many actually went to Deck
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
		local ct=#og
		local flips=math.floor(ct/3)
		if flips>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- select all at once
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tg=Duel.SelectMatchingCard(tp,s.setfilter,tp,0,LOCATION_MZONE,1,flips,nil)
			if #tg>0 then
				Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end


--Xyz Summon 1
function s.xyzfilter(c,e,tp,pg)
	return e:GetHandler():IsCanBeXyzMaterial(c,tp) and c:IsSetCard(SET_VYLON) and c:IsXyzMonster() and not c:IsCode(id) and (#pg<=0 or pg:IsContains(e:GetHandler()))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_XYZ)
		return #pg<=1 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,pg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,pg)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(c)
		Duel.Overlay(sc,c)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
