--Scripted by IanxWaifu
--Hafgufa, Necrotic Tendril
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
	--Become 0
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.atkcon)
    e3:SetTarget(s.atktg)
    e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
    -- Gain Attribute
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.atkcon)
    e4:SetOperation(s.attrOperation)
    c:RegisterEffect(e4)
    --Force Attack
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetHintTiming(0,TIMING_END_PHASE+TIMING_BATTLE_START)
    e5:SetCountLimit(1,{id,1})
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.poscon)
    e5:SetTarget(s.postg)
    e5:SetOperation(s.posop)
    c:RegisterEffect(e5)
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_MATERIAL_CHECK)
    e6:SetValue(s.valcheck)
    e6:SetLabelObject(e4)
    c:RegisterEffect(e6)
    --act limit
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_CANNOT_ACTIVATE)
    e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e7:SetRange(LOCATION_MZONE)
    e7:SetTargetRange(0,1)
    e7:SetValue(s.limval)
    c:RegisterEffect(e7)
    --mandatory
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e8:SetCode(EVENT_SPSUMMON_SUCCESS)
    e8:SetCondition(s.regcon)
    e8:SetOperation(s.regop)
    c:RegisterEffect(e8)
    local e9=Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id,2))
    e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e9:SetCode(EVENT_PHASE+PHASE_END)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCountLimit(1)
    e9:SetCondition(s.sumcon)
    e9:SetOperation(s.sumop)
    c:RegisterEffect(e9)

end
s.listed_series={0x29f}
s.material={999415}
s.material_setcode={0x129f}
s.listed_names={id,CARD_ZORGA}

function s.mfilter1(c)
	return c:IsCode(999415)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_SEASERPENT,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_WATER,fc,sumtype,tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.atkfilter(c)
    return c:IsFaceup() and (c:GetAttack()>0 or c:GetDefense()>0)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,g,#g,1-tp,LOCATION_MZONE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    for tc in g:Iter() do
        --Make ATK 0
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        tc:RegisterEffect(e2)
    end
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

function s.limval(e,re,rp)
    local rc = re:GetHandler()
    local ec = e:GetHandler()
    local sharedAttribute = ec:GetAttribute() & rc:GetAttribute() ~= 0
    return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER) and sharedAttribute and (rc:GetAttack()==0 or rc:GetDefense()==0)
end


function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)~=0 and Duel.GetTurnPlayer()==tp
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
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

    -- Prompt the player to select an attribute to lose
    local att_to_lose = Duel.AnnounceAttribute(tp, 1, c:GetAttribute()-ATTRIBUTE_DIVINE)
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

function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return Duel.GetTurnPlayer()~=tp and ((ph==PHASE_DRAW) or (ph==PHASE_STANDBY) or (ph==PHASE_MAIN1) or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_MUST_ATTACK)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
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
