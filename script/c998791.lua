--Scripted by IanxWaifu
--Girls’&’Artillery - Magist
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x12EE,0x12EF}
function s.tgfilter(c)
	return (c:IsSetCard(0x12EE) or c:IsSetCard(0x12EF)) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end


function s.psetfilter(c,tp,cg)
	return c:IsFaceup() and c:IsSetCard(0x12EE) and cg:GetColumnGroup():IsContains(c)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.psetfilter,1,nil,tp,e:GetHandler())
end



function s.setfilter(c)
	return c:IsSetCard(0x12EF) and c:IsSpellTrap() and ((c:IsSSetable()) or (not c:IsForbidden()))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local b1=c:IsSSetable()
		local b2=c:IsForbidden()
		local op=0
		if b1 and not b2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(id,2))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
		end
		if op==2 then return end
		if op==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			Duel.SSet(tp,g)
		else
			local tc=g:GetFirst()
			if tc then
				local type=tc:GetOriginalType()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
				if tc:IsType(TYPE_FIELD) then
  					Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
    			else
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetCode(EFFECT_CHANGE_TYPE)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
					e1:SetValue(type+TYPE_CONTINUOUS)
					tc:RegisterEffect(e1)
				end
			end
		end
	end
end


function s.spfilter(c,e,tp,ct)
	return c:IsSetCard(0x12EE) and c:IsLinkBelow(ct) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lkcheck(c)
	return c:IsSetCard(0x12EE) and c:IsType(TYPE_LINK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.lkcheck,tp,LOCATION_MZONE,0,nil)
	local ct=dg:GetSum(Card.GetLink)
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local dg=Duel.GetMatchingGroup(s.lkcheck,tp,LOCATION_MZONE,0,nil)
	local ct=dg:GetSum(Card.GetLink)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ct)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end