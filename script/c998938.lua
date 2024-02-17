--Scripted by Aimer
--Iron Saga - The Ordinal Scales
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x12EC),7,2,nil,nil,7)
	-- Special Summon Xyz Material and negate effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Attach 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	--Xyz Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end

s.listed_series={0x12EC}
s.listed_names={id}

--Select an Xyz Material to Special Summon and negate the effect
function s.xyzcheck(c,e,tp)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():GetOverlayGroup():IsExists(s.xyzcheck,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local matg=c:GetOverlayGroup()
    local tg=matg:FilterSelect(tp,s.xyzcheck,1,1,nil,e,tp)
    local tc=tg:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) and tc:IsAbleToHand() then
		Duel.BreakEffect()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end

function s.attfilter(c)
    return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(tp) and s.attfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.attfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.attfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,c)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetTargetCards(e)
		if #g>0 then
			Duel.Overlay(c,g)
		end
	end
end

function s.xyzcon(e)
	local mat=e:GetHandler():GetOverlayGroup()
	return mat:IsExists(Card.IsCode,1,nil,998920) and mat:IsExists(Card.IsCode,1,nil,998921) and mat:IsExists(Card.IsCode,1,nil,998922) and mat:IsExists(Card.IsCode,1,nil,998923)
end


function s.xyzfilter(c,e,tp,pg)
	return e:GetHandler():IsCanBeXyzMaterial(c,tp) and c:IsCode(998935) and (#pg<=0 or pg:IsContains(e:GetHandler()))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_XYZ)
		return #pg<=1 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,pg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,pg)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(c)
		Duel.Overlay(sc,c)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local gg=Group.CreateGroup()
		gg:AddCard(sc)
		gg:KeepAlive()
		--Return to Extra during your next Standby
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		de:SetCode(EVENT_PHASE+PHASE_STANDBY)
		de:SetCountLimit(1)
		de:SetLabelObject(gg)
		de:SetCondition(s.rtcon)
		de:SetOperation(s.rtop)
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			de:SetLabel(Duel.GetTurnCount())
			de:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		else
			de:SetLabel(0)
			de:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		end
		Duel.RegisterEffect(de,tp)
	end
end
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rtfilter,1,nil) then
		g:DeleteGroup()
		e:Reset()
		return false
	end
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
function s.rtfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.rtfilter,nil)
	g:DeleteGroup()
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
end