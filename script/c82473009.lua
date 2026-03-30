--Scripted by Aimer
----Genosynx Trihnadel
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
--Genosynx Trihnadel
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	-- Trap Monster to linked zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
	--Keep track of monsters sent to your opponent's GY
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetLabelObject(e1)
	e1a:SetOperation(s.regop)
	c:RegisterEffect(e1a)
	-- BP/EP Quick Xyz Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.xyzcon)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	-- Destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.repop)
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
	-- To-hand replace
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetTarget(s.threptg)
	c:RegisterEffect(e4)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

-- Link material check
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_GENOSYNX,lc,sumtype,tp)
end

--regop for multiple summons
function s.efftgfilter(c,e)
	return c:IsOriginalType(TYPE_TRAP) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and (not e or c:IsCanBeEffectTarget(e))
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.efftgfilter,nil)
	if #tg>0 then
		for tc in tg:Iter() do
				tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
			end
			local g=e:GetLabelObject():GetLabelObject()
			if Duel.GetCurrentChain()==0 then g:Clear() end
			g:Merge(tg)
			g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
			e:GetLabelObject():SetLabelObject(g)
			if #g>0 and not Duel.HasFlagEffect(tp,id) then
				Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
				Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,tp,ep,ev)
		end
	end
end

-- Linked Trap Monster check
function s.linked_trapmon_filter(c,lc)
	if not c:IsOriginalType(TYPE_TRAP) or not c:IsLocation(LOCATION_MZONE) then return false end
	local seq=c:GetSequence()
	if seq<0 then return false end
	local z=lc:GetLinkedZone(c:GetControler())&0x7f
	return (z&(1<<seq))~=0
end

function s.setcon(e,tp,eg)
	return eg:IsExists(s.linked_trapmon_filter,1,nil,e:GetHandler())
end


function s.can_set_facedown(tc,e,tp)
	if tc:IsLocation(LOCATION_MZONE) then
		return tc:IsCanTurnSet()
	elseif tc:IsLocation(LOCATION_SZONE) then
		if tc:IsFacedown() then return false end
		return tc:IsSSetable(e,tp)
	end
	return false
end
function s.can_to_hand(tc)
	return tc:IsAbleToHand()
end

function s.paircheck_base(g,e,tp,mg)
	if #g~=2 then return false end
	local a=g:GetFirst()
	local b=g:GetNext()
	if not (mg and (mg:IsContains(a) or mg:IsContains(b))) then return false end
	return (s.can_set_facedown(a,e,tp) and s.can_to_hand(b))
		or (s.can_set_facedown(b,e,tp) and s.can_to_hand(a))
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mg=e:GetLabelObject():Filter(s.efftgfilter,nil,e):Match(s.linked_trapmon_filter,nil,c)
	if chkc then return mg:IsContains(chkc) and s.efftgfilter(chkc,e) end
	local fg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local function chkf(g,ex,tx)
		if #g~=2 then return false end
		local a=g:GetFirst()
		local b=g:GetNext()
		if not (mg:IsContains(a) or mg:IsContains(b)) then return false end
		return (s.can_set_facedown(a,ex,tx) and s.can_to_hand(b))
			or (s.can_set_facedown(b,ex,tx) and s.can_to_hand(a))
	end
	if chk==0 then
		if #mg==0 then return false end
		return aux.SelectUnselectGroup(fg,e,tp,2,2,chkf,0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=aux.SelectUnselectGroup(fg,e,tp,2,2,chkf,1,tp,HINTMSG_TARGET)
	if not g or #g~=2 then return end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end

function s.setop(e,tp)
	local tg=Duel.GetTargetCards(e)
	if #tg~=2 then return end
	local a,b=tg:GetFirst(),tg:GetNext()
	if not (a and b) then return end
	if not (a:IsRelateToEffect(e) and b:IsRelateToEffect(e)) then return end
	local canASet=s.can_set_facedown(a,e,tp)
	local canBSet=s.can_set_facedown(b,e,tp)
	local canAHand=s.can_to_hand(a)
	local canBHand=s.can_to_hand(b)
	local setc,handc
	if canASet and canBHand and not (canBSet and canAHand) then
		setc=a handc=b
	elseif canBSet and canAHand and not (canASet and canBHand) then
		setc=b handc=a
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=tg:FilterSelect(tp,function(tc) return s.can_set_facedown(tc,e,tp) end,1,1,nil)
		setc=sg:GetFirst()
		handc=(setc==a) and b or a
		if not (setc and handc) then return end
	end
	-- RESOLUTION RECHECK (covers forced branches too)
	if not (s.can_set_facedown(setc,e,tp) and s.can_to_hand(handc)) then return end
	if not (setc:IsRelateToEffect(e) and handc:IsRelateToEffect(e)) then return end
	-- show what is being Set
	Duel.HintSelection(Group.FromCards(setc))
	if setc:IsLocation(LOCATION_MZONE) then
		Duel.ChangePosition(setc,POS_FACEDOWN_DEFENSE)
	else
		Duel.SSet(tp,setc)
	end
	-- show what is being returned
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.HintSelection(Group.FromCards(handc))
	Duel.SendtoHand(handc,nil,REASON_EFFECT)
end



-- Quick Xyz Summon
function s.xyzcon()
	local ph=Duel.GetCurrentPhase()
	return (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_END
end

function s.genomatfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_MONSTER)
end

function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENOSYNX) and not c:IsType(TYPE_TOKEN)
end
function s.xyzfilter(c,mg)
	return c:IsSetCard(SET_GENOSYNX) and c:IsXyzSummonable(nil,mg)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,g)
	end
end

-- Replacement logic
function s.xyz_with_trapmat(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.overlayfilter,1,nil)
end

function s.overlayfilter(c)
	return c:IsOriginalType(TYPE_TRAP) and c:IsAbleToGrave()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup() and Duel.IsExistingMatchingCard(s.xyz_with_trapmat,tp,LOCATION_MZONE,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local xg=Duel.GetMatchingGroup(s.xyz_with_trapmat,tp,LOCATION_MZONE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local xc=xg:Select(tp,1,1,nil):GetFirst()
		local og=xc:GetOverlayGroup():Filter(s.overlayfilter,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=og:Select(tp,1,1,nil)
		e:SetLabelObject(tg:GetFirst())
		tg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.threptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetDestination()==LOCATION_HAND and not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup() and Duel.IsExistingMatchingCard(s.xyz_with_trapmat,tp,LOCATION_MZONE,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local xg=Duel.GetMatchingGroup(s.xyz_with_trapmat,tp,LOCATION_MZONE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local xc=xg:Select(tp,1,1,nil):GetFirst()
		local og=xc:GetOverlayGroup():Filter(s.overlayfilter,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=og:Select(tp,1,1,nil)
		e:SetLabelObject(tg:GetFirst())
		tg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.SendtoGrave(tc,REASON_EFFECT|REASON_REPLACE)
end
function s.repval(e,c)
	return true
end