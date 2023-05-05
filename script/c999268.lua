--Scripted by IanxWaifu
--Daedric Relic, Deprivation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Special Summon Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--inactivatable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_SZONE)
--[[	e3:SetCondition(s.effcon)--]]
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end


--Special Summon Material
function s.spfilter(c,e,tp)
	return c:IsControler(tp) and c:IsSetCard(0x718) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup() 
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	return eg:IsExists(s.spfilter,1,nil,e,tp) and e:GetHandler():IsAbleToGrave()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsAbleToGrave() then return end
	local g=eg:Filter(s.spfilter,nil,e,tp)
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tc=g:Select(tp,1,1,nil)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	if c:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end



--[[function s.efilter(e,te)
	return te and te:GetColumnGroup(1,1):IsExists(function(c,tp,te)
		return c:IsControler(1-tp) 
	end,1,te,e:GetHandlerPlayer())
end--]]

function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return p==tp and tc:IsSetCard(0x718) 
end

--[[
function s.efilter(c,tp)
	local cg=c:GetColumnGroup(1,1)
	return cg:IsExists(s.fgfilter,1,nil,tp)
end
function s.fgfilter(c,tp)
	return c:IsSetCard(0x718) and c:IsOriginalType(TYPE_MONSTER) and c:IsFaceup() and c:GetControler()==tp
end
--]]

function s.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return tc:IsSetCard(0xed)
end
--[[
function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local cg=te:GetColumnGroup(1,1)
	return cg:IsExists(s.fgfilter,1,nil) and te:IsSetCard(0x718) and ((te:IsHasCategory(CATEGORY_SPECIAL_SUMMON)) or (te:IsActiveType(TYPE_MONSTER) and p==tp)) and cg:GetHandlerPlayer()==te:GetHandlerPlayer() 
end


function s.fgfilter(c)
	return c:IsSetCard(0x718) and ((c:IsLocation(LOCATION_PZONE)) or (c:IsType(TYPE_XYZ) or c:IsType(TYPE_RITUAL))) 
end

function s.efilter(e,te)
	local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION)
	return te:IsActivated() and loc==LOCATION_ONFIELD and e:GetHandlerPlayer()==1-te:GetHandlerPlayer() 
end
--]]