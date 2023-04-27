--Wizardrake Transformation
--Scripted by IanxWaifu
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 pendulum monster from deck into pendulum zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	-- Set self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
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

s.listed_names={id}
s.listed_series={0x12A7}

-- global check
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsType(TYPE_PENDULUM) and tc:IsSetCard(0x12A7) then 
			Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

--Pendulum Place
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:IsSetCard(0x12A7)
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(1-tp,LOCATION_PZONE,0) or Duel.CheckLocation(1-tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckLocation(1-tp,LOCATION_PZONE,0) and not Duel.CheckLocation(1-tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.MoveToField(g:GetFirst(),tp,1-tp,LOCATION_PZONE,POS_FACEUP,true) then
		--Apply Continuous
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetCountLimit(1,{id,2})
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
		g:GetFirst():RegisterFlagEffect(id+1,RESET_EVENT+RESET_TOFIELD|RESET_TURN_SET,0,1)
	end
end

--Target and Destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsPreviousLocation(LOCATION_ONFIELD) and tc:GetFlagEffect(id+1)>0 and tc:GetPreviousControler()==1-tp
end


function s.desfilter(c,e)
	return c:IsDestructable(e)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) and tc:GetFlagEffect(id+1)>0 then
		tc:ResetFlagEffect(id+1)
		Duel.BreakEffect()
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
		Duel.Destroy(dg,REASON_EFFECT)
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
