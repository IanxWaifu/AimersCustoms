--Scripted by IanxWaifu
--Divine-Eye's Awakening
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
s.listed_series={0x12D9}

local ATTRIBUTES=ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND|ATTRIBUTE_DARK|ATTRIBUTE_LIGHT
function s.counterfilter(c)
	return c:IsSetCard(0x12D9)
end
function s.rescon(sg,e,tp,mg)
	return true,not sg:CheckDifferentPropertyBinary(function(c)return c:GetAttribute()&(ATTRIBUTES)end)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local matg=Duel.GetOverlayGroup(tp,LOCATION_MZONE,0)
    if chk==0 then return aux.SelectUnselectGroup(matg,e,tp,2,2,s.rescon,0) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
    local tg=aux.SelectUnselectGroup(matg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
    Duel.SendtoGrave(tg,REASON_COST)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x12D9)
end


---Target Player Cannot Activate
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--chain resolve attach
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAIN_ACTIVATING)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.actlimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end

--Change ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and (re:GetHandler():IsType(TYPE_XYZ) or re:GetHandler():IsType(TYPE_FUSION) or re:GetHandler():IsType(TYPE_LINK)) and re:GetHandler():IsSetCard(0x12D9)
end
function s.atkfilter(c)
	return c:IsFaceup() and not (c:IsAttack(0) and c:IsDefense(0))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if #g<=0 or rp~=tp or not (re:GetHandler():IsType(TYPE_XYZ) or re:GetHandler():IsType(TYPE_FUSION) or re:GetHandler():IsType(TYPE_LINK))  or not re:GetHandler():IsSetCard(0x12D9) then return end
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		Duel.Hint(HINT_CARD,0,id)
		local sg=g:Select(tp,1,1,nil)
		local tg=sg:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tg:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tg:RegisterEffect(e2)
		--Banish it if it leaves the field
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(3300)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tg:RegisterEffect(e3)
	end
end

--Draw
function s.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12D9) and c:IsAbleToRemoveAsCost()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) 
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
