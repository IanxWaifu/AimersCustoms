--Scripted by IanxWaifu
--Ersatz, Necrotic Wings

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
	Fusion.AddProcMixRep(c,true,true,s.mfilter2,1,99,s.mfilter1)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
    -- Gain Attribute
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.drcon)
    e4:SetOperation(s.attrOperation)
    c:RegisterEffect(e4)
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_MATERIAL_CHECK)
    e6:SetValue(s.valcheck)
    e6:SetLabelObject(e4)
    c:RegisterEffect(e6)
    -- Negate and Destroy effect
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 1))
    e7:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_CHAINING)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1,{id,1})
    e7:SetCondition(s.negateCondition)
    e7:SetTarget(s.negateTarget)
    e7:SetOperation(s.negateOperation)
    c:RegisterEffect(e7)
end
s.listed_series={0x29f}
s.material={999415}
s.material_setcode={0x129f}
s.listed_names={id,CARD_ZORGA}

function s.mfilter1(c)
	return c:IsCode(999415)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
end
function s.drfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_FUSION)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	Duel.Draw(p,ct,REASON_EFFECT)
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

function s.negateCondition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsHasEffect(EFFECT_ADD_ATTRIBUTE) then return false end
    local att = c:GetAttribute()
    local attCount = 0
    while att > 0 do
        if att & 0x1 ~= 0 then
            attCount = attCount + 1
        end
        att = att >> 1
    end
    return rp ~= tp and not c:IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev) and attCount > 1
end

function s.negateTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
end

function s.negateOperation(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.NegateActivation(ev)
    if eg:GetFirst():IsRelateToEffect(e) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
    local quickatt = c:GetAttribute()
    -- Set the Divine attribute bit to 0
    quickatt = quickatt & ~ATTRIBUTE_DIVINE
    -- Prompt the player to select an attribute to lose
    local att_to_lose = Duel.AnnounceAttribute(tp, 1, quickatt)
    c:ResetFlagEffect(id) -- Reset the flag before setting a new one
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1, att_to_lose)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(att_to_lose)
	c:RegisterEffect(e1)
end