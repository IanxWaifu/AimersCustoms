--Scripted by Aimer
--Vylon Matrix
local s,id=GetID()
function s.initial_effect(c)
    --Activate as Continuous Trap
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    --Only control 1 copy
    c:SetUniqueOnField(1,0,id)
    --Equip 1 "Vylon" monster or Equip Spell to 1 "Vylon" monster you control
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)
    --Banish 1 face-up "Vylon" monster you control until the End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
    --Grant effect to Sigma and Delta
    local ge=Effect.CreateEffect(c)
    ge:SetDescription(aux.Stringid(id,2))
    ge:SetCategory(CATEGORY_DISABLE)
    ge:SetType(EFFECT_TYPE_IGNITION)
    ge:SetRange(LOCATION_MZONE)
    ge:SetCountLimit(1,{id,2})
    ge:SetProperty(EFFECT_FLAG_CARD_TARGET)
    ge:SetCost(s.negcost)
    ge:SetCost(s.negcon)
    ge:SetTarget(s.negtg)
    ge:SetOperation(s.negop)
    local ge_grant=Effect.CreateEffect(c)
    ge_grant:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    ge_grant:SetRange(LOCATION_SZONE)
    ge_grant:SetTargetRange(LOCATION_MZONE,0)
    ge_grant:SetTarget(s.eftg)
    ge_grant:SetLabelObject(ge)
    c:RegisterEffect(ge_grant)
end

CARD_VYLON_SIGMA=48370501
CARD_VYLON_DELTA=45215453
--E1: Equip operation (select at resolution)
function s.vylonequip(c)
	return c:IsSetCard(SET_VYLON) and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_EQUIP))
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.vylonequip),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
    if #g1==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g2=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_VYLON),tp,LOCATION_MZONE,0,1,1,nil)
    if #g2==0 then return end
    local tc=g1:GetFirst()
    local trc=g2:GetFirst()
    if Duel.Equip(tp,tc,trc,true) then
	    -- Equip limit on the EQUIP CARD (tc)
	    local e1=Effect.CreateEffect(tc)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_EQUIP_LIMIT)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	    e1:SetValue(function(e,c) return c==trc end)
	    tc:RegisterEffect(e1)
	end
end

--E2: Banish operation (select at resolution)
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsAbleToRemove() end,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
        local fid=e:GetHandler():GetFieldID()
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabel(fid)
        e1:SetLabelObject(tc)
        e1:SetCondition(s.retcon)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return tc:GetFlagEffectLabel(id)==e:GetLabel()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ReturnToField(e:GetLabelObject())
end

--Grant effect to Sigma and Delta
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFlagEffect(tp,c:GetCode())==0 end
	Duel.RegisterFlagEffect(tp,c:GetCode(),RESET_PHASE|PHASE_END,0,1)
end
function s.vylonfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:IsEquipCard() and c:IsSetCard(SET_VYLON)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetEquipGroup():IsExists(s.vylonfilter,1,nil,tp) 
end
function s.eftg(e,c)
    return c:IsFaceup() and (c:IsCode(CARD_VYLON_SIGMA) or c:IsCode(CARD_VYLON_DELTA))
end
function s.negfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsDisabled()
end


-- filter to find the opposite monster
function s.otherfilter(tc,c)
    if not tc:IsFaceup() or not tc:IsAbleToRemove() then return false end
    if c:IsCode(CARD_VYLON_SIGMA) then
        return tc:IsCode(CARD_VYLON_DELTA)
    elseif c:IsCode(CARD_VYLON_DELTA) then
        return tc:IsCode(CARD_VYLON_SIGMA)
    end
    return false
end

-- target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.negfilter(chkc) end
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToRemove()
            and Duel.IsExistingMatchingCard(function(tc) return s.otherfilter(tc,c) end,tp,LOCATION_MZONE,0,1,nil,c)
            and Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    local g2=Duel.GetMatchingGroup(function(tc) return s.otherfilter(tc,c) end,tp,LOCATION_MZONE,0,1,nil,c)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

-- operation: banish both, negate target, return at EP
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    -- find opposite-name monster
    local g=Duel.GetMatchingGroup(function(tc) return s.otherfilter(tc,c) end,tp,LOCATION_MZONE,0,nil,c)
    if #g<=0 or not c:IsAbleToRemove() then return end
    local tg=g:Select(tp,1,1,nil):GetFirst()
    if tg then
        Duel.HintSelection(tg)
        -- banish both monsters temporarily
        local banish_group=Group.FromCards(c,tg)
        if Duel.Remove(banish_group,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=2 then return end
        -- keep the group alive
        banish_group:KeepAlive()
        -- create the End Phase return effect
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetLabelObject(banish_group)
        e1:SetCountLimit(1)
        e1:SetOperation(s.retop2)
        Duel.RegisterEffect(e1,tp)
        -- negate target Spell/Trap until EP
        if tc and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetCode(EFFECT_DISABLE)
            e2:SetReset(RESETS_STANDARD_PHASE_END)
            tc:RegisterEffect(e2)
            local e3=e2:Clone()
            e3:SetCode(EFFECT_DISABLE_EFFECT)
            e3:SetValue(RESET_TURN_SET)
            tc:RegisterEffect(e3)
            if tc:IsType(TYPE_TRAPMONSTER) then
                local e4=e2:Clone()
                e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                tc:RegisterEffect(e4)
            end
        end
    end
end

-- return banished monsters at End Phase
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g then return end
    for tc in aux.Next(g) do
        Duel.ReturnToField(tc)
    end
    g:DeleteGroup()
end




--[[













function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.negfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
   	if tc and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e3)
		end
		Duel.Destroy(c,REASON_EFFECT)
	end
end
--]]