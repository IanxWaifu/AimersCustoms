--Sylvestrie Faelnir
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--If Normal or Special Summoned: Owner sends 1 "Sylvestrie" card from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If used as material for the Special Summon of a "Sylvestrie" monster: Set 1 S/T from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_SYLVESTRIE}

--"Sylvestrie" filter
function s.gyfilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsAbleToGrave()
end

--Owner sends from Deck
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local owner=c:GetOwner()
	if Duel.IsExistingMatchingCard(s.gyfilter,owner,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,owner,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(owner,s.gyfilter,owner,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end


--Be Material
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:GetReasonCard():IsSetCard(SET_SYLVESTRIE) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

--Set S/T from Deck
function s.setfilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsSpellTrap() and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end