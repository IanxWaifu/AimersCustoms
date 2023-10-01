--Scripted by IanxWaifu
--Necroticrypt Naganthis
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
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

s.listed_names={id}
s.listed_series={0x29f,0x129f}

function s.check(ev, re)
    return function(category, checkloc)
        local turnPlayer = Duel.GetTurnPlayer()  -- Get the current turn player

        if not ep == 1 - turnPlayer then
            return false  -- Opponent's activation
        end

        if not checkloc and re and re:IsHasCategory(category) then
            return true
        end

        local ex1, g1, gc1, dp1, dv1 = Duel.GetOperationInfo(ev, category)
        local ex2, g2, gc2, dp2, dv2 = Duel.GetPossibleOperationInfo(ev, category)

        if not (ex1 or ex2) then
            return false
        end

        local g = Group.CreateGroup()
        if g1 then
            g:Merge(g1)
        end
        if g2 then
            g:Merge(g2)
        end

        return (((dv1 or 0) | (dv2 or 0)) & LOCATION_GRAVE) ~= 0 or (#g > 0 and g:IsExists(Card.IsLocation, 1, nil, LOCATION_GRAVE))
    end
end


function s.discon(e, tp, eg, ep, ev, re, r, rp)
    if not re or re:GetHandler():IsDisabled() or not Duel.IsChainDisablable(ev) then
        return false
    end

    local checkfunc = s.check(ev, re)

    return checkfunc(CATEGORY_TOHAND, true) or checkfunc(CATEGORY_SPECIAL_SUMMON, true) or checkfunc(CATEGORY_REMOVE, true)
end

function s.onfield(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x129f) and c:IsMonster() and c:IsType(TYPE_XYZ)
end
function s.distg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.onfield, tp, LOCATION_MZONE, 0, nil, tp)
    if chk == 0 then
        return #g>0 and not (not re or re:GetHandler():IsStatus(STATUS_DISABLED))
    end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.disop(e, tp, eg, ep, ev, re, r, rp)
    local rc=re:GetHandler()
    local g = Duel.GetMatchingGroup(s.onfield, tp, LOCATION_MZONE, 0, nil, tp)
    if Duel.NegateEffect(ev) and #g>0 and rc:IsRelateToEffect(re) then
        rc:CancelToGrave()
        local mg=g:Select(tp,1,1,nil)
        local oc=mg:GetFirst():GetOverlayTarget()
        Duel.Overlay(mg:GetFirst(),rc)
    end
    if rc:IsOriginalType(TYPE_MONSTER) then return end
    if Duel.IsPlayerCanDraw(tp,1) and rc:IsLocation(LOCATION_OVERLAY) then
        Duel.BreakEffect()
        Duel.SendtoGrave(rc,REASON_EFFECT)
        Duel.RaiseSingleEvent(rc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
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
