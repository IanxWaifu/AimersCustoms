--帝王の極致
--Monarchic Perfection
--Scripted by The Razgriz
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_KEGAI}


function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_KEGAI) and c:IsAbleToHand()
end
function s.pcfilter(c,tp)
    return c:IsSetCard(SET_KEGAI) and c:IsMonster() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.setfilter(c)
	return c:IsTrap() and c:IsSSetable() and c:IsSetCard(SET_KEGAI)
end


function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then return true end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cost_skip=e:GetLabel()~=-100
	--Search
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	--Place to S/T Zone
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_HAND,0,1,nil,tp)
	--Send to GY and Set To Field
	local b3=(cost_skip or not Duel.HasFlagEffect(tp,id+2)) and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and e:GetHandler():IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then e:SetLabel(0) return (b1 or b2 or b3) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		--Search
		e:SetCategory(CATEGORY_TOHAND)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK)
	elseif op==2 then
		--Place to S/T Zone
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
	elseif op==3 then
		--Send to GY and Set To Field
		e:SetCategory(CATEGORY_TOGRAVE)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,0,tp,LOCATION_SZONE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		--Search
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		--Place to S/T Zone
		local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_HAND,0,nil,tp)
	    if #g>0 then
	        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	        local tc=g:Select(tp,1,1,nil):GetFirst()
	        if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
	            --Treat it as a Continuous Spell
	            local e1=Effect.CreateEffect(c)
	            e1:SetType(EFFECT_TYPE_SINGLE)
	            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	            e1:SetCode(EFFECT_CHANGE_TYPE)
	            e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
	            e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET)
	            tc:RegisterEffect(e1)
	        end
	    end
	elseif op==3 then
		--Send to GY and Set To Field
		if not (c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE)) then return end 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if g and Duel.SSet(tp,g)>0 then
			--It can be activated this turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCondition(s.actcon)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			g:RegisterEffect(e1)
		end
	end
end

function s.actcon(e,c)
	local ct1=Duel.GetMatchingGroupCount(nil,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
	local ct2=Duel.GetMatchingGroupCount(nil,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,nil)
	return ct1<ct2
end