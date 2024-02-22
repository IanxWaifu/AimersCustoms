--Scripted by IanxWaifu
--Deathrall Sinduroth
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Tribute and draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}

--Special Proc
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOKEN) and c:IsRace(RACE_PYRO)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end


--Send + Add from GY
function s.tgfilter1(c)
	return (c:ListsArchetype(SET_LEGION_TOKEN) or c:IsSetCard(SET_DEATHRALL)) and c:IsAbleToGrave()
end
function s.tgfilter2(c,code)
	return (c:ListsArchetype(SET_LEGION_TOKEN) or c:IsSetCard(SET_DEATHRALL)) and c:IsAbleToHand() and not c:IsCode(code) and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		local tc=g:GetFirst()
		local mg=Duel.GetMatchingGroup(s.tgfilter2,tp,LOCATION_GRAVE,0,nil,tc:GetCode())
		if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end


--Tribute and Draw
function s.drfilter(c,race)
	return c:IsType(TYPE_TOKEN) and not c:IsRace(race)
end


function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local race=c:GetRace()
    if chk==0 then
        return Duel.CheckReleaseGroupCost(tp, function(c) return s.drfilter(c,race) end,1,false,nil,nil)
    end
    local g=Duel.SelectReleaseGroupCost(tp, function(c) return s.drfilter(c,race) end,1,1,false,nil,nil)
    Duel.Release(g,REASON_COST)
end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc~=c end
	if chk==0 then return ct>=2 and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT) 
	end
end