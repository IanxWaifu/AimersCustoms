--Scripted by IanxWaifu
--Necroticrypt Wailstrom
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Destroy or Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.discost)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Shuffle itself and attach from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end


function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and rp~=tp and loc==LOCATION_MZONE
		and (Duel.IsChainNegatable(ev) or rc:IsDestructable())
end

function s.cfilter1(c,tp)
	if not c:IsFaceup() or not (c:IsType(TYPE_XYZ) and c:IsSetCard(0x129f)) then return false end
	local g=c:GetOverlayGroup()
	if #g==0 then return false end
	local count=#g
	return true
end
function s.cfilter2(c,tp)
	if not c:IsFaceup() or not (c:IsType(TYPE_XYZ) and c:IsSetCard(0x129f)) then return false end
	local g=c:GetOverlayGroup()
	if #g<2 then return false end
	local count=#g
	return true
end


function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=re:GetHandler()
	local b1=check:IsDestructable()
	local b2=Duel.IsChainNegatable(ev)
	local xyz1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
	local xyz2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	local opt=0
	if chk==0 then return (xyz1 and b1) or (xyz2 and b2) end
	if ((xyz1 and b1) and (xyz2 and b2)) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		e:SetLabel(opt)
	elseif (xyz1 and b1) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0))
		e:SetLabel(opt)
	elseif (xyz2 and b2) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))+1
		e:SetLabel(opt)
	else return end		
		if opt==0 then
		local sg=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST,sg)
		elseif opt>0 then
		local tc=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		local og=tc:GetOverlayGroup()
		Duel.SendtoGrave(og,REASON_COST)
		Duel.RaiseSingleEvent(tc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end


function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=re:GetHandler()
	local b1=check:IsDestructable()
	local b2=Duel.IsChainNegatable(ev)
	if chk==0 then return b1 or b2 end
	local op=e:GetLabel()
	if op==0 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,check,1,1-tp,check:GetLocation())
	elseif op>0 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE+CATEGORY_DESTROY,check,1,1-tp,check:GetLocation())
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local check=re:GetHandler()
	local b1=check:IsDestructable()
	local b2=Duel.IsChainNegatable(ev)
	if b1 and opt==0 then
		Duel.Destroy(check,REASON_EFFECT)
	end
	if b2 and opt>0 then
		Duel.NegateEffect(ev)
	end
end


function s.checkf(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x29f) and c:IsMonster()
end
function s.checkf2(c, tp)
    return c:IsFaceup() and not c:IsSetCard(0x29f) and c:IsMonster()
end
function s.xyzfilter(c, e, tp)
    local g1 = Duel.GetMatchingGroup(s.checkf, tp, LOCATION_REMOVED, 0, nil, tp)
    local g2 = Duel.GetMatchingGroup(s.checkf2, tp, LOCATION_REMOVED, LOCATION_REMOVED, nil, tp)
    local g3 = Duel.GetMatchingGroup(s.checkf, tp, 0, LOCATION_REMOVED, nil, tp)
    return ((((#g1==1 and #g2>=1) and not c:IsSetCard(0x29f) and c:IsMonster()) or (#g1 >=2 and c:IsMonster())) or ((#g3>=1 and #g1==1 and #g2>=1) and c:IsMonster() and c:IsControler(1-tp)))
    and not c:IsImmuneToEffect(e) and c:IsCanBeEffectTarget(e) and c ~= e:GetHandler() and c:IsFaceup()
end

function s.xyzfilter2(c, e, tp)
    return c:IsFaceup() and c:IsSetCard(0x29f) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.xyzfilter, tp, LOCATION_REMOVED, LOCATION_REMOVED, 1, nil, e, tp)
end

function s.faceupfilter(c,tp)
	return c:IsSetCard(0x129f) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.xyztg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.xyzfilter(chkc, e, tp) end

    local g = Duel.GetMatchingGroup(s.xyzfilter2, tp, LOCATION_REMOVED, LOCATION_REMOVED, nil, e, tp)
    if chk == 0 then
        return #g > 0 and Duel.IsExistingTarget(s.xyzfilter, tp, LOCATION_REMOVED, LOCATION_REMOVED, 1, nil, e, tp) and e:GetHandler():IsAbleToDeck()
        and Duel.IsExistingMatchingCard(s.faceupfilter,tp,LOCATION_MZONE,0,1,nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local selectedTargets = Duel.SelectTarget(tp, s.xyzfilter, tp, LOCATION_REMOVED, LOCATION_REMOVED, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
end

function s.xyzop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.faceupfilter,tp,LOCATION_MZONE,0,nil,tp)
	if #dg<=0 then return end
    local excludeGroup = Group.FromCards(tc, c)
    local g = Duel.GetMatchingGroup(s.xyzfilter2, tp, LOCATION_REMOVED, 0, excludeGroup, e, tp)
    if #g > 0 then
        local tg = g:Select(tp, 1, 2, nil)
        tg:AddCard(c)
        if Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
            local mg=dg:Select(tp,1,1,nil)
			local oc=mg:GetFirst():GetOverlayTarget()
			Duel.Overlay(mg:GetFirst(),tc)
	    end
	end
end
