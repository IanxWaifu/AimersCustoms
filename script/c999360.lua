--Scripted by IanxWaifu
--Necroticrypt - Liasboar the Devourer
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),6,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzcheck)
	c:EnableReviveLimit()
	--Gains ATK/DEF equal to the total ATK/DEF of the "Zoodiac" monsters attached
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.statcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
	--attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.attachtg)
	e3:SetOperation(s.attachop)
	c:RegisterEffect(e3)
	--negate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.negcon)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	--attach ED
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1,id)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.xyztg)
	e5:SetOperation(s.xyzop)
	c:RegisterEffect(e5,false,REGISTER_FLAG_DETACH_XMAT)
end

s.listed_series={0x129f,0x29f}
s.listed_names={id}

function s.oppfilter(c,tp)
    return c:GetOwner()~=tp
end
function s.statcon(e,tp,eg,ep,ev,re,r,rp)
    local mg=e:GetHandler():GetOverlayGroup()
    return mg:IsExists(s.oppfilter,1,nil,e:GetHandlerPlayer())
end
function s.atkfilter(c,tp)
	return c:GetAttack()>=0 and c:GetOwner()~=tp
end
function s.deffilter(c,tp)
	return c:GetDefense()>=0 and c:GetOwner()~=tp
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer() 
	local g=e:GetHandler():GetOverlayGroup():Filter(s.atkfilter,nil,tp)
	return g:GetSum(Card.GetAttack)
end
function s.defval(e,c)
	local tp=e:GetHandlerPlayer() 
	local g=e:GetHandler():GetOverlayGroup():Filter(s.deffilter,nil,tp)
	return g:GetSum(Card.GetDefense)
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRankBelow(5) and c:GetOverlayCount()==0 and c:IsSetCard(0x129f) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) 
end
function s.xyzcheck(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end


function s.attachfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.attachfilter(chkc) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end


function s.xyzfilter(c)
	return c:IsMonster()
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,nil) end
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	if not e:GetHandler():IsRelateToEffect(e) then return end
		if #g>0 then
			local mg=g:Select(tp,1,1,nil)
			local oc=e:GetHandler():GetOverlayTarget()
			if Duel.Overlay(e:GetHandler(),mg,true)~=0 then
			e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_EFFECT)
		end
	end
end



function s.checkfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x129f) and c:IsFaceup()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local mg=e:GetHandler():GetOverlayGroup()
	return mg:IsExists(s.oppfilter,1,nil,e:GetHandlerPlayer()) and rp~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev) and Duel.GetFlagEffect(tp,id)==0
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local g=Duel.GetMatchingGroup(s.checkfilter,tp,LOCATION_MZONE,0,nil)
	local mg=e:GetHandler():GetOverlayGroup()
	if Duel.GetFlagEffect(tp,id)>0 or not mg:IsExists(s.oppfilter,1,nil,e:GetHandlerPlayer()) then return end
	if #g<=0 then return end
		if rc:IsNegatableSpellTrap() and Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
			Duel.Hint(HINT_CARD,0,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			local tg=g:Select(tp,1,1,nil)
			if #tg>0 then
			rc:CancelToGrave()
			Duel.Overlay(tg:GetFirst(),rc)
		end
	end
end
