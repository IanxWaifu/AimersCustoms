--Scripted by IanxWaifu
--Zorga, Wraithlord of Invictus
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
local function CountAttributes(att)
    local count = 0
    while att > 0 do
        count = count + (att & 1)
        att = att >> 1
    end
    return count
end

local chosenAttribute = 0

function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	Fusion.AddProcMixRep(c,true,true,s.mfilter2,2,99,s.mfilter1)
	--Name becomes "Zorga" while on the field on in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetValue(999415)
	c:RegisterEffect(e1)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(aux.fuslimit)
	c:RegisterEffect(e2)
    -- Gain Attribute
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.attcon)
    e3:SetOperation(s.attrOperation)
    c:RegisterEffect(e3)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_MATERIAL_CHECK)
    e4:SetValue(s.valcheck)
    e4:SetLabelObject(e3)
    c:RegisterEffect(e4)
    --Special Targets
   	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_series={0x29f}
s.material={999415}
s.material_setcode={0x129f}
s.listed_names={id,CARD_ZORGA}

function s.mfilter1(c)
	return c:IsCode(999415)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) or c:IsRace(RACE_ZOMBIE,fc,sumtype,tp)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.attrOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local att = e:GetLabel()
    if att > 0 then
        local e5 = Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e5:SetRange(LOCATION_MZONE)
        e5:SetCode(EFFECT_ADD_ATTRIBUTE)
        e5:SetValue(att)
        e5:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e5)
    end
end
function s.valcheck(e, c)
    local att = 0
    local g = c:GetMaterial()
    for tc in aux.Next(g) do
        att = bit.bor(att, tc:GetAttribute())
    end
    e:GetLabelObject():SetLabel(att)
end

function s.spfilter(c,e,tp)
	return e:GetHandler():GetAttribute() & c:GetAttribute() ~= 0  and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

local ATTRIBUTES=ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND|ATTRIBUTE_DARK|ATTRIBUTE_LIGHT|ATTRIBUTE_DIVINE

function s.rescon(sg,e,tp,mg)
	return true,not sg:CheckDifferentPropertyBinary(function(c)return c:GetAttribute()&(ATTRIBUTES)end)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local attCount = 0
	local att = c:GetAttribute()
	while att > 0 do
		attCount = attCount + (att & 1)
		att = att >> 1
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1
	else ft=attCount end
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		return aux.SelectUnselectGroup(rg,e,tp,1,ft,s.rescon,0) and ft > 0 and c:IsReleasableByEffect()
	end
	local g=aux.SelectUnselectGroup(rg,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local ft = Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft <= 0 or not c:IsRelateToEffect(e) or not c:IsReleasableByEffect() then return end
	local g = Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg = g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg > 0 and (#sg > 1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then
		if #sg > ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg = sg:Select(tp,ft,ft,nil)
		end
		if Duel.Release(c,REASON_EFFECT)~=0 then 
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
