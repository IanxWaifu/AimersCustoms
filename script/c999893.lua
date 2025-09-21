--Kegai - Shakudo ni Mebuku Kegaima
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate 1 of these effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Additional Normal summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,4))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_KEGAI))
    c:RegisterEffect(e2)
    --Return to hand and activate Field Spell
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.acttg)
    e3:SetOperation(s.actop)
    c:RegisterEffect(e3)
    --Special the Material
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
    e4:SetCode(EVENT_CUSTOM+id)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,1})
    --[[e4:SetCondition(s.regcon)--]]
    e4:SetTarget(s.lfsptg)
    e4:SetOperation(s.lfspop)
    c:RegisterEffect(e4)
    local g=Group.CreateGroup()
    g:KeepAlive()
    local mapping={} -- material-to-ritual monster map table
    -- Store both the group and mapping table inside e4's LabelObject
    e4:SetLabelObject({g,mapping})
    -- Effect to register materials used for ritual summons
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e5:SetCode(EVENT_BE_MATERIAL)
    e5:SetRange(LOCATION_SZONE)
    e5:SetLabelObject(e4)
    e5:SetOperation(s.regop)
    c:RegisterEffect(e5)
    -- Effect to track ritual summons and populate mapping table
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetRange(LOCATION_SZONE)
    e6:SetLabelObject(e4:GetLabelObject()) -- share same LabelObject {g,mapping}
    e6:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        local val=e:GetLabelObject()
        local g,map=val[1],val[2]
        for rc in eg:Iter() do
            if rc:IsType(TYPE_RITUAL) and rc:IsSummonType(SUMMON_TYPE_RITUAL) then
                local mats=rc:GetMaterial()
                for mc in mats:Iter() do
                    map[mc]=rc
                end
            end
        end
    end)
    c:RegisterEffect(e6)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}

function s.actfilter(c,tp)
    return c:IsCode(999888) and c:IsFieldSpell() and not c:IsForbidden() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:GetActivateEffect():IsActivatable(tp,true) 
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE)) then return end 
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.actfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,tp)
    local tc=sg:GetFirst()
    local te=tc:GetActivateEffect()
    if not te then return end
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
    local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
    if pre[1] then
        for i,eff in ipairs(pre) do
            local prev=eff:GetValue()
            if type(prev)~='function' or prev(eff,te,tp) then return end
        end
    end
    if tc then
    Duel.HintSelection(sg)
    te:UseCountLimit(tp,1)
        local tpe=tc:GetType()
        local tg=te:GetTarget()
        local co=te:GetCost()
        local op=te:GetOperation()
        e:SetCategory(te:GetCategory())
        e:SetProperty(te:GetProperty())
        Duel.ClearTargetCard()
        local loc=LOCATION_SZONE
        if (tpe&TYPE_FIELD)~=0 then
            loc=LOCATION_FZONE
            local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
            if Duel.IsDuelType(DUEL_1_FIELD) then
                if fc then Duel.Destroy(fc,REASON_RULE) end
                fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
                if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
            else
                fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
                if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
            end
        if (tpe&TYPE_FIELD)==TYPE_FIELD then
            Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true) end
        end
        Duel.Hint(HINT_CARD,0,tc:GetCode())
        tc:CreateEffectRelation(te)
        if te:GetCode()==EVENT_CHAINING then
            local chain=Duel.GetCurrentChain()-1
            local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
            local tc=te2:GetHandler()
            local g=Group.FromCards(tc)
            local p=tc:GetControler()
            if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
            if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
        elseif te:GetCode()==EVENT_FREE_CHAIN then
            if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
            if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
        else
            local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
            if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
            if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
        end
        Duel.BreakEffect()
        local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
        if g then
            local etc=g:GetFirst()
            while etc do
                etc:CreateEffectRelation(te)
                etc=g:GetNext()
            end
        end
        tc:SetStatus(STATUS_ACTIVATED,true)
        if not tc:IsDisabled() then
            if te:GetCode()==EVENT_CHAINING then
                local chain=Duel.GetCurrentChain()-1
                local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
                local tc=te2:GetHandler()
                local g=Group.FromCards(tc)
                local p=tc:GetControler()
                if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
            elseif te:GetCode()==EVENT_FREE_CHAIN then
                if op then op(te,tp,eg,ep,ev,re,r,rp) end
            else
                local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
                if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
            end
        else
            --insert negated animation here
        end
        Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
        if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
            Duel.Equip(tp,tc,g:GetFirst())
        end
        tc:ReleaseEffectRelation(te)
        if etc then
            etc=g:GetFirst()
            while etc do
                etc:ReleaseEffectRelation(te)
                etc=g:GetNext()
            end
        end
    end
end


function s.ritual_summon_reg(e,tp,eg,ep,ev,re,r,rp)
    local map=e:GetLabelObject()
    for rc in eg:Iter() do
        if rc:IsType(TYPE_RITUAL) and rc:IsSummonType(SUMMON_TYPE_RITUAL) then
            local mats=rc:GetMaterial()
            for mc in mats:Iter() do
                map[mc]=rc
            end
        end
    end
end

--If used as Ritual Material
function s.regfilter(c,e,tp)
    return c:IsSetCard(SET_KEGAI) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and 
    c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsReason(REASON_RITUAL) or c:IsReason(REASON_SYNCHRO)) and c:IsReason(REASON_MATERIAL))
end

--Check for if used as Ritual/Synchro Material
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_RITUAL) or c:IsReason(REASON_SYNCHRO)
end

-- Use map inside e4's LabelObject (passed via e:GetLabelObject())
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsPhase(PHASE_DAMAGE) then return end
    if not (r&REASON_RITUAL)==REASON_RITUAL then return end
    local e4=e:GetLabelObject()
    local val=e4:GetLabelObject()
    local g,map=val[1],val[2]
    local tg=eg:Filter(s.regfilter,nil,e,tp)
    if #tg>0 then
        for tc in tg:Iter() do
            tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
            local ritualMonster=map[tc]
            map[tc]=ritualMonster
        end
        if Duel.GetCurrentChain()==0 then g:Clear() end
        g:Merge(tg)
        g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
        e:SetLabelObject({g,map})
        if Duel.GetFlagEffect(tp,id)==0 then
            Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
            Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
        end
    end
end

function s.lfsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=e:GetLabelObject()[1]:Filter(s.regfilter,nil,e,tp)
    if chkc then return g:IsContains(chkc) and s.regfilter(chkc,e,tp) end
    if chk==0 then return #g>0 end
    Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=g:Select(tp,1,1,nil)
    Duel.SetTargetCard(tg)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
end

function s.lfspop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local _,map=table.unpack(e:GetLabelObject())
    local ritraceCard=map[tc]
    local ritrace=ritraceCard and ritraceCard:GetRace() or nil
    if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Only apply extra effect if race matches
        if ritrace and ritrace&RACE_DRAGON~=0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #g>0 then
                Duel.HintSelection(g)
                Duel.BreakEffect()
                Duel.Destroy(g,REASON_EFFECT)
            end
        elseif ritrace and ritrace&RACE_REPTILE~=0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #g>0 then
                Duel.HintSelection(g)
                Duel.BreakEffect()
                Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
            end
        end
        -- If ritrace is nil or any other type, do nothing extra
    end
    -- Clear map
    for k in pairs(map) do map[k]=nil end
end
