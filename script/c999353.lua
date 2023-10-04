--Scripted by IanxWaifu
--Necroticrypt Resurrection
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Send 1 monster to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
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




function s.spfilter(c)
	return c:IsMonster()
end
function s.xyzchk(c,tp,sg)
	return c:IsSetCard(0x129f) and c:IsType(TYPE_XYZ) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and c:IsRankBelow(5)
end
function s.monster(c)
	return c:IsMonster()
end
function s.xyzmonster(c,e,tp)
	return c:IsSetCard(0x129f) and not c:IsType(TYPE_XYZ)
end
function s.rescon(sg,e,tp,mg)
	local res=sg:FilterCount(s.monster,nil)>=1 or sg:FilterCount(s.xyzmonster,nil)<=1 
	return res,not res and Duel.IsExistingMatchingCard(s.xyzchk,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,sg,tp,sg)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	local sg=aux.SelectUnselectGroup(g2,e,tp,2,2,s.rescon,1,tp,HINTMSG_SELECT)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if #sg~=2 then return end
	local xyzg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.xyzchk),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,sg,tp,sg)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(xyz,0,tp,tp,false,false,POS_FACEUP)
		Duel.Overlay(xyz,sg)
		Duel.SpecialSummonComplete()
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


