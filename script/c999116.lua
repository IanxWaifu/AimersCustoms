--Scripted by IanxWaifu
--Wizardrake Castigation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(s.dragfilter),matfilter=aux.FALSE,extrafil=s.extrafilter,stage2=s.stage2,extratg=s.extratg,extraop=s.extraop})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--Destroy PZones
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={0x12A7}
s.listed_names={id}

--Sp Summon Checks
function s.counterfilter(c)
	return ((c:IsType(TYPE_FUSION)) or (c:IsSetCard(0x12A7)) or (c:IsType(TYPE_PENDULUM)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
end
function s.splimit(e,c)
	return not (c:IsType(TYPE_FUSION)) and not (c:IsSetCard(0x12A7)) and not (c:IsType(TYPE_PENDULUM)) and c:IsLocation(LOCATION_EXTRA)
end


--Material Filters
function s.dragfilter(c)
	return c:IsRace(RACE_DRAGON) or c:IsSetCard(0x12A7)
end
function s.matfil(c,e,tp,chk)
	return c:IsDestructable(e) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.fexfilter(c,e)
	return c:IsDestructable(e) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.Envfilter(c,e,tp)
	return (c:GetControler()==tp and c:IsLocation(LOCATION_PZONE+LOCATION_MZONE+LOCATION_HAND)) or (c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_DRAGON) and c:GetControler()==1-tp and c:IsDestructable(e))
	or (c:IsLocation(LOCATION_PZONE) and c:GetControler()==1-tp and c:IsDestructable(e)) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.extrafilter(e,tp,mg)
	if Duel.IsEnvironment(999117,tp) then
		local sg=Duel.GetMatchingGroup(s.Envfilter,tp,LOCATION_PZONE+LOCATION_MZONE+LOCATION_HAND,LOCATION_PZONE+LOCATION_MZONE,nil,e,tp)
		if sg and #sg>0 then
			return sg,s.fcheck
		end
	end
	local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_PZONE+LOCATION_MZONE+LOCATION_HAND,LOCATION_PZONE,nil,e,tp)
	if #sg>0 and not Duel.IsEnvironment(999117,tp) then
		return sg,s.fcheck
	end
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_PZONE+LOCATION_MZONE+LOCATION_HAND)
end


--Extra Filters
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,LOCATION_MZONE+LOCATION_PZONE+LOCATION_HAND)
end

function s.rfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_MZONE+LOCATION_PZONE+LOCATION_HAND)
	if #rg>0 then
	Duel.Destroy(rg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Sub(rg)
	local dg=rg:Filter(s.rfilter,nil,tp)
		if #dg>1 and Duel.IsPlayerCanDraw(tp,1) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--Destroy Pends+Return
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,LOCATION_PZONE)>1
		and e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,1,1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	if #g<2 then return end
		local dg=g:Select(tp,2,2,nil)
		Duel.HintSelection(dg)
		if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		if e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsAbleToHand() then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
