--Dragonic Icyene Ritual
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_DRAGOCYENE),extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,stage2=s.stage2,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck,specificmatfilter=s.specificfilter,extratg=s.extratg})
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e2:SetTarget(s.rttg)
    e2:SetOperation(s.rtop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_DRAGOCYENE}

function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
     return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
end

function s.matfilter(c,e,tp)
    return s.matfilter1(c)
end
function s.matfilter1(c)
    return c:IsAbleToGrave() and c:IsMonster() and c:IsSetCard(SET_DRAGOCYENE) and c:IsLocation(LOCATION_EXTRA+LOCATION_DECK)
end

function s.specificfilter(c,rc,mg,tp)
    return rc:GetLevel()<=mg:GetFirst():GetLevel() and rc:GetAttribute()~=mg:GetFirst():GetAttribute()
end

function s.ritcheck(e,tp,g,sc)
    return #g==1
end

function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,4))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.ctcon)
    e1:SetOperation(s.ctop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1,true)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    e2:SetCondition(s.evcon)
    e2:SetValue(s.evalue)
    tc:RegisterEffect(e2)
    --indes
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.indcon)
    e3:SetValue(s.indval)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e3)
end



--tribute to summon a ritual monster
function s.filter1(c,e,tp)
    local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
    return #pg<=0 and c:IsRitualMonster() and c:IsSetCard(SET_DRAGOCYENE) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true)
end

function s.checkc(c,tp)
    local ice=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,COUNTER_ICE)
    local blaze=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,COUNTER_BLAZE)
    local total=ice+blaze
    return c:GetLevel()<=total or Aimer.FrostrineCheckEnvironment(tp)
end

function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(function(c) return s.filter1(c,e,tp) and s.checkc(c,tp) end,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.rtop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_RITUAL)
    if #pg>0 then return end
    local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(c) return s.filter1(c,e,tp) and s.checkc(c,tp) end),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
    local tc=tg:GetFirst()
    if tc then
        tc:SetMaterial(nil)
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
        tc:CompleteProcedure()
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,4))
        e1:SetCategory(CATEGORY_COUNTER)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCondition(s.ctcon)
        e1:SetOperation(s.ctop)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,2))
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetRange(LOCATION_MZONE)
        e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        e2:SetCondition(s.evcon)
        e2:SetValue(s.evalue)
        tc:RegisterEffect(e2)
        --indes
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(id,3))
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCondition(s.indcon)
        e3:SetValue(s.indval)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
        local lv=tc:GetLevel()
        local ice=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,COUNTER_ICE)
        local blaze=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,COUNTER_BLAZE)
        local removed=0
        local check=0
        if ice+blaze>=lv and Aimer.FrostrineCheckEnvironment(tp) then
            if Duel.SelectYesNo(tp,aux.Stringid(999721,1)) then
                Duel.RegisterFlagEffect(tp,999721,RESET_PHASE+PHASE_END,0,1)
                Duel.Hint(HINT_CARD,0,999721)
                check=check+1
            end
        elseif ice+blaze<lv and Aimer.FrostrineCheckEnvironment(tp) then
            Duel.RegisterFlagEffect(tp,999721,RESET_PHASE+PHASE_END,0,1)
            Duel.Hint(HINT_CARD,0,999721)
            check=check+1
        end
        if check==0 then
            while removed<lv do
                local op
                if ice>0 and blaze>0 then
                    op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6)) -- 5 for Ice, 6 for Blaze
                elseif ice>0 then
                    op=0
                elseif blaze>0 then
                    op=1
                else
                    break
                end
                if (op==0 and ice>0) or (op==1 and blaze>0) then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
                    Duel.RemoveCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,(op==0 and COUNTER_ICE or COUNTER_BLAZE),1,REASON_EFFECT)
                    if op==0 then
                        ice=ice-1
                    else
                        blaze=blaze-1
                    end
                    removed=removed+1
                else
                    break
                end
            end
        end
    end
end


function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetFlagEffect(id)<=0
end
--Place Counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetFlagEffect(id)>0 then return end
    c:AddCounter(COUNTER_ICE,1)
    c:AddCounter(COUNTER_BLAZE,1)
    c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end

function s.indcon(e)
    return e:GetHandler():GetCounter(COUNTER_ICE)>0
end
function s.evcon(e)
    return e:GetHandler():GetCounter(COUNTER_BLAZE)>0
end

function s.indval(e,re,tp)
    return tp~=e:GetHandlerPlayer()
end
function s.evalue(e,re,rp)
    return rp~=e:GetHandlerPlayer()
end