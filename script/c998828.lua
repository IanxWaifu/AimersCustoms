--Scripted by IanxWaifu
--Shio to Suna ★ Sunbathing!
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--self destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.descon)
	c:RegisterEffect(e1)
	--level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(aux.TargetBoolFunction(s.lvfilter))
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA,0)
	e2:SetValue(-1)
	c:RegisterEffect(e2)
end

function s.lvfilter(c)
	return c:IsSetCard(0x12F0) and not (c:IsFacedown() and c:IsLocation(LOCATION_EXTRA))
end

function s.thfilter(c)
	return (c:IsSetCard(0x12F0) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:GetSequence()==0 or c:GetSequence()==4 then
		-- Define temporary holder for the materials and (c)
		local selfseq=c:GetSequence()
	    local locs=LOCATION_EXTRA|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_HAND|LOCATION_SZONE
	    local TemporaryHolder=Duel.GetFieldGroup(tp,locs,locs):GetFirst()
	    -- Attach the card to the temporary holder
	    Duel.Overlay(TemporaryHolder,c)
	    -- Move the bottom material to the field
	    Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true,1<<selfseq)
	    Pendulum.AddProcedure(c)
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fc0000)
		e1:SetValue(TYPE_SPELL+TYPE_PENDULUM)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetCode(EFFECT_REMOVE_TYPE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+0x1fc0000)
		e2:SetValue(TYPE_CONTINUOUS)
		c:RegisterEffect(e2)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_LSCALE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetReset(RESET_EVENT+0x1fc0000)
		e4:SetValue(7)
		c:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_CHANGE_RSCALE)
		c:RegisterEffect(e5)
		Duel.AdjustInstantly()
	end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.descon(e)
	return e:GetHandler():GetLeftScale()<=0
end
