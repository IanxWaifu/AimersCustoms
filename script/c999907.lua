--Kegai - Karasu Tokei no Shisha
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    Aimer.KegaiAddSynchroMaterialEffect(c)
	--synchro summon
    Aimer.KegaiSynchroAddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Check materials
--[[	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)--]]
	--Banish and copy effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE|LOCATION_MZONE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsPhase(PHASE_END) end)
	e2:SetCost(Cost.AND(Cost.SelfBanish,Cost.HardOncePerChain(id)))
	e2:SetTarget(s.applytg)
	e2:SetOperation(s.applyop)
	c:RegisterEffect(e2)
	--Become Ritual
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.tycon)
	e3:SetOperation(s.tyop)
	c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}


-- Check Materials
--[[function s.valcheck(e,c)
    local g=c:GetMaterial()
    local races={}
    local uniqueRaceCount=0
    local totalCount=g:GetCount()
    for tc in aux.Next(g) do
        local race=tc:GetRace()
        if not races[race] then
            races[race]=true
            uniqueRaceCount=uniqueRaceCount+1
        end
    end
    -- Only true if ALL materials are different races
    if uniqueRaceCount==totalCount then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),0,1)
    end
end

--Draw
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSynchroSummoned() and e:GetHandler():GetFlagEffect(id)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end--]]


--Apply Ritual Effect
function s.applyfilter(c)
    if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
    return c:IsRitualSpell() and c:IsAbleToDeck() and c:CheckActivateEffect(true,true,false)~=nil
end

function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(s.applyfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.applyfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	local te=e:GetLabelObject()
	if te then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
	end
end




--Become Ritual
function s.tycon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsType(TYPE_RITUAL)
end

function s.tyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetValue(TYPE_MONSTER+TYPE_EFFECT+TYPE_RITUAL)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EVENT_BE_MATERIAL)
        e2:SetCountLimit(1,{id,3})
        e2:SetCondition(s.mtcon)
        e2:SetOperation(s.mtop)
        c:RegisterEffect(e2)
        if not c:IsType(TYPE_EFFECT) then
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_ADD_TYPE)
            e3:SetValue(TYPE_EFFECT)
            e3:SetReset(RESET_EVENT|RESETS_STANDARD)
            c:RegisterEffect(e3,true)
        end
    end
end

function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    local mt=rc and rc:GetMetatable()
    if r==REASON_RITUAL then return true end
    if mt and mt.ritual_material_required and mt.ritual_material_required>=1 then
        e:SetLabelObject(rc)
        return true
    end
    return false
end

function s.mtop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    local mt=rc and rc:GetMetatable()
    
    if r==REASON_RITUAL then
        for rc2 in eg:Iter() do
            if rc2:IsType(TYPE_RITUAL) then rc=rc2 break end
        end
        if not rc then return end
        local e1=Effect.CreateEffect(rc)
        e1:SetDescription(aux.Stringid(id,3))
        e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e1:SetCode(id)
        e1:SetProperty(--[[EFFECT_FLAG_DELAY+--]]EFFECT_FLAG_NO_TURN_RESET)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCountLimit(1,{id,4})
        e1:SetTarget(s.thtg)
        e1:SetOperation(s.thop)
        rc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_END)
		e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		    Duel.RaiseSingleEvent(rc,id,e,r,rp,ep,ev)
		    e:Reset()  -- remove this chain-end effect after it runs once
		end)
        Duel.RegisterEffect(e2,tp)
    else
        -- normal special summon triggers
        if not rc then return end
        local e1=Effect.CreateEffect(rc)
        e1:SetDescription(aux.Stringid(id,3))
        e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e1:SetCode(EVENT_SPSUMMON_SUCCESS)
        --[[e1:SetProperty(EFFECT_FLAG_DELAY)--]]
        e1:SetCountLimit(1,{id,4})
        e1:SetTarget(s.thtg)
        e1:SetOperation(s.thop)
        rc:RegisterEffect(e1,true)
    end
    
    if not rc:IsType(TYPE_EFFECT) then
        local e2=Effect.CreateEffect(rc)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_ADD_TYPE)
        e2:SetValue(TYPE_EFFECT)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        rc:RegisterEffect(e2,true)
    end
end


function s.thfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end




--[[function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--Destruction/Banish replacement
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	rc:RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
end

function s.repfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and (c:GetDestination()==LOCATION_REMOVED or c:IsReason(REASON_DESTROY)) and c:IsControler(tp)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and eg:IsExists(s.repfilter,1,nil,tp) and c:GetFlagEffect(id+1)>0 end
	if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		c:ResetFlagEffect(id+1)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	return true
	else return false end
end
function s.repval(e,c)
	return c:IsReason(REASON_EFFECT) and (c:GetDestination()==LOCATION_REMOVED or c:IsReason(REASON_DESTROY)) and c:GetControler()==e:GetHandlerPlayer()
end--]]