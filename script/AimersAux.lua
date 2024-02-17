--Aimers Auxillary Functions

if not aux.AimersAux then
    aux.AimersAux = {}
    Aimer = aux.AimersAux
end

if not Aimer then
    Aimer = aux.AimersAux
end

--Common use Events
EVENT_PENDULUM_ZONE_CHANGE = EVENT_CUSTOM + 3200
EVENT_ROVARIK = EVENT_CUSTOM + 3200

--Common used cards
CARD_ZORGA = 999415

--Common used Tokens
TOKEN_LEGION_F = 999611
TOKEN_LEGION_P = 999612
TOKEN_LEGION_Z = 999613


--Enviroment ids
VOLTAICPENDQ = 999563
VOLTAICMONQ = 999564
VOLTAICEQUQ = 999565

--Common Setcards
SET_VOLTAIC = 0x2A1
SET_VOLDRAGO = 0x2A2
SET_VOLTAIC_ARTIFACT = 0x12A1
SET_DEATHRALL = 0x2A3
SET_LEGION_TOKEN = 0x2A4



-- Gets cards Attribute countFunction to get the count of set bits (1s) in a card's attribute
function Aimer.GetAttributeCount(card)
    local att=card:GetAttribute()
    local count=0
    while att>0 do
        if att & 0x1~=0 then
            count=count+1
        end
        att=att>>1
    end
    return count
end

--Voltaic Same Columns
function Aimer.VoltaicSameColumns(e,cc)
    local function facedownfilter(c,tp)
        return c:IsControler(tp) and c:IsFacedown()
    end
    return cc:GetColumnGroup():IsExists(facedownfilter,1,cc,e:GetHandlerPlayer())
end

-- Utility filter and function to check if a card can be placed in the appropriate zone
function Aimer.CanMoveCardToAppropriateZone(c,p,checkOpponent)
    if checkOpponent==true then
        p=1-p -- If checking opponent, change the player ID
    end
    if c:IsMonster() then
        return Duel.GetLocationCount(p,LOCATION_MZONE)>0
    elseif c:IsSpellTrap() and not c:IsType(TYPE_FIELD) then
        if c:IsLocation(LOCATION_PZONE) then
            return Duel.CheckPendulumZones(p)
        else
            return Duel.GetLocationCount(p,LOCATION_SZONE)>0
        end
    end
    return false
end

function Aimer.MoveCardToAppropriateZone(tc,p,zoneType)
    local seq=-1
    if tc:IsLocation(LOCATION_MZONE) then
        seq=math.log(Duel.SelectDisableField(p,1,LOCATION_MZONE,0,0),2)
    elseif tc:IsLocation(LOCATION_STZONE) and not tc:IsLocation(LOCATION_PZONE) then
        local zone=Duel.SelectDisableField(p,1,LOCATION_SZONE,0,0)
        seq=math.log(zone,2)-8
        if not Duel.CheckLocation(p,LOCATION_SZONE,seq) then return end
    elseif tc:IsLocation(LOCATION_PZONE) then
        seq=tc:IsSequence(0) and 1 or 0
        zoneType=zoneType or LOCATION_PZONE
    end
    if seq>=0 then
        Duel.MoveSequence(tc,seq,zoneType)
    end
end

-- Add Voltaic Equip Per Chain Effect
function Aimer.AddVoltaicEquipEffect(c,id)
    --Apply Flag for One Name per Turn
    local function hdexcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
    -- Check if there are "Voltaic" monsters on the field
    local function hdexfilter(c,tp)
        return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_VOLTAIC) and not c:IsCode(id) and c:IsControler(tp) and c:IsFaceup()
    end
    local function hdexcon(e,tp,eg,ep,ev,re,r,rp)
        local g=eg:Filter(hdexfilter,nil,tp)
        return #g>0
    end
    -- Targeting condition for the Equip effect
    local function hdextg(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then
            return Duel.GetFlagEffect(tp,999566)==0 and #eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) and not c:IsForbidden()
        end
        Duel.RegisterFlagEffect(tp,999566,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
        local g=eg:Filter(hdexfilter,nil,tp)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
    end
    -- Equip operation for the added effect
    local function hdexop(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g=eg:FilterSelect(tp,hdexfilter,1,1,nil,tp)
        if #g>0 then
            Duel.HintSelection(g,true)
            Duel.Equip(tp,c,g:GetFirst())
        end
    end
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(3,999557)
    e1:SetRange(LOCATION_DECK)
    e1:SetCost(hdexcost)
    e1:SetCondition(hdexcon)
    e1:SetTarget(hdextg)
    e1:SetOperation(hdexop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP)
    c:RegisterEffect(e3)
end


--Voltaic face-down Pendulum Summon
function Aimer.AddVoltaicPendProcedure(c,reg,desc)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    if desc then
        e1:SetDescription(desc)
    else
        e1:SetDescription(1074)
    end
    e1:SetCode(EFFECT_SPSUMMON_PROC_G)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCondition(Aimer.VoltaicPendCondition())
    e1:SetOperation(Aimer.VoltaicPendOperation())
    e1:SetValue(SUMMON_TYPE_PENDULUM)
    c:RegisterEffect(e1)
    --register by default
    if reg==nil or reg then
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(1160)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    c:RegisterEffect(e2)
    end
end
function Aimer.VoltaicPendFilter(c,e,tp,lscale,rscale,lvchk)
    if lscale>rscale then lscale,rscale=rscale,lscale end
    local lv=0
    if c.pendulum_level then
        lv=c.pendulum_level
    else
        lv=c:GetLevel()
    end
    return c:IsSetCard(0x2A1) 
        and (lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) 
            and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false,POS_FACEDOWN_DEFENSE) and not c:IsForbidden()
end
function Aimer.VoltaicPendCondition()
    return function(e,c,og)
        if c==nil then return true end
        local tp=c:GetControler()
        local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
        if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,10000000)>0 then return false end
        local lscale=c:GetLeftScale()
        local rscale=rpz:GetRightScale()
        if lscale>rscale then lscale,rscale=rscale,lscale end
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<=0 then return false end
        if og then
            return og:Filter(Card.IsLocation,nil,LOCATION_HAND):IsExists(Aimer.VoltaicPendFilter,1,nil,e,tp,lscale,rscale)
        else
            return Duel.IsExistingMatchingCard(Aimer.VoltaicPendFilter,tp,LOCATION_HAND,0,1,nil,e,tp,lscale,rscale)
        end
    end
end
function Aimer.VoltaicPendOperation()
    return function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
        local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
        local lscale=c:GetLeftScale()
        local rscale=rpz:GetRightScale()
        if lscale>rscale then lscale,rscale=rscale,lscale end
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
        ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
        if og then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=og:Filter(Card.IsLocation,nil,LOCATION_HAND):FilterSelect(tp,Aimer.VoltaicPendFilter,0,ft,nil,e,tp,lscale,rscale)
            if g then
                sg:Merge(g)
            end
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,Aimer.VoltaicPendFilter,tp,LOCATION_HAND,0,0,ft,nil,e,tp,lscale,rscale)
            if g then
                sg:Merge(g)
            end
        end
        if #sg<=0 then return end
        local id=c:GetCode()
        Duel.Hint(HINT_CARD,0,id)
        Duel.RegisterFlagEffect(tp,10000000,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
        Duel.HintSelection(c,true)
        Duel.HintSelection(rpz,true)
        for tc in sg:Iter() do
            if tc:IsSetCard(0x2A1) then
                Duel.SpecialSummonStep(tc,SUMMON_TYPE_PENDULUM,tp,tp,true,false,POS_FACEDOWN_DEFENSE)
            end
        end
        Duel.SpecialSummonComplete()
    end
end


--Synchro monster, m-n tuners + m-n monsters
function Aimer.VoltaicSynchroAddProcedure(c,...)
    --parameters (f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
    if c.synchro_type==nil then
        local code=c:GetOriginalCode()
        local mt=c:GetMetatable()
        mt.synchro_type=1
        mt.synchro_parameters={...}
        if type(mt.synchro_parameters[2])=='function' then
            Debug.Message("Old Synchro Procedure detected in c"..code..".lua")
            return
        end
    end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(1172)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SPSUM_PARAM)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetTargetRange(POS_FACEDOWN_DEFENSE+POS_FACEUP,0)
    e1:SetCondition(Aimer.VoltaicSynchroCondition(...))
    e1:SetTarget(Aimer.VoltaicSynchroTarget(...))
    e1:SetOperation(Aimer.VoltaicSynchroOperation())
    e1:SetValue(SUMMON_TYPE_SYNCHRO)
    c:RegisterEffect(e1)
end

function Aimer.VoltaicSynchroCondition(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
    return  function(e,c,smat,mg,min,max)
                if c==nil then return true end
                if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
                -- Check if can be synchro mat/banish
                local function synchfilter(c)
                    return c:IsCanBeSynchroMaterial() and ((not c:IsLocation(LOCATION_GRAVE)) or (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)) or (c:IsLocation(LOCATION_PZONE) and c:IsFacedown() and c:IsAbleToHand()))
                end
                local tp=c:GetControler()
                local dg
                local lv=c:GetLevel()
                local g
                local mgchk
                if sub1 then
                    sub1=aux.OR(sub1,function(_c) return _c:IsHasEffect(30765615) and (not f1 or f1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) end)
                else
                    sub1=function(_c) return _c:IsHasEffect(30765615) and (not f1 or f1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) end
                end
                if mg then
                    dg=mg
                    g=mg:Filter(synchfilter,c,c)
                    mgchk=true
                else
                    local function synchmatfilter(mc)
                        local handmatfilter=mc:IsHasEffect(EFFECT_SYNCHRO_MAT_FROM_HAND)
                        local handmatvalue=nil
                        if handmatfilter then handmatvalue=handmatfilter:GetValue() end
                        return (mc:IsLocation(LOCATION_MZONE) and mc:IsFaceup()
                            and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)))
                            or (handmatfilter and handmatfilter:CheckCountLimit(tp) and handmatvalue(handmatfilter,mc,c))
                    end
                    dg=Duel.GetMatchingGroup(synchmatfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE,LOCATION_MZONE,c)
                    g=dg:Filter(synchfilter,nil,c)
                    mgchk=false
                end
                local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
                if not g:Includes(pg) or pg:IsExists(aux.NOT(synchfilter),1,nil,c) then return false end
                if smat then
                    if smat:IsExists(aux.NOT(synchfilter),1,nil,c) then return false end
                    pg:Merge(smat)
                    g:Merge(smat)
                end
                if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
                    --if there is a monster with EFFECT_SYNCHRO_CHECK (Genomix Fighter/Mono Synchron)
                    local g2=g:Clone()
                    if not mgchk then
                        local hg=Duel.GetMatchingGroup(synchfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
                        for thc in g:Iter() do
                            local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
                            if te then
                                local val=te:GetValue()
                                local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil) --tuner
                                g2:Merge(ag)
                            end
                        end
                    end
                    local res=g2:IsExists(Synchro.CheckP31,1,nil,g2,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                    local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
                    aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
                    Duel.AssumeReset()
                    return res
                else
                    --no race change
                    local tg
                    local ntg
                    if mgchk then
                        tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
                        ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
                    else
                        tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
                        ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
                        local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
                        thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
                        local hg=Duel.GetMatchingGroup(synchfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
                        for thc in aux.Next(thg) do
                            local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
                            local val=te:GetValue()
                            local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
                            local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
                            tg:Merge(thag)
                            ntg:Merge(nthag)
                        end
                    end
                    local lv=c:GetLevel()
                    local res=tg:IsExists(Synchro.CheckP41,1,nil,tg,ntg,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                    local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
                    aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
                    return res
                end
                return false
            end
end

function Aimer.VoltaicSynchroTarget(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
            -- Check if can be synchro mat/banish
            local function synchfilter(c)
                return c:IsCanBeSynchroMaterial() and ((not c:IsLocation(LOCATION_GRAVE)) or (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)) or (c:IsLocation(LOCATION_PZONE) and c:IsFacedown() and c:IsAbleToHand()))
            end
                local sg=Group.CreateGroup()
                local lv=c:GetLevel()
                local mgchk
                local g
                local dg
                if sub1 then
                    sub1=aux.OR(sub1,function(_c) return _c:IsHasEffect(30765615) and (not f1 or f1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) end)
                else
                    sub1=function(_c) return _c:IsHasEffect(30765615) and (not f1 or f1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) end
                end
                if mg then
                    mgchk=true
                    dg=mg
                    g=mg:Filter(synchfilter,c,c)
                else
                    mgchk=false
                    local function synchmatfilter(mc)
                        local handmatfilter=mc:IsHasEffect(EFFECT_SYNCHRO_MAT_FROM_HAND)
                        local handmatvalue=nil
                        if handmatfilter then handmatvalue=handmatfilter:GetValue() end
                        return (mc:IsLocation(LOCATION_MZONE) and mc:IsFaceup()
                            and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)))
                            or (handmatfilter and handmatfilter:CheckCountLimit(tp) and handmatvalue(handmatfilter,mc,c))
                    end
                    dg=Duel.GetMatchingGroup(synchmatfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE,LOCATION_MZONE,c)
                    g=dg:Filter(synchfilter,nil,c)
                end
                local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
                if smat then
                    pg:Merge(smat)
                    g:Merge(smat)
                end
                local tg
                local ntg
                if mgchk then
                    tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
                    ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
                else
                    tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
                    ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
                    local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
                    thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
                    local hg=Duel.GetMatchingGroup(synchfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
                    for thc in aux.Next(thg) do
                        local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
                        local val=te:GetValue()
                        local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
                        local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
                        tg:Merge(thag)
                        ntg:Merge(nthag)
                    end
                end
                local lv=c:GetLevel()
                local tsg=Group.CreateGroup()
                local selectedastuner=Group.CreateGroup()
                if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
                    local ntsg=Group.CreateGroup()
                    local tune=true
                    local g2=Group.CreateGroup()
                    while #ntsg<max2 do
                        local cancel=false
                        local finish=false
                        if tune then
                            cancel=not mgchk and Duel.IsSummonCancelable() and #tsg==0
                            local g3=ntg:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            g2=g:Filter(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            if #g3>0 and #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp)) then
                                g2:Merge(g3)
                            end
                            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
                            local tc=Group.SelectUnselect(g2,sg,tp,false,cancel)
                            if not tc then
                                if #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp))
                                    and ntg:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
                                else
                                    return false
                                end
                            end
                            if not sg:IsContains(tc) then
                                if g3:IsContains(tc) then
                                    ntsg:AddCard(tc)
                                    tune = false
                                else
                                    tsg:AddCard(tc)
                                end
                                selectedastuner:AddCard(tc)
                                sg:AddCard(tc)
                                for _, te in ipairs({tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}) do
                                    local val=te:GetValue()
                                    for mc in g:Iter() do
                                        val(te,mc)
                                    end
                                end
                            else
                                selectedastuner:RemoveCard(tc)
                                tsg:RemoveCard(tc)
                                sg:RemoveCard(tc)
                                if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
                                    Duel.AssumeReset()
                                end
                            end
                            if g:FilterCount(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max1 then
                                tune=false
                            end
                        else
                            if (#ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
                                and ntsg:IsExists(Synchro.NonTunerFilter,#ntsg,nil,f2,sub2,c,tp)
                                and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp)) then
                                    finish=true
                            end
                            cancel = (not mgchk and Duel.IsSummonCancelable()) and #sg==0
                            g2=g:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            if #g2==0 then break end
                            local g3=g:Filter(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            if #g3>0 and #(ntsg-selectedastuner)==0 and #tsg<max1 then
                                g2:Merge(g3)
                            end
                            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
                            local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
                            if not tc then
                                if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
                                    and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then break end
                                return false
                            end
                            if not selectedastuner:IsContains(tc) then
                                if not sg:IsContains(tc) then
                                    ntsg:AddCard(tc)
                                    sg:AddCard(tc)
                                    for _,te in ipairs({tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}) do
                                        local val=te:GetValue()
                                        for mc in g:Iter() do
                                            val(te,mc)
                                        end
                                    end
                                else
                                    ntsg:RemoveCard(tc)
                                    sg:RemoveCard(tc)
                                    if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
                                        Duel.AssumeReset()
                                    end
                                end
                            elseif #(ntsg-selectedastuner)==0 then
                                tune=true
                                selectedastuner:RemoveCard(tc)
                                ntsg:RemoveCard(tc)
                                tsg:RemoveCard(tc)
                                sg:RemoveCard(tc)
                            end
                        end
                    end
                    Duel.AssumeReset()
                else
                    local ntsg=Group.CreateGroup()
                    local tune=true
                    local g2=Group.CreateGroup()
                    while #ntsg<max2 do
                        local cancel=false
                        local finish=false
                        if tune then
                            cancel=not mgchk and Duel.IsSummonCancelable() and #tsg==0
                            local g3=ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            g2=tg:Filter(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            if #g3>0 and #tsg>=min1 and (not req1 or req1(tsg,c,tp)) then
                                g2:Merge(g3)
                            end
                            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
                            local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
                            if not tc then
                                if #tsg>=min1 and (not req1 or req1(tsg,c,tp))
                                    and ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
                                else
                                    return false
                                end
                            else
                                if not sg:IsContains(tc) then
                                    if g3:IsContains(tc) then
                                        ntsg:AddCard(tc)
                                        tune = false
                                    else
                                        tsg:AddCard(tc)
                                    end
                                    selectedastuner:AddCard(tc)
                                    sg:AddCard(tc)
                                else
                                    selectedastuner:RemoveCard(tc)
                                    tsg:RemoveCard(tc)
                                    sg:RemoveCard(tc)
                                end
                            end
                            if tg:FilterCount(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max1 then
                                tune=false
                            end
                        else
                            if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
                                and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then
                                finish=true
                            end
                            cancel=not mgchk and Duel.IsSummonCancelable() and #sg==0
                            g2=ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            if #g2==0 then break end
                            local g3=tg:Filter(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
                            if #g3>0 and #(ntsg-selectedastuner)==0 and #tsg<max1 then
                                g2:Merge(g3)
                            end
                            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
                            local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
                            if not tc then
                                if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
                                    and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then break end
                                return false
                            end
                            if not selectedastuner:IsContains(tc) then
                                if not sg:IsContains(tc) then
                                    ntsg:AddCard(tc)
                                    sg:AddCard(tc)
                                else
                                    ntsg:RemoveCard(tc)
                                    sg:RemoveCard(tc)
                                end
                            elseif #(ntsg-selectedastuner)==0 then
                                tune=true
                                selectedastuner:RemoveCard(tc)
                                ntsg:RemoveCard(tc)
                                tsg:RemoveCard(tc)
                                sg:RemoveCard(tc)
                            end
                        end
                    end
                end
                local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
                aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
                if sg then
                    local subtsg=tsg:Filter(function(_c) return sub1 and sub1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) and ((f1 and not f1(_c,c,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) or not _c:IsType(TYPE_TUNER)) end,nil)
                    local subc=subtsg:GetFirst()
                    while subc do
                        local e1=Effect.CreateEffect(c)
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetCode(EFFECT_ADD_TYPE)
                        e1:SetValue(TYPE_TUNER)
                        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                        subc:RegisterEffect(e1,true)
                        subc=subtsg:GetNext()
                    end
                    sg:KeepAlive()
                    e:SetLabelObject(sg)
                    return true
                else return false end
            end
    
end





function Aimer.VoltaicSynchroOperation()
    return function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
        local g=e:GetLabelObject()
        c:SetMaterial(g)
        --Execute the operation function of the Synchro Monster's "EFFECT_MATERIAL_CHECK" effect, if it exists ("Cupid Pitch")
        local mat_check_eff=c:IsHasEffect(EFFECT_MATERIAL_CHECK)
        if mat_check_eff then
            local mat_check_op=mat_check_eff:GetOperation()
            if mat_check_op then mat_check_op(mat_check_eff,c) end
        end
        --Use up the count limit of any "EFFECT_SYNCHRO_MAT_FROM_HAND" effect in the material group ("Revolution Synchron")
        for mc in g:Iter() do
            local handmatfilter=mc:IsHasEffect(EFFECT_SYNCHRO_MAT_FROM_HAND)
            if handmatfilter and handmatfilter:GetValue(handmatfilter,mc,c) then
                
                handmatfilter:UseCountLimit(tp)
            end
        end
        local tg=g:Filter(Auxiliary.TatsunecroFilter,nil)
        if #tg>0 then
            Synchro.Send=2
            for tc in aux.Next(tg) do tc:ResetFlagEffect(3096468) end
        end
        local sg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
        -- Remove GY Voldragos
        if #sg>0 then
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)
            g:Sub(sg)
        end
        local rg=g:Filter(Card.IsLocation,nil,LOCATION_PZONE)
        -- Return FD PendZone Voltaics
        if #rg>0 then
            Duel.SendtoHand(rg,nil,REASON_EFFECT+REASON_MATERIAL+REASON_SYNCHRO)
            g:Sub(rg)
        end
        if Synchro.Send==1 then
            Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO+REASON_RETURN)
        elseif Synchro.Send==2 then
            Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==3 then
            Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==4 then
            Duel.SendtoHand(g,nil,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==5 then
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_SYNCHRO)
        elseif Synchro.Send==6 then
            Duel.Destroy(g,REASON_MATERIAL+REASON_SYNCHRO)
        else
            Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
        end
        Synchro.Send=0
        Synchro.CheckAdditional=nil
        g:DeleteGroup()
    end
end





































--(checkOpponentMonsterZone, checkOpponentGraveyard) Setting to "true" sets the Locations to check against your own Locations. Use if You must have different Attributes.
--(checkPlayerMonsterZone, checkPlayerGraveyard) Setting to "true" sets the Locations to check against your opponents Locations. Use if Opponent must have different Attributes.
--atleast 1 of each player must be used.
--ie; (tp,true,false,true,false) would compare opponent' Mzone to your Mzone. and finds the single Attribute bits which are Unique Between both Players
function Aimer.GetUniqueAttributesByLocation(handler, oppLocations, playerLocations, oppFilter, playerFilter)
    oppLocations = oppLocations or 0
    playerLocations = playerLocations or 0
    oppFilter = oppFilter or function(c) return true end
    playerFilter = playerFilter or function(c) return true end

    local player = handler
    local attributes = {}

    -- Define a set of locations to iterate through
    local locations = {
        [LOCATION_MZONE] = { opp = true, player = true },
        [LOCATION_GRAVE] = { opp = true, player = true },
        [LOCATION_HAND] = { opp = true, player = true },
        [LOCATION_DECK] = { opp = true, player = true },
        [LOCATION_EXTRA] = { opp = true, player = true },
        [LOCATION_REMOVED] = { opp = true, player = true }
    }

    -- Helper function to iterate through a location
    local function IterateLocation(location, control, filter)
        local group = Duel.GetFieldGroup(control, location, 0)
        for _, card in ipairs(group) do
            if filter(card) then
                local att = card:GetAttribute()
                while att > 0 do
                    local bitPos = att & -att
                    attributes[bitPos] = true
                    att = att - bitPos
                end
            end
        end
    end

    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
                if (location == LOCATION_MZONE) then
                    for i = 0, 6 do
                        local zone = Duel.GetFieldCard(p, location, i)
                        if zone and oppFilter(zone) then
                            local att = zone:GetAttribute()
                            while att > 0 do
                                local bitPos = att & -att
                                attributes[bitPos] = true
                                att = att - bitPos
                            end
                        end
                    end
                end
            end
        end

        if (playerLocations & location) == location and flags.player then
            if (location == LOCATION_MZONE) then
                for i = 0, 6 do
                    local zone = Duel.GetFieldCard(player, location, i)
                    if zone and playerFilter(zone) then
                        local att = zone:GetAttribute()
                        while att > 0 do
                            local bitPos = att & -att
                            attributes[bitPos] = nil
                            att = att - bitPos
                        end
                    end
                end
            end
        end
    end
    -- Iterate through locations based on flags
    for location, flags in pairs(locations) do
        if (oppLocations & location) == location and flags.opp then
            for p = 0, 1 do
            local ct=Duel.GetFieldGroupCount(p, location, 0)
            for i = 0, ct - 1 do
                local zone = Duel.GetFieldCard(p, location, i)
                if zone and oppFilter(zone) then
                    local att = zone:GetAttribute()
                    while att > 0 do
                        local bitPos = att & -att
                        attributes[bitPos] = true
                        att = att - bitPos
                    end
                end
            end
        end
    end
        if (playerLocations & location) == location and flags.player then
            local ct=Duel.GetFieldGroupCount(player, location, 0)
            for i = 0, ct - 1 do
                local zone = Duel.GetFieldCard(player, location, i)
                if zone and oppFilter(zone) then
                    local att = zone:GetAttribute()
                    while att > 0 do
                        local bitPos = att & -att
                        attributes[bitPos] = true
                        att = att - bitPos
                    end
                end
            end
        end
    end
    local result = {}
    for att, _ in pairs(attributes) do
        table.insert(result, att)
    end

    return result
end






--Kijin Link Procedure for Monsters/Spells/Traps onfield
function Aimer.AddLinkProcedureMST(c,f,min,max,specialchk,desc)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    if desc then
        e1:SetDescription(desc)
    else
        e1:SetDescription(1174)
    end
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_EXTRA)
    if max==nil then max=c:GetLink() end
    e1:SetCondition(Aimer.Condition(f,min,max,specialchk))
    e1:SetTarget(Aimer.Target(f,min,max,specialchk))
    e1:SetOperation(Aimer.Operation(f,min,max,specialchk))
    e1:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(e1)
end
function Aimer.ConditionFilter(c,f,lc,tp)
    local res1=((c:IsCanBeLinkMaterial(lc,tp)) or (c:IsAbleToGraveAsCost() and c:IsSpellTrap())) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
    local res2=false
    local formud_eff=c:IsHasEffect(50366775)
    if formud_eff then
        local label={formud_eff:GetLabel()}
        for i=1,#label-1,2 do
            c:AssumeProperty(label[i],label[i+1])
        end
        res2=((c:IsCanBeLinkMaterial(lc,tp)) or (c:IsAbleToGraveAsCost() and c:IsSpellTrap())) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
    end
    return res1 or res2
end
function Aimer.GetLinkCount(c)
    if c:IsLinkMonster() and c:GetLink()>1 then
        return 1+0x10000*c:GetLink()
    else return 1 end
end
function Aimer.CheckRecursive(c,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
    if #sg>maxc then return false end
    filt=filt or {}
    sg:AddCard(c)
    for _,filt in ipairs(filt) do
        if not filt[2](c,filt[3],tp,sg,mg,lc,filt[1],1) then
            sg:RemoveCard(c)
            return false
        end
    end
    if not og:IsContains(c) then
        res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
        if not res then
            sg:RemoveCard(c)
            return false
        end
    end
    local res=Aimer.CheckGoal(tp,sg,lc,minc,f,specialchk,filt)
        or (#sg<maxc and mg:IsExists(Aimer.CheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)}))
    sg:RemoveCard(c)
    return res
end
function Aimer.CheckRecursive2(c,tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
    if #sg>maxc then return false end
    sg:AddCard(c)
    for _,filt in ipairs(filt) do
        if not filt[2](c,filt[3],tp,sg,mg,lc,filt[1],1) then
            sg:RemoveCard(c)
            return false
        end
    end
    if not og:IsContains(c) then
        res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
        if not res then
            sg:RemoveCard(c)
            return false
        end
    end
    if #(sg2-sg)==0 then
        if secondg and #secondg>0 then
            local res=secondg:IsExists(Aimer.CheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        else
            local res=Aimer.CheckGoal(tp,sg,lc,minc,f,specialchk,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        end
    end
    local res=Aimer.CheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
    sg:RemoveCard(c)
    return res
end
function Aimer.CheckGoal(tp,sg,lc,minc,f,specialchk,filt)
    for _,filt in ipairs(filt) do
        if not sg:IsExists(filt[2],1,nil,filt[3],tp,sg,Group.CreateGroup(),lc,filt[1],1) then
            return false
        end
    end
    return #sg>=minc and sg:CheckWithSumEqual(Aimer.GetLinkCount,lc:GetLink(),#sg,#sg)
        and (not specialchk or specialchk(sg,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end
function Aimer.Condition(f,minc,maxc,specialchk)
    return  function(e,c,must,g,min,max)
                if c==nil then return true end
                if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
                local tp=c:GetControler()
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
                end
                local mg=g:Filter(Aimer.ConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                if mustg:IsExists(aux.NOT(Aimer.ConditionFilter),1,nil,f,c,tp) or #mustg>max then return false end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.ConditionFilter,nil,f,c,tp)
                local mg_tg=mg+tg
                local res=mg_tg:Includes(mustg) and #mustg<=max
                if res then
                    if #mustg==max then
                        local sg=Group.CreateGroup()
                        res=mustg:IsExists(Aimer.CheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    elseif #mustg<max then
                        local sg=mustg
                        res=mg_tg:IsExists(Aimer.CheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    end
                end
                aux.DeleteExtraMaterialGroups(emt)
                return res
            end
end
function Aimer.Target(f,minc,maxc,specialchk)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
                end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                local mg=g:Filter(Aimer.ConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.ConditionFilter,nil,f,c,tp)
                local sg=Group.CreateGroup()
                local finish=false
                local cancel=false
                sg:Merge(mustg)
                local mg_tg=mg+tg
                while #sg<max do
                    local filters={}
                    if #sg>0 then
                        Aimer.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
                    end
                    local cg=mg_tg:Filter(Aimer.CheckRecursive,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
                    if #cg==0 then break end
                    finish=#sg>=min and #sg<=max and Aimer.CheckGoal(tp,sg,c,min,f,specialchk,filters)
                    cancel=not og and Duel.IsSummonCancelable() and #sg==0
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
                    local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
                    if not tc then break end
                    if #mustg==0 or not mustg:IsContains(tc) then
                        if not sg:IsContains(tc) then
                            sg:AddCard(tc)
                        else
                            sg:RemoveCard(tc)
                        end
                    end
                end
                if #sg>0 then
                    local filters={}
                    Aimer.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
                    sg:KeepAlive()
                    e:SetLabelObject({sg,filters,emt})
                    return true
                else
                    aux.DeleteExtraMaterialGroups(emt)
                    return false
                end
            end
end
function Aimer.Operation(f,minc,maxc,specialchk)
    return  function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
                local g,filt,emt=table.unpack(e:GetLabelObject())
                for _,ex in ipairs(filt) do
                    if ex[3]:GetValue() then
                        ex[3]:GetValue()(1,SUMMON_TYPE_LINK,ex[3],ex[1]&g,c,tp)
                        if ex[3]:CheckCountLimit(tp) then
                            ex[3]:UseCountLimit(tp,1)
                        end
                    end
                end
                for tc in g:Iter() do
                    local formud_eff=tc:IsHasEffect(50366775)
                    if formud_eff then
                        local res1=((tc:IsCanBeLinkMaterial(c,tp)) or (tc:IsAbleToGraveAsCost() and tc:IsSpellTrap())) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
                        local label={formud_eff:GetLabel()}
                        for i=1,#label-1,2 do
                            tc:AssumeProperty(label[i],label[i+1])
                        end
                        local res2=((tc:IsCanBeLinkMaterial(c,tp)) or (tc:IsAbleToGraveAsCost() and tc:IsSpellTrap())) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
                        if not res2 or (res1 and res2 and not Duel.SelectEffectYesNo(tp,tc)) then
                            Duel.AssumeReset()
                        end
                    end
                end
                c:SetMaterial(g)
                Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
                g:DeleteGroup()
                aux.DeleteExtraMaterialGroups(emt)
            end
end