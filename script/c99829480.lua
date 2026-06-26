--Sylvestrie Vitae Unification
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    local fparams={handler=c,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_SYLVESTRIE),extrafil=s.fextra,extraop=s.fusextraop,extratg=s.fusextratg}
    local rparams={handler=c,lvtype=RITPROC_GREATER,filter=s.rspfilter,extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_DECK,forcedselection=s.ritcheck}
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
s.listed_series={SET_SYLVESTRIE}

----------------------------------------------
--Fusion Summon
function s.fextra(e,tp,mg)
    local eg=Group.CreateGroup()
    if Duel.IsPlayerAffectedByEffect(tp,999960) then
        local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
        if #sg>0 then eg:Merge(sg) end
    end
    if #eg>0 then return eg end
    return nil
end

function s.fusextratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end 

function s.exfilter(c)
    return c:IsMonster() and c:IsAbleToRemove()
end
function s.fusextraop(e,tc,tp,sg)
    local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    if #rg>0 then
        Duel.Remove(rg,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
        sg:Sub(rg)
    end
end


------------------------------------------------
--Ritual Summon
function s.rspfilter(c)
    local loc=c:GetLocation()
    return c:IsSetCard(SET_SYLVESTRIE)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_REMOVED,0,nil)
    return g
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.matfilter(c)
    return c:IsAbleToDeck() and c:IsSetCard(SET_SYLVESTRIE) and c:HasLevel() and c:IsMonster()
end
function s.ritcheck(e,tp,g,sc)
    return #g>=1
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if #mat==0 then return end
    Duel.SendtoDeck(mat,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

-------------------------------------------
--ToDeck Filter
function s.monoppthfilter(c)
    return c:IsType(TYPE_FIELD) and c:IsAbleToRemove()
end
function s.monoppthchk(g,e,tp)
    local c=e:GetHandler()
    local ft=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):FilterCount(function(tc) return tc~=c end,nil)
    local onfield_count=g:FilterCount(function(tc) return tc:IsLocation(LOCATION_ONFIELD) and tc~=c end,nil)
    return (ft-onfield_count)>=1
end

-- Fusion + Ritual + Optional Destroy Cost Wrapper
function s.effcost(fustg,rittg)
    return function(e,tp,eg,ep,ev,re,r,rp,chk)
        e:SetLabel(-100)
        local c=e:GetHandler()
        local fg=Duel.GetMatchingGroup(s.monoppthfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,c)
        -- b1/b2 = fusion/ritual validity + flag check
        local b1=fustg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
        local b2=rittg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+1)
        local b3=not Duel.HasFlagEffect(tp,id+2) and #fg>=2 and aux.SelectUnselectGroup(fg,e,tp,2,2,s.monoppthchk,0)
        if chk==0 then return b1 or b2 or b3 end
    end
end

function s.monoppthtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.monoppthfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if chk==0 then
        return aux.SelectUnselectGroup(g,e,tp,2,2,s.monoppthchk,0)
    end
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.monoppthchk,1,tp,HINTMSG_REMOVE,s.monoppthchk)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end


-- Fusion + Ritual + Optional Destroy Target Wrapper
function s.efftg(fustg,fusop,rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        if chkc then return false end
        local cost_skip=e:GetLabel()~=-100
        local c=e:GetHandler()
        local fg=Duel.GetMatchingGroup(s.monoppthfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,c)
        -- Check fusion/ritual validity as b1/b2
        local b1=fustg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
        local b2=rittg(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+1)
        local b3=not Duel.HasFlagEffect(tp,id+2) and aux.SelectUnselectGroup(fg,e,tp,2,2,s.monoppthchk,0)
        if chk==0 then
            e:SetLabel(0)
            return b1 or b2 or b3
        end
        local op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,0)},
            {b2,aux.Stringid(id,1)},
            {b3,aux.Stringid(id,2)}
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
            Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
        elseif op==3 then
            e:SetCategory(CATEGORY_TODECK)
            if not cost_skip then Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1) end
            local tg=aux.SelectUnselectGroup(fg,e,tp,2,2,s.monoppthchk,1,tp,HINTMSG_REMOVE,s.monoppthchk)
            e:SetLabelObject(tg)
            Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD)
        end
    end
end


-- Fusion + Ritual + Optional Destroy Operation Wrapper
function s.effop(fustg,fusop,rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local op=e:GetLabel()
        local tg=e:GetLabelObject()
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
           local tg=e:GetLabelObject()
            if not tg or #tg==0 then return end
            local ct=Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
            if ct>0 then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
                if #sg>0 then
                    Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
                end
            end
        end
    end
end