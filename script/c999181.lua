-- Drakian Recollection
-- Scripted by IanxWaifu
local s,id=GetID()
function s.initial_effect(c)
     --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
     --Banish itself from GY to destroy 1 face-up card the opponent controls
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.descon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
s.fit_monster={999182} --should be removed in hardcode overhaul
s.listed_names={999182,999181}              
function s.filter1(c,e,tp)
    return (((c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR)) and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_DECK) and c:IsAbleToRemove()) or 
        (c:IsCode(999180) and c:IsLocation(LOCATION_ONFIELD) and c:IsAbleToRemove())) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,nil,e)
    and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_HAND,0,1,nil,e,tp) 
end

function s.filter2(c,e,tp,code)
    return (code~=999180 and ((c:IsDestructable(e) and c:IsRace(RACE_SPELLCASTER) and c:IsLocation(LOCATION_DECK) and c:IsType(TYPE_PENDULUM)) or (c:IsCode(999180) and c:IsLocation(LOCATION_ONFIELD) and c:IsDestructable(e)))) or
           (code==999180 and not c:IsCode(999180) and ((c:IsDestructable(e) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_DECK)) or ((c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR)) and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_DECK) and c:IsAbleToRemove())))
end

function s.filter3(c,e,tp)
local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
    return #pg<=0 and c:IsRitualMonster() and c:IsCode(999182) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_RITUAL)
    if #pg>0 then return end
    local rg1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil,e,tp)
    local code=rg1:GetFirst():GetCode()
    local rg2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil,e,tp,code)
    local race=rg1:GetFirst()
    local race2=rg2:GetFirst()
    if ((race:IsRace(RACE_FIEND) or race:IsRace(RACE_WARRIOR)) or ((race:IsCode(999180) and not race2:IsCode(999180)) or (race2:IsCode(999180) and not race:IsCode(999180)))) and not (race:IsCode(999180) and (race2:IsRace(RACE_WARRIOR) or race2:IsRace(RACE_FIEND))) then
        Duel.Remove(rg1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    else
        Duel.Destroy(rg1,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    end
        if ((race2:IsRace(RACE_FIEND) or race2:IsRace(RACE_WARRIOR)) or not (race2:IsCode(999180) and not race:IsCode(999180))) and not race2:IsRace(RACE_SPELLCASTER) then
        Duel.Remove(rg2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    else
        Duel.Destroy(rg2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    end
    local tg=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=tg:GetFirst()
    if tc then
        tc:SetMaterial(rg1+rg2)  
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
        tc:CompleteProcedure()
    end
end















--BFG Destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and aux.exccon(e)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end