--Scripted by IanxWaifu
--Hora, Necrotic Gatekeeper
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
    --Special Summon 
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.tgcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
    -- Gain Attribute
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.tgcon)
    e4:SetOperation(s.attrOperation)
    c:RegisterEffect(e4)
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_MATERIAL_CHECK)
    e6:SetValue(s.valcheck)
    e6:SetLabelObject(e4)
    c:RegisterEffect(e6)
    --Special summon necrotic ect;
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetCountLimit(1,{id,1})
    e7:SetRange(LOCATION_MZONE)
    e7:SetCondition(s.necroticcon)
    e7:SetTarget(s.necrotictg)
    e7:SetOperation(s.necroticop)
    c:RegisterEffect(e7)
    local leave = Effect.CreateEffect(c)
    leave:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    leave:SetCode(EVENT_LEAVE_FIELD)
    leave:SetOperation(s.leaveOperation)
    c:RegisterEffect(leave)
end

s.listed_series={0x29f}
s.material={999415}
s.material_setcode={0x129f}
s.listed_names={id,CARD_ZORGA}

function s.mfilter1(c)
	return c:IsCode(999415)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_FIEND,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_WIND,fc,sumtype,tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tgfilter(c,att)
    local sharedAttribute = att & c:GetAttribute() ~= 0
    return ((c:IsSetCard(0x29f) and c:IsLocation(LOCATION_EXTRA+LOCATION_DECK) and c:IsMonster()) or (c:IsLocation(LOCATION_MZONE) and sharedAttribute)) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local att=e:GetHandler():GetAttribute()
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_MZONE,LOCATION_MZONE,1,nil,att,sharedAttribute) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local att=e:GetHandler():GetAttribute()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_MZONE,LOCATION_MZONE,1,1,nil,att,sharedAttribute)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

function s.necroticcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local att = c:GetAttribute()
    local attCount = 0
    while att > 0 do
        if att & 0x1 ~= 0 then
            attCount = attCount + 1
        end
        att = att >> 1
    end
    return attCount > 1 and Duel.IsMainPhase()
end

function s.necroticfilter(c,e,tp,att,zorg)
    local sharedAttribute = att & c:GetAttribute() ~= 0
    return ((c:IsCode(999415) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_HAND)) or (((c:IsLevelBelow(4) or c:IsCode(999415)) and sharedAttribute) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_HAND) and c:IsControler(tp))))

        or (zorg and c:IsSetCard(0x29f) and  c:IsLocation(LOCATION_DECK)))

        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.necrotictg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local att=c:GetAttribute()
    local zorg=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,999415),tp,LOCATION_ONFIELD,0,1,nil)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.necroticfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,LOCATION_GRAVE,1,nil,e,tp,att,zorg) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK)
end
function s.necroticop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local att=c:GetAttribute()
    local zorg=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,999415),tp,LOCATION_ONFIELD,0,1,nil)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.necroticfilter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,LOCATION_GRAVE,1,1,nil,e,tp,att,zorg)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
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
        e5:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
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
