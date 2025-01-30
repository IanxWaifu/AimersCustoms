--Novalxon Zenithal
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--When opponent Summons a monster(s)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--When opponent activates on field Effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.condition)
	e5:SetTarget(s.target2)
	e5:SetOperation(s.activate)
	c:RegisterEffect(e5)
	--Set this card from your banishment
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_REMOVED)
	e6:SetCountLimit(1,id)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NOVALXON),tp,LOCATION_ONFIELD,0,1,nil) end)
	e6:SetTarget(s.settg)
	e6:SetOperation(s.setop)
	c:RegisterEffect(e6)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NOVALXON),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.filter(c,e,tp)
	return c:IsFaceup() and not c:IsSummonPlayer(tp) and not c:IsImmuneToEffect(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg and eg:IsExists(s.filter,1,nil,e,tp) end
	local g=eg:Filter(s.filter,nil,e,tp)
	Duel.SetTargetCard(g)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if not (re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and tc:IsLocation(LOCATION_SZONE)) then return false end
	if chk==0 then return rp==1-tp and tc:IsFaceup() and not tc:IsImmuneToEffect(e) --[[and not tc:IsStatus(STATUS_ACTIVATED) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)--]] end
	Duel.SetTargetCard(tc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e) -- Get the targeted cards
	if #g>0 then
		g:KeepAlive()
		for tc in aux.Next(g) do
			--Client Hint
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local allcards=Duel.GetFieldGroup(tp,LOCATION_ALL,LOCATION_ALL)
			allcards:RemoveCard(tc)
			for tc2 in aux.Next(allcards) do
				--Cannot be targeted by card effects
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetLabelObject(tc) 
				e2:SetValue(s.val)
				e2:SetReset(RESET_PHASE+PHASE_END,2)
				tc2:RegisterEffect(e2)

				-- Create a field effect that restricts the targeting for the labeled cards
	--[[		local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD) 
				e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
				e2:SetLabelObject(tc)  
				e2:SetTarget(function(e, _c) local tc=e:GetLabelObject() return _c~=tc end)
				e2:SetValue(s.val)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)--]]
			end
		end
	end
end


-- Target value function to prevent targeting of other cards
function s.val(e,re,tp)
	return re:GetHandler()==e:GetLabelObject()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end