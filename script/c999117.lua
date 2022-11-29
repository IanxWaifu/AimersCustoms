--Scripted by IanxWaifu
--Wizardrake Affliction
local s,id=GetID()
function s.initial_effect(c)
   --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    -- Allow Fusion material from opp field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e) end)
	e1:SetValue(s.matval)
	e1:SetLabelObject({s.extrafil_replacement})
	c:RegisterEffect(e1)
	--Duel Environment
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--Fusion Eff
	local e3=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(s.dragfilter),matfilter=aux.FALSE,extrafil=s.extrafilter,stage2=s.stage2,extratg=s.extratg,extraop=s.extraop})
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,0})
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_series={0x12A7}
s.listed_names={id}

--Material Replacement
function s.matval(e,c)
	return c and c:IsRace(RACE_DRAGON) and c:IsControler(e:GetHandlerPlayer())
end
function s.extrafil_repl_filter(c)
	return c:IsMonster() and c:IsCanBeFusionMaterial() and c:IsRace(RACE_DRAGON)
end
function s.extrafil_replacement(e,tp,mg)
	local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return g,s.fcheck_replacement
end
function s.fcheck_replacement(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)
end


--Race Change
function s.rcfilter(c)
    return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and c:IsStatus(STATUS_SPSUMMON_TURN) and not c:IsRace(RACE_DRAGON)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.rcfilter,tp,0,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
    end
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.hcondition)
    e2:SetTarget(s.htarget)
    e2:SetOperation(s.hoperation)
    Duel.RegisterEffect(e2,tp)
end
function s.hfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_DRAGON) and c:IsSummonLocation(LOCATION_EXTRA) 
end
function s.hcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_FZONE) or not c:IsFaceup() or c:IsDisabled() then return end
    return eg:IsExists(s.hfilter,1,nil,tp)
end
function s.htarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=eg:GetFirst()
    if chk==0 then return tc end
    tc:CreateEffectRelation(e)
end
function s.hoperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=eg:GetFirst()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
    end
end


--Material Filters
function s.dragfilter(c)
	return c:IsRace(RACE_DRAGON) or c:IsSetCard(0x12A7)
end
function s.matfil(c,e,tp,chk)
	return not c:IsImmuneToEffect(e) and c:IsCanBeFusionMaterial()
end
function s.fexfilter(c,e)
	return ((c:IsLocation(LOCATION_PZONE) and c:IsDestructable() and c:IsSetCard(0x12A7)) or (c:IsLocation(LOCATION_MZONE))) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.Envfilter(c,e,tp)
	return (c:IsLocation(LOCATION_MZONE) and c:GetControler()==tp) or (c:IsLocation(LOCATION_PZONE) and c:IsSetCard(0x12A7) and c:GetControler()==tp and c:IsDestructable(e)) or (c:IsLocation(LOCATION_PZONE+LOCATION_MZONE) and c:IsRace(RACE_DRAGON)) and not c:IsImmuneToEffect(e) and c:IsCanBeFusionMaterial()
end
function s.extrafilter(e,tp,mg)
	if Duel.IsEnvironment(999117,tp) then
		local sg=Duel.GetMatchingGroup(s.Envfilter,tp,LOCATION_PZONE+LOCATION_MZONE,LOCATION_PZONE+LOCATION_MZONE,nil,e,tp)
		if sg and #sg>0 then
			return sg,s.fcheck
		end
	end
	local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_PZONE+LOCATION_MZONE,0,nil,e)
	if #sg>0 and not Duel.IsEnvironment(999117,tp) then
		return sg,s.fcheck
	end
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_PZONE+LOCATION_MZONE)
end

--Destroy Materials
function s.exfilter(c,tp)
	return c:IsLocation(LOCATION_PZONE) and c:IsControler(tp) and c:IsSetCard(0x12A7)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(s.exfilter,nil,tp)
	if #rg>0 then
		Duel.Destroy(rg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end




--Search
function s.thfilter(c)
	return c:IsSetCard(0x12A7) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
