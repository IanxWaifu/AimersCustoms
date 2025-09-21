--Scripted by Aimer
--Vylon Compression
local s,id=GetID()
function s.initial_effect(c)
    local e1=aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_VYLON))
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCountLimit(1,{id,1})
    e6:SetTarget(s.leveltg)
    e6:SetOperation(s.levelop)
    c:RegisterEffect(e6)
end

function s.atkval(e,c)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,c:GetControler(),LOCATION_SZONE,0,nil,SET_VYLON)
    return #g*200
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_VYLON) and not c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(6) 
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.Equip(tp,c,tc) then
        --Add Equip limit
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
        e1:SetValue(function(e,c) return e:GetOwner()==c end)
        c:RegisterEffect(e1)
    end
end

function s.leveltg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:GetEquipTarget()~=nil end
end

function s.levelop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    if not ec or not ec:IsFaceup() then return end
    local exclv=ec:GetLevel()
    local levels={}
    for i=1,4 do
        if i~=exclv then
            table.insert(levels,i)
        end
    end
    if #levels==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
    local lv=Duel.AnnounceNumber(tp,table.unpack(levels))
    if lv>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e1)
        if c:IsRelateToEffect(e) then
            Duel.BreakEffect()
            Duel.Destroy(c,REASON_EFFECT)
        end
    end
end
