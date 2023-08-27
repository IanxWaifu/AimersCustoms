--Scripted by IanxWaifu
--Sargengelis, Necrotic Paragon
local s,id=GetID()

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
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- Gain Attribute
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.spcon)
    e4:SetOperation(s.attrOperation)
    c:RegisterEffect(e4)
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_MATERIAL_CHECK)
    e6:SetValue(s.valcheck)
    e6:SetLabelObject(e4)
    c:RegisterEffect(e6)
    --Change the effect of monster
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_CHAINING)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1,{id,1})
    e7:SetCondition(s.chcon)
    e7:SetTarget(s.chtg)
    e7:SetOperation(s.chop)
    c:RegisterEffect(e7)
    --Contained Effect
    function s.chop(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local g=Group.CreateGroup()
        Duel.ChangeTargetCard(ev,g)
        chosenAttribute=Duel.AnnounceAttribute(tp,1,c:GetAttribute())
        Duel.ChangeChainOperation(ev,s.repop(nil,c))
    end
    function s.repop(e,c)
        return function(e,tp,eg,ep,ev,re,r,rp)
            local g=Duel.GetDecktopGroup(e:GetHandlerPlayer(),1)
            if #g>0 then
                Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
            end
            c:ResetFlagEffect(id)
            c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,chosenAttribute)
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            e1:SetValue(chosenAttribute)
            c:RegisterEffect(e1)
        end
    end
end

s.listed_series={0x29f}
s.material={999415}
s.material_setcode={0x129f}

function s.mfilter1(c)
	return c:IsCode(999415)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_FAIRY,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x29f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
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


function s.chcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if not c:IsHasEffect(EFFECT_ADD_ATTRIBUTE) then
        return false
    end
    local attCount = CountAttributes(c:GetAttribute())
    -- Check if the activating monster shares an attribute with e:GetHandler()
    local sharedAttribute = c:GetAttribute() & rc:GetAttribute() ~= 0
    return re:IsMonsterEffect() and attCount > 1 and rc ~= c and sharedAttribute
end

function s.chtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 and Duel.IsPlayerCanDiscardDeck(tp,1) then
        return true 
    else return false
    end
end