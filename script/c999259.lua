--Scripted by IanxWaifu
--Daemon Astaroth, Solomon’s Key
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	--xyz summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.xyzcon)
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(function(_,c) return c:IsSetCard(0x718) end)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Return adjacent to hand instead
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetCondition(s.repcon)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
	--Negate and Set
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DISABLE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCountLimit(1,id)
	e6:SetHintTiming(0,0x1c1)
	e6:SetCost(s.actcost)
	e6:SetTarget(s.acttg)
	e6:SetOperation(s.actop)
	c:RegisterEffect(e6,false,REGISTER_FLAG_DETACH_XMAT)
	--if leaves the field draw
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_NO_TURN_RESET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetCountLimit(1,{id,1})
	e7:SetCondition(s.drcon)
	e7:SetTarget(s.drtg)
	e7:SetOperation(s.drop)
	c:RegisterEffect(e7)
	--Place this card in the Pendulum Zone
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,{id,2})
	e8:SetCondition(s.pencon)
	e8:SetTarget(s.pentg)
	e8:SetOperation(s.penop)
	c:RegisterEffect(e8)
	--Shuffle Replace
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_SEND_REPLACE)
	e9:SetRange(LOCATION_MZONE)
	e9:SetTarget(s.shtg)
	e9:SetValue(s.repval)
	c:RegisterEffect(e9)
--[[	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_CHAIN_SOLVING)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCondition(s.deckcon)
	e10:SetOperation(s.deckop)
	c:RegisterEffect(e10)--]]
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		ge1:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		ge1:SetTarget(function (e,c) return e:GetLabelObject():GetLabelObject() end)
		ge1:SetLabelObject(e9)
		ge1:SetValue(LOCATION_DECK)
		Duel.RegisterEffect(ge1,0)
	end
end
s.minxyzct=2
s.maxxyzct=2
s.maintain_overlay=true
s.listed_series={0x718,0x719}
s.listed_names={id}

function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsMonster()
end

function s.xyzcon(e,c,og)
	if not c then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_REMOVED,0,2,nil)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
	local g=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,nil,1,tp,HINTMSG_XMATERIAL)
	if sg and sg:GetCount()>1 then
		og=sg:Clone()
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		if tc1:GetOverlayCount()~=0 then
			Duel.Overlay(tc2,tc1:GetOverlayGroup())
		end
		Duel.Overlay(c,Group.FromCards(tc1,tc2))
		c:SetMaterial(og)
		if Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,true,false,POS_FACEUP)~=0 then
			c:CompleteProcedure()
		end
	end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x718) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end


function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)==0 and e:GetHandler():GetFlagEffect(id+1)==0
end



function s.spcfilter(c,tp,mc)
    if c:GetControler()==1-tp or not (c:IsSetCard(0x718) or c:IsSetCard(0x719)) then return false end
    local zone=mc:GetColumnZone(LOCATION_ONFIELD)
    local seq=c:GetSequence()
    if c:GetFlagEffect(id)==0 and ((seq>0 and bit.extract(zone,seq-1)~=0) or (seq<4 and bit.extract(zone,seq+1)~=0)) or ((seq==0 or seq==4) and bit.extract(zone,seq)~=0) then
        return true
    end
    return false
end


function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mc=e:GetHandler()
    if not mc:IsFaceup() and not mc:IsLocation(LOCATION_PZONE) then return false end
    if chk==0 then return eg:IsExists(s.spcfilter,1,nil,tp,mc) end
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    	Duel.Hint(HINT_CARD,0,id)
        local g=eg:Filter(s.spcfilter,nil,tp,mc) 
        local ct=g:GetCount()
        if ct>1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
            g=g:Select(tp,1,ct,nil)
            for hc in g:Iter() do
                hc:CancelToGrave()
            end
        end
        local og=Group.CreateGroup()
        for tc in g:Iter() do
            og:AddCard(tc)
            local e1=Effect.CreateEffect(mc) 
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(LOCATION_HAND)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOHAND+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            mc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
            mc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET,0,1)
        end
        return true
    else return false end
end

function s.repval(e,c)
    return false
end


	--Return Spell/Trap activated
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local zone=e:GetHandler():GetColumnZone(LOCATION_ONFIELD)
    local seq=re:GetHandler():GetSequence()
    if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(0x719)
        and e:GetHandler():GetFlagEffect(id)==0 and e:GetHandler():GetFlagEffect(id+1)==0 then
        -- Check for left pendulum zone and its right adjacent column
        if seq > 0 and bit.extract(zone,seq-1)~=0 then
            return true
        end
        -- Check for right pendulum zone and its left adjacent column
        if seq < 4 and bit.extract(zone,seq+1)~=0 then
            return true
        end
    end
    return false
end

	--Activation legality
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
	--Return
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsOnField() then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_CARD,0,id)
		re:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
		e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET,0,1)
		rc:CancelToGrave()
		Duel.SendtoHand(rc,nil,REASON_EFFECT)
	end
end



--Negate and Set
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.onfieldcon(e,tp,eg,ep,ev,re,r,rp)
	local dg=e:GetLabelObject()
	return dg:IsFaceup() and dg:GetFlagEffect(id+2)>=1
end

function s.actfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and not c:IsLocation(LOCATION_PZONE)
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.actfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.NegateRelatedChain(tc,RESET_TURN_SET)~=0 and tc:IsSpellTrap() then
			tc:CancelToGrave()
			Duel.ChangePosition(tc,POS_FACEDOWN)
			tc:SetStatus(STATUS_ACTIVATE_DISABLED,false)
			tc:SetStatus(STATUS_SET_TURN,false)
			Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			Duel.BreakEffect()
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			tc:CancelToGrave()
			if tc:IsType(TYPE_SPELL+TYPE_TRAP) then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,4))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetCondition(s.onfieldcon)
				e1:SetLabelObject(c)
				e1:SetReset(RESET_EVENT|RESETS_CANNOT_ACT)
				e1:SetValue(1)
				tc:RegisterEffect(e1)
				c:RegisterFlagEffect(id+2,RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD-RESET_TURN_SET-RESET_LEAVE,0,1)
			end
			elseif Duel.NegateRelatedChain(tc,RESET_TURN_SET)~=0 and tc:IsMonster() then
				Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		end
	end
end

--Shuffle Detached Materials
function s.shfilter(c,tp,sc)
	return c:IsLocation(LOCATION_OVERLAY) and c:GetDestination()==LOCATION_GRAVE and c:IsAbleToDeck() and sc:IsContains(c)
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc=e:GetHandler():GetOverlayGroup()
	if chk==0 then return bit.band(r,REASON_EFFECT+REASON_COST+REASON_RELEASE+REASON_ADJUST)~=0 and eg:IsExists(s.shfilter,1,nil,tp,sc) end
	if e:GetHandler():IsFaceup() and e:GetHandler():IsLocation(LOCATION_MZONE) then
		local g=eg:Filter(s.shfilter,nil,tp,sc)
		local ct=g:GetCount()
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			g=g:Select(tp,1,ct,nil)
		end
		local og=Group.CreateGroup()
		for tc in aux.Next(g) do
			og:AddCard(tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_DECKSHF)
			e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			--[[Duel.RegisterFlagEffect(0,id+4,RESET_CHAIN,0,1)--]]
		end
		Duel.ShuffleDeck(tp) 
		if og:GetCount()>0 then
			e:SetLabelObject(og)
		end
		return true
	else 
		return false 
	end
end



--Place to Pend Zone when no Xyz
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end


--Draw when activated
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and rc:IsSetCard(0x719) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end


--Old Tests


	--Shuffle on Resolve
--[[function s.deckcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id+4)>0 then
		return true
	else return false end
end

	--Shuffle
function s.deckop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+4)==0 then return false end
	if Duel.ShuffleDeck(tp)~=0 then
		Duel.ResetFlagEffect(tp,id+4)
	end
end--]]

	--Column Tests
--[[function s.spcfilter(c,tp,mc)
    if c:GetControler()==1-tp then return false end
    local zone=mc:GetColumnZone(LOCATION_ONFIELD)<<1
    local seq=c:GetSequence()
    return zone and bit.extract(zone,seq)~=0 and c:GetFlagEffect(id)==0 
end--]]

--[[function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local left_zone=e:GetHandler():GetColumnZone(LOCATION_ONFIELD)<<1 -- get the Left Pendulum Zone
	local right_zone=e:GetHandler():GetColumnZone(LOCATION_ONFIELD)>>1 -- get the Right Pendulum Zone
	local seq=re:GetHandler():GetSequence()
	local is_left_adjacent = bit.extract(left_zone,seq)~=0 -- check if the activated card is in the Left Pendulum Zone's Right Adjacent Column
	local is_right_adjacent = bit.extract(right_zone,seq)~=0 -- check if the activated card is in the Right Pendulum Zone's Left Adjacent Column
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and re:GetHandler():IsSetCard(0x719)
		and e:GetHandler():GetFlagEffect(id)==0 and e:GetHandler():GetFlagEffect(id+1)==0
		and (is_left_adjacent or is_right_adjacent) -- return true if the activated card is in either Pendulum Zone's adjacent column
end--]]