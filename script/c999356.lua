--Scripted by IanxWaifu
--Necroticrypt Confrontation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Shuffle itself and attach from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={0x29f,0x129f}

-- Check if a monster can be Special Summoned to the owner's field
function s.xyzcheck(c, e, tp)
    local p = c:GetOwner()
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, p)
end

-- Target the Xyz Monster that can summon all its materials
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local mg = Duel.GetMatchingGroup(Card.IsSetCard, tp, LOCATION_MZONE, 0, nil, 0x129f)
        for mc in aux.Next(mg) do
            local xyzmaterials = mc:GetOverlayGroup()
            local canSummonAll = xyzmaterials:IsExists(s.xyzcheck, 1, nil, e, tp)
            if canSummonAll then
            	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
                Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_MZONE, 0, 1, mc)
                return true
            end
        end
        return false
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_OVERLAY)
end

-- Special Summon Xyz Materials to the owner's field
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return false end
    local tc = Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end -- Not enough space to summon
    local matg = tc:GetOverlayGroup()
    if matg:IsExists(function(c) return not s.xyzcheck(c, e, tp) end, 1, nil, e, tp) then
        return false -- At least one material cannot be summoned
    end
    local tg = matg:FilterSelect(tp, s.xyzcheck, 1, 10, nil, e, tp)
    Duel.SpecialSummon(tg, 0, tp, tp, false, false, POS_FACEUP)
    return true
end



function s.tgfilter(c, e, tp)
    if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x129f)) then return false end
    local g = c:GetOverlayGroup()
    local mg = g:Filter(s.xyzcheck, nil, e, tp)
    local ct = #mg
    return g:IsExists(s.xyzcheck, 1, nil, e, tp) and ct > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) >= ct and mg:FilterCount(s.xyzcheck, nil, e, tp, c) == ct
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local g = Duel.GetMatchingGroup(s.tgfilter, tp, LOCATION_MZONE, 0, nil, e, tp)
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and g:GetCount() > 0
    end
    local tc = Duel.SelectTarget(tp, s.tgfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp):GetFirst()
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc, 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local fc = Duel.GetFirstTarget()
    local matg = fc:GetOverlayGroup()
    
    for p = 0, 1 do
        local lc = Duel.GetLocationCount(p, LOCATION_MZONE)
        local tg = matg:FilterSelect(tp, s.xyzcheck, lc, lc, nil, e, p)
        
        for sp in aux.Next(tg) do
            -- Check the original owner of the card
            local originalOwner = sp:GetOwner()
            
            -- Special Summon to the correct owner's field
            Duel.SpecialSummonStep(sp, 0, tp, originalOwner, false, false, POS_FACEUP)
        end
    end

    Duel.SpecialSummonComplete()
    if Duel.Remove(fc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		fc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(fc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end

	--Flag been raised
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
	--Return banished monster
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
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

