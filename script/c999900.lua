--Scripted by Aimer
--Kegai - Akujü Madowashi Yöma
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	Aimer.KegaiAddSynchroMaterialEffect(c)
	--Place itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.pccost)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--Special Summon this card if it is a Continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--be material
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.ccon)
	e3:SetTarget(s.cctg)
	e3:SetOperation(s.ccop)
	c:RegisterEffect(e3)
end

function s.counterfilter(c)
	return c:IsSetCard(SET_KEGAI) or not c:IsSummonLocation(LOCATION_DECK|LOCATION_GRAVE)
end
function s.pccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	--Cannot Special Summon from the Deck or Extra Deck, except Fiend monsters
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetTarget(function(e,c) return c:IsLocation(LOCATION_DECK|LOCATION_GRAVE) and not c:IsSetCard(SET_KEGAI) end)
	Duel.RegisterEffect(e2,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,function(e,c) return not c:IsSetCard(SET_KEGAI) end)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_DECK|LOCATION_GRAVE) and not c:IsSetCard(SET_KEGAI)
end

--summonself
function s.spconfilter(c,tp)
	return c:IsSetCard(SET_KEGAI) and c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end


--Place self
function s.tffilter(c,tp)
	return c:IsSetCard(SET_KEGAI) and c:IsSpellTrap() and not c:IsForbidden() and c:CheckUniqueOnField(tp) 
	and ((c:IsType(TYPE_FIELD)) or (c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0))
end
function s.rfilter(c)
	return c:IsSetCard(SET_KEGAI) and not c:IsPublic() and c:IsAbleToDeck()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden() end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_HAND,0,e:GetHandler())
	local ag=Duel.GetMatchingGroup(s.tffilter,tp,LOCATION_DECK,0,nil,tp)
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) and #g>0 and #ag>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,1,1,nil):GetFirst()
		Duel.ConfirmCards(1-tp,sg)
		if Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
		if not Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_DECK|LOCATION_EXTRA) then return end
		local tf=ag:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	    if tf then
	        if tf:IsType(TYPE_FIELD) then
	            Duel.MoveToField(tf,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	        else
	            Duel.MoveToField(tf,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	        end
	    end
	end
end

--Be Material
function s.ccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) and c:GetReasonCard():IsSetCard(SET_KEGAI) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.cctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if chk==0 then return rc:IsFaceup() and rc:IsLocation(LOCATION_MZONE) end
end

function s.ccop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc:IsFaceup() or not rc:IsLocation(LOCATION_MZONE) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	rc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	rc:RegisterEffect(e2)
end