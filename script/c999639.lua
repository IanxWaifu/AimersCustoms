--Scripted by IanxWaifu
--Archdaemon Taamuz, The Malefactor
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,5,2,nil,nil,99)
	c:EnableReviveLimit()
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end

s.listed_names={id}
s.listed_series={SET_ARCHDAEMON,SET_NECROTICRYPT,SET_DEATHRALL,SET_DIVINE_,SET_DAEDRIC_RELIC,SET_LEGION_TOKEN}

--Destroy
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_LEGION_TOKEN) and c:IsDestructable()
end

function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetRace)==#sg
end

function s.ctfilter(c)
	return ((c:ListsArchetype(SET_LEGION_TOKEN)) or (c:IsSetCard(0x129f)) or (c:IsSetCard(0x719)) or (c:IsSetCard(0x12E0))) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local og=c:GetOverlayCount()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetClassCount(Card.GetRace)
	if og>ct then og=ct end
	if chk==0 then 
		-- Check for Deathrall Trap Cards in the deck
		local deathrall_count = Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
		-- Check for available S/T zones
		local available_zones = Duel.GetLocationCount(tp,LOCATION_SZONE)
		-- Ensure og does not exceed the minimum of ct, deathrall_count, or available_zones
		og = math.min(og, ct, deathrall_count, available_zones)
		return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and og>0 and #g>0 and aux.SelectUnselectGroup(g,e,tp,1,og,s.rescon,chk)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local og=c:GetOverlayCount()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetClassCount(Card.GetRace)
	-- Check for Deathrall Trap Cards in the deck
	local deathrall_count = Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
	-- Check for available S/T zones
	local available_zones = Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- Ensure og does not exceed the minimum of ct, deathrall_count, or available_zones
	og = math.min(og, ct, deathrall_count, available_zones)
	local xyzct=c:RemoveOverlayCard(tp,1,og,REASON_EFFECT)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,xyzct,s.rescon,1,tp,HINTMSG_DESTROY)
	if #sg>0 then
	 	Duel.HintSelection(sg)
		if Duel.Destroy(sg,REASON_EFFECT)>0 then
			-- Select and set Deathrall Trap Cards
			local deathrall = Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil)
			local deathrall_to_set = deathrall:Select(tp,xyzct,xyzct,nil)
			Duel.BreakEffect()
			Duel.SSet(tp,deathrall_to_set)
			for tc in deathrall_to_set:Iter() do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
				tc:RegisterEffect(e1)
			end
		end
	end
end
