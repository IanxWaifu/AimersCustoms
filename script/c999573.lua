--Scripted by IanxWaifu
--Voldragocyene - Tombs of Permafrost
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Banish from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names = {id}
s.listed_series = {SET_VOLTAIC, SET_VOLTAIC_ARTIFACT, SET_VOLDRAGO}

function s.chfilter(c)
	return c:IsFaceup() and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_VOLTAIC_ARTIFACT)
end
function s.chvfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VOLDRAGO)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph~=PHASE_MAIN2 and (Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,nil) or Duel.IsExistingMatchingCard(s.chvfilter,tp,LOCATION_MZONE,0,1,nil))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end

function s.atkfilter(c)
	return c:IsAttackAbove(0) and c:IsFaceup()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local rs=g:RandomSelect(1-tp,1)
	local card=rs:GetFirst()
	if card==nil then return end
	if Duel.Remove(card,POS_FACEDOWN,REASON_EFFECT)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(card)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_MAIN2)
		Duel.RegisterEffect(e1,tp)
		card:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN2,0,1,fid)
		--Attack Reduction
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetTarget(s.atktg)
		e2:SetValue(s.value)
		e2:SetReset(RESET_PHASE+PHASE_BATTLE)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end


function s.atktg(e,c)
	return c:IsAttackAbove(0)
end
function s.value(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	return ct*-300
end