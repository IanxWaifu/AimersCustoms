--Kyoshin - Unmei Man’kagami
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    local fparams={handler=c,filter=aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),extrafil=s.fextra,extratg=s.fusextratg}
    local rparams={handler=c,lvtype=RITPROC_GREATER,filter=s.rspfilter,extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_GRAVE|LOCATION_REMOVED,forcedselection=s.ritcheck}
    -- Correctly unpacked Fusion helper functions
    local fustg,fusop=Fusion.SummonEffTG(table.unpack(fparams)),Fusion.SummonEffOP(table.unpack(fparams))
    local rittg,ritop=Ritual.Target(rparams),Ritual.Operation(rparams) 
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
    e1:SetCost(s.effcost(fustg,rittg))
    e1:SetTarget(s.efftg(fustg,fusop,rittg,ritop))
    e1:SetOperation(s.effop(fustg,fusop,rittg,ritop))
    c:RegisterEffect(e1)
end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}

--Fusion Summon
function s.fextra(e,tp,mg)
    local eg=Group.CreateGroup()
    if Duel.IsPlayerAffectedByEffect(tp,999960) then
        local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
        if #sg>0 then eg:Merge(sg) end
    end
    if #eg>0 then return eg end
    return nil
end

function s.fusextratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_STZONE)
end 

function s.exfilter(c)
    return (c:IsMonster() or c:IsOriginalType(TYPE_MONSTER)) and c:IsSetCard(SET_KYOSHIN) and c:IsAbleToGrave() and c:HasLevel()
end
function s.monoppthfilter(c,e,tp)
	return ((c:IsSetCard(SET_KYOSHIN) and (c:IsType(TYPE_FUSION+TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER)) and c:IsControler(tp) and c:IsFaceup()) or c:IsControler(1-tp))
		and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end

--Ritual Summon
function s.rspfilter(c)
    local loc=c:GetLocation()
    return c:IsSetCard(SET_KYOSHIN)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
    return g
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.matfilter(c)
    return c:IsOriginalType(TYPE_MONSTER) and c:HasLevel()
end
function s.ritcheck(e,tp,g,sc)
    return #g>=1
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if #mat==0 then return end
    Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

-- Fusion + Ritual + Optional Destroy Cost Wrapper
function s.effcost(fustg,rittg)
    return function(e,tp,eg,ep,ev,re,r,rp,chk)
        e:SetLabel(-100)
        local g=Duel.GetMatchingGroup(s.monoppthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e,tp)
        -- b1/b2 = fusion/ritual validity + flag check
        local b1=fustg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
        local b2=rittg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+1)
        local b3=not Duel.HasFlagEffect(tp,id+2) and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
        if chk==0 then return b1 or b2 or b3 end
    end
end

-- Fusion + Ritual + Optional Destroy Target Wrapper
function s.efftg(fustg,fusop,rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        if chkc then return false end
        local cost_skip=e:GetLabel()~=-100
        local g=Duel.GetMatchingGroup(s.monoppthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e,tp)
        -- Check fusion/ritual validity as b1/b2
        local b1=fustg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
        local b2=rittg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+1)
        local b3=not Duel.HasFlagEffect(tp,id+2) and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
        if chk==0 then
            e:SetLabel(0)
            return b1 or b2 or b3
        end
        local op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,1)},
            {b2,aux.Stringid(id,2)},
            {b3,aux.Stringid(id,3)}
        )
        e:SetLabel(op)
        if op==1 then
            e:SetCategory(CATEGORY_SPECIAL_SUMMON)
            e:SetProperty(0)
            if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
            Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
        elseif op==2 then
            e:SetCategory(CATEGORY_SPECIAL_SUMMON)
            e:SetProperty(0)
            if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
            Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
        elseif op==3 then
            e:SetCategory(CATEGORY_DESTROY)
            e:SetProperty(EFFECT_FLAG_CARD_TARGET)
            if not cost_skip then Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1) end
            local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
            Duel.SetTargetCard(tg)
            Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,2,tp,0)
        end
    end
end


-- Fusion + Ritual + Optional Destroy Operation Wrapper
function s.effop(fustg,fusop,rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local op=e:GetLabel()
        if op==1 then
            if fustg(e,tp,eg,ep,ev,re,r,rp,0) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                fusop(e,tp,eg,ep,ev,re,r,rp)
            end
        elseif op==2 then
            if rittg(e,tp,eg,ep,ev,re,r,rp,0) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                ritop(e,tp,eg,ep,ev,re,r,rp)
            end
        elseif op==3 then
            local tg=Duel.GetTargetCards(e)
            if #tg>0 then
                Duel.Destroy(tg,REASON_EFFECT)
            end
        end
    end
end
