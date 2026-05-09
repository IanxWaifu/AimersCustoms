--Scripted by Aimer
--Genosynx Assimilation
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Place 1 or add
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

-- Special Summon 1 "Genosynx" monster or Trap as a monster, from hand/Deck
function s.ssmonfilter(c,e,tp)
	return c:IsSetCard(SET_GENOSYNX) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.sstrapfilter(c,tp)
	if not (c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_TRAP)) then return false end
	if c:IsForbidden() then return false end
	return Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK)
end

function s.ssfilter(c,e,tp)
	if c:IsMonster() then
		return s.ssmonfilter(c,e,tp)
	else
		return s.sstrapfilter(c,tp)
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=0
	if c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_SZONE) then ft=ft+1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>ft and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=0
	if c:IsLocation(LOCATION_SZONE) then ft=ft+1 end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=ft then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if tc:IsMonster() then
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		else
			tc:AddMonsterAttribute(TYPE_EFFECT|TYPE_SPIRIT|TYPE_TRAP)
			tc:AddMonsterAttributeComplete()
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_BEAST)
			e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
			tc:RegisterEffect(e1,true)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e3:SetValue(ATTRIBUTE_DARK)
			tc:RegisterEffect(e3,true)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CHANGE_LEVEL)
			e4:SetValue(4)
			tc:RegisterEffect(e4,true)
			local e5=e1:Clone()
			e5:SetCode(EFFECT_SET_BASE_ATTACK)
			e5:SetValue(1000)
			tc:RegisterEffect(e5,true)
			local e6=e1:Clone()
			e6:SetCode(EFFECT_SET_BASE_DEFENSE)
			e6:SetValue(1000)
			tc:RegisterEffect(e6,true)
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		end
		Duel.BreakEffect()
		local tg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND|LOCATION_ONFIELD,0,e:GetHandler())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg2=tg:Select(tp,1,1,nil)
		if #tg2>0 then
			Duel.SendtoGrave(tg2,REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,tc) return not tc:IsSetCard(SET_GENOSYNX) and not tc:IsType(TYPE_SPIRIT) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
	end
end

--Place or Add
function s.plthfilter(c,tohand_chk)
	return (c:IsCode(82473011) and not c:IsForbidden()) or (tohand_chk and c:IsSetCard(SET_GENOSYNX) and c:IsSpell() and c:IsAbleToHand() and c:IsLocation(LOCATION_DECK) and not c:IsCode(id))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local tohand_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,82473011),tp,LOCATION_ONFIELD,0,1,nil)
		return Duel.IsExistingMatchingCard(s.plthfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tohand_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tohand_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,82473011),tp,LOCATION_ONFIELD,0,1,nil)
	local hint_desc=tohand_chk and aux.Stringid(id,2) or HINTMSG_TOFIELD
	Duel.Hint(HINT_SELECTMSG,tp,hint_desc)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plthfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tohand_chk):GetFirst()
	if not sc then return end
	if sc:IsCode(82473011) then
		if not tohand_chk then
			Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		else
			aux.ToHandOrElse(sc,tp,
				function() return tohand_chk and not sc:IsForbidden() end,
				function() Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) end,
				aux.Stringid(id,3)
			)
		end
	else
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	end
end