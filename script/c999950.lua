--Kyoshin - Saimyö no Mikoha
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    c:EnableReviveLimit()
    s.material_count=3
    s.min_material_count=3
    s.max_material_count=3
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_FUSION_MATERIAL)
    e0:SetCondition(Fusion.ConditionMix(true,true,s.fil1,s.ffilter,s.ffilter))
    e0:SetOperation(Fusion.OperationMix(true,true,s.fil1,s.ffilter,s.ffilter))
    c:RegisterEffect(e0)
    -- Immunity
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)
    --Shuffle and Negate
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.discost)
    e2:SetCondition(s.discon)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
    --Special Summon up to 2
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_BECOME_TARGET)
    e3:SetRange(LOCATION_MZONE|LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
    e3:SetCost(Cost.SelfToExtra)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}
s.ritual_material_required=2

function s.fil1(c,fc,sub1,sub2)
    return c:IsType(TYPE_FUSION,fc,sumtype,fc:GetControler()) and c:IsRace(RACE_FAIRY,fc,sumtype,fc:GetControler()) --[[or (sub1 and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961))--]]
end

function s.ffilter(c,fc,sub1,sub2,mg,sg,sumtype)
    return c:IsType(TYPE_RITUAL,fc,sumtype,fc:GetControler()) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,fc:GetControler()),fc,sumtype,fc:GetControler()))
end

function s.fusfilter(c,code,fc,sumtype)
    return c:IsSummonCode(fc,sumtype,fc:GetControler(),code) and not c:IsHasEffect(511002961)
end

-- Immunity
function s.immval(e,re)
    local c=e:GetHandler()
    if not (re:IsActivated() and c:IsFusionSummoned() and e:GetOwnerPlayer()==1-re:GetOwnerPlayer()) then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return not g or not g:IsContains(c)
end

function s.spfilter(c,e,tp)
    if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
    return (c:IsRitualMonster() or c:IsFusionMonster()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
    local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),#g,2)
    if ft<1 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
    local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Shuffle and Negate
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return Duel.IsChainDisablable(ev)
end
function s.costfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetCurrentChain()+1
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,ct,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,ct,ct,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end
