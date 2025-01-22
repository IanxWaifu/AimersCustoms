--Scripted by IanxWaifu
--Fury of Eternal Macabre
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Special summon 3 tokens
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={id}
s.listed_series={SET_LEGION_TOKEN}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local clmgtable={}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetLabelObject(clmgtable)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) s.regop(e,tp,eg,ep,ev,re,r,rp,clmgtable) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e,tp,eg) return Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp,clmgtable)
	for tc in aux.Next(eg) do
		if tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(SET_LEGION_TOKEN) and tc:IsType(TYPE_TOKEN) then
			local clmg=tc:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
			if clmg:GetCount()>0 then
				-- Use :KeepAlive() to maintain the references
				clmg:KeepAlive()
				clmgtable[tc] = clmg
			end
		end
	end
end

function s.cfilter(c,tp)
	return c:IsSetCard(SET_LEGION_TOKEN) and c:IsType(TYPE_TOKEN)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.GetFlagEffect(tp,id)==0
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local clmgtable=e:GetLabelObject()
	if chk==0 then
		for _,clmg in pairs(clmgtable) do
			if clmg and clmg:GetCount()>0 then
				return true
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_ONFIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local clmgtable=e:GetLabelObject()
	if not clmgtable or next(clmgtable)==nil then return end
	local tg=Group.CreateGroup()
	for _,g in pairs(clmgtable) do
		if g and g:IsExists(Card.IsOnField,1,nil) then -- Ensure only valid cards are processed
			tg:Merge(g)
		end
	end
	if tg:GetCount()<=0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		Duel.Hint(HINT_CARD,0,id)
		Duel.Destroy(tg,REASON_EFFECT)
	end
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_EITHER,LOCATION_GRAVE)
end

--Remove
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	if #g<=0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tg=g:Select(tp,1,1,nil)
		Duel.Hint(HINT_CARD,0,id)
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT) 
	end
end