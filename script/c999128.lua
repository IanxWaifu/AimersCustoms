--Scripted by IanxWaifu
--Wizardrake Assimilation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(s.dragfilter),matfilter=aux.FALSE,extrafil=s.extrafilter,stage2=s.stage2,extratg=s.extratg,extraop=s.extraop})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	-- Set self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- Check for Wizardrake destroyed
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x12A7}
s.listed_names={id}

-- global check
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsType(TYPE_PENDULUM) and tc:IsSetCard(0x12A7) then 
			Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end


--Material Filters
function s.dragfilter(c)
	return c:IsSetCard(0x12A7)
end
function s.fexfilter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and ((c:IsLocation(LOCATION_GRAVE)) or (c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)))
end
function s.Envfilter(c,e,tp)
	return (c:GetControler()==tp and ((c:IsLocation(LOCATION_GRAVE)) or (c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)))) or (c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_DRAGON) and c:IsAbleToRemove())
	or (c:IsLocation(LOCATION_PZONE) and c:IsRace(RACE_DRAGON) and c:IsAbleToRemove()) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.extrafilter(e,tp,mg)
	if Duel.IsEnvironment(999117,tp) then
		local sg=Duel.GetMatchingGroup(s.Envfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_PZONE+LOCATION_MZONE,LOCATION_PZONE+LOCATION_MZONE,nil,e,tp)
		if sg and #sg>0 then
			return sg,s.envfcheck
		end
	end
	local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
	if #sg>0 and not Duel.IsEnvironment(999117,tp) then
		return sg,s.fcheck
	end
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.envfcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_MZONE+LOCATION_PZONE)
end

--Extra Filters
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end


function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_MZONE+LOCATION_PZONE)
	if #rg<0 then return false end 
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
--Set self
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return e:GetHandler():IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
   Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   if c:IsRelateToEffect(e) and c:IsSSetable() then
      Duel.SSet(tp,c)
      --Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
   end
end
