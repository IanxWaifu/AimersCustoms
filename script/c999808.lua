--Novalxon Gyrant
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}


function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_NOVALXON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and (c:IsLocation(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.seqfilter(c)
    local tp=c:GetControler()
    return c:IsFaceup() and c:GetSequence()<7 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=not Duel.HasFlagEffect(tp,id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.IsExistingMatchingCard(s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    local b3=not Duel.HasFlagEffect(tp,id) and not Duel.HasFlagEffect(tp,id+1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    if chk==0 then return b1 or b2 or b3 end
    local op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,0)},
            {b2,aux.Stringid(id,1)},
            {b3,aux.Stringid(id,2)})
    e:SetLabel(op)
    if op==1 then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE)
    elseif op==2 then
        Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
    elseif op==3 then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE)
        Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
    end
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    elseif op==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local tc=Duel.SelectMatchingCard(tp,s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
        local p1,p2,i
        if tc:IsControler(tp) then
            i=0
            p1=LOCATION_MZONE
            p2=0
        else
            i=16
            p2=LOCATION_MZONE
            p1=0
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
    elseif op==3 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
        local sptg=g:GetFirst()
        if sptg and Duel.SpecialSummon(sptg,0,tp,tp,false,false,POS_FACEUP)~=0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
            local tc=Duel.SelectMatchingCard(tp,s.seqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
            local p1,p2,i
            if tc:IsControler(tp) then
                i=0
                p1=LOCATION_MZONE
                p2=0
            else
                i=16
                p2=LOCATION_MZONE
                p1=0
            end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
            Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
        end
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ASTRAL_SHIFT)
    e1:SetCondition(s.setcon)
    e1:SetOperation(s.setop)
    e1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(e1,tp)
end

--Search Condition on Astral Shift
function s.astfilter(c,tp)
    return c:IsControler(tp)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.astfilter,1,nil,tp) and not Duel.HasFlagEffect(tp,id+2)
end
function s.setfilter(c)
    return c:IsSetCard(SET_NOVALXON) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or Duel.HasFlagEffect(tp,id+2) then return end 
    if Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_CARD,0,id)  
        Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g)
        end
    end
end