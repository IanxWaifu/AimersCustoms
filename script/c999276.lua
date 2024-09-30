--Scripted by IanxWaifu
--Daedric Relics, Nihility
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x718,0x719}

function s.filter(c)
	return c:IsSetCard(0x718) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		--cannot disable
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetRange(LOCATION_MZONE)
		e0:SetValue(s.cnvalue)
		e0:SetCode(EFFECT_CANNOT_DISEFFECT)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_INACTIVATE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(s.cnvalue)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
		--Increase ATK
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetValue(1000)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetTargetRange(0,LOCATION_SZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
end

function s.cnvalue(e,ct)
	return Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT):GetHandler()==e:GetHandler()
end
function s.checkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x718)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    if re:IsActiveType(TYPE_FIELD) or rp==tp or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or not Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil) then
        return false
    end
    local rg=Duel.GetMatchingGroup(s.checkfilter,tp,LOCATION_ONFIELD,0,nil)
    local te,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_SEQUENCE)
    local tc=te:GetHandler()
    local seq = tc:GetSequence()
    local loc = tc:GetLocation()
	if loc == LOCATION_FIELD then return false end
    local seqbit = bit.lshift(1, seq)
    -- Special handling for Pendulum Zones
    if loc == LOCATION_PZONE then
        -- Pendulum Zones use special sequence values
        if seq == 6 then
            seqbit = 0x1  -- Left Pendulum Zone
        elseif seq == 7 then
            seqbit = 0x20  -- Right Pendulum Zone
        end
    end
    -- Get the column groups, adjusting for Pendulum Zones
    local cg = tc:GetColumnGroup(1, 1)
    local cg2 = tc:GetColumnGroup()
    for g in aux.Next(rg) do
        if cg:IsContains(g) or cg2:IsContains(g) then
            return false
        end
        -- Check for Pendulum Zone match
        if loc == LOCATION_PZONE and (g:GetSequenceBit() & seqbit) ~= 0 then
            return false
        end
    end

    return true
end


function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
