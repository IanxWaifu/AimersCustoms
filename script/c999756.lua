--Azhimaou - Seed of Enatos
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--Increase or Decrease Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	--Special Summon 1 monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,2})
	--[[e3:SetCondition(s.spcon)--]]
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	--Register summons
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3a:SetCode(EVENT_DESTROYED)
	e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetLabelObject(e3)
	e3a:SetOperation(s.regop)
	c:RegisterEffect(e3a)
end

s.listed_series={SET_AZHIMAOU}
s.listed_names={id}

function s.counterfilter(c)
	return c:IsSetCard(SET_AZHIMAOU)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_AZHIMAOU)
end

function s.thfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand() 
end
function s.tdfilter(c,tp,tcode)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode(),tcode)
end
function s.adfilter(c,code,tcode)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(code) and not c:IsCode(tcode)
end
function s.chkfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsType(TYPE_RITUAL)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil):GetFirst()
		if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 and sg:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			local chkmg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_GRAVE,0,nil)
			local mg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,tp,sg:GetCode())
			if #mg>0 and #chkmg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local td=mg:Select(tp,1,1,nil):GetFirst()
				local smg=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_DECK,0,nil,sg:GetCode(),td:GetCode())
				if td and #smg>0 and Duel.SendtoDeck(td,nil,2,REASON_EFFECT)>0 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local thg=smg:Select(tp,1,1,nil):GetFirst()
					Duel.SendtoHand(thg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,thg)
				end
			end
		end
	end
end


function s.lvfilter(c)
	return c:HasLevel() and c:IsSetCard(SET_AZHIMAOU) and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_SYNCHRO)) and ((c:IsLocation(LOCATION_HAND) and not c:IsPublic()) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sg=g:Select(tp,1,1,nil):GetFirst()
	Duel.HintSelection(sg)
	if sg:IsLocation(LOCATION_HAND) and not sg:IsPublic() then
		Duel.ConfirmCards(1-tp,sg)
	end
	local op=0
	local lv=sg:GetLevel()
	if lv>=9 then op=Duel.SelectOption(tp,aux.Stringid(id,5))
	else op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6)) end
	if op==0 then 
		local lv=sg:GetLevel()
	    local reduction=4
	    if lv-reduction<0 then
	        local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			sg:RegisterEffect(e1)
		else
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-reduction)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			sg:RegisterEffect(e1)
		end
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		sg:RegisterEffect(e1)
	end
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsRitualMonster() and c:IsControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
--[[function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,e,tp)
end--]]
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():Filter(s.spfilter,nil,e,tp,nil)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local tc=nil
	local g=e:GetLabelObject()
	if #g==0 then return end
	local sg=g:FilterSelect(tp,aux.NecroValleyFilter(s.spfilter),1,1,nil,e,tp)
	if sg and Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
		--Level Becomes 4
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		sg:GetFirst():RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local c=e:GetHandler()
	local tg=eg:Filter(aux.NecroValleyFilter(s.spfilter),nil,e,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end