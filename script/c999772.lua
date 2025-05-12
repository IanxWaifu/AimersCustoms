--Azhimaou - Sanguiva
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
   --Fusion summon
    local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_AZHIMAOU),matfilter=Card.IsAbleToRemove,extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratarget}
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(Fusion.SummonEffTG(params))
    e1:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e1)
    -- Special Summon itself
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

function s.fextra(e,tp,mg)
    if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
        return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
    end
    return nil
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
end

--Special itself
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED)) and c:GetReasonCard():IsSetCard(SET_AZHIMAOU)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end