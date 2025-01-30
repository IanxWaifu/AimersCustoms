--Novalxon Prismel
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Apply Astral Shift
	Aimer.AddAstralShift(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsMainPhase() and e:GetHandler():GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==0 end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Extra Material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_HAND)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_EXTRA_ASTRAL)
	e4:SetTarget(s.extratg)
	c:RegisterEffect(e4)
	--ASTRAL STATE-- Return Cards
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCondition(s.rtcon)
	e5:SetTarget(s.rttg)
	e5:SetOperation(s.rtop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_NOVALXON}
s.listed_names={id}
s.astral_shift={id}

function s.extratg(c)
	if c:GetFlagEffect(id)>0 then return false end
    local hasEffect = c:IsHasEffect(EFFECT_EXTRA_ASTRAL)
    local correctLocation = c:IsLocation(LOCATION_HAND)
    return hasEffect and correctLocation and c:GetFlagEffect(id)==0
end

function s.cfilter(c)
	return c:IsSetCard(SET_NOVALXON) and c:IsMonster() and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NOVALXON) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,c,e,tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,c):GetFirst()
	local AstralCheck=false
	if tc and tc:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)>0 then
		AstralCheck=true
	end
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
			if #rg<=0 or AstralCheck==false then return end
				if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then 
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local rtg=rg:Select(tp,1,1,nil)
				Duel.Remove(rtg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end


--Astral Effect
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==1
end

function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local oc=e:GetHandler():GetOverlayCount()
	if chk==0 then return oc>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local oc=e:GetHandler():GetOverlayCount()
	if oc<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,oc,c)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_ASTRAL_EFFECT_PROC,e,0,0,0,0)
	e:GetHandler():RegisterFlagEffect(REGISTER_FLAG_ASTRAL_STATE,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET,0,0)
end