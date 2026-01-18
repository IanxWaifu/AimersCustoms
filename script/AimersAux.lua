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
EVENT_ASTRAL_SHIFT = EVENT_CUSTOM + 3300
EVENT_ASTRAL_EFFECT_PROC = EVENT_CUSTOM + 3305
EVENT_ASTRAL_SHIFT_END = EVENT_CUSTOM + 3310


--Common used cards
CARD_ZORGA = 999415

--Common used Tokens
TOKEN_LEGION_F = 999611
TOKEN_LEGION_P = 999612
TOKEN_LEGION_Z = 999613


--Enviroment ids and effects
VOLTAICPENDQ = 999563
VOLTAICMONQ = 999564
VOLTAICEQUQ = 999565

----------------------------------

--Common Setcards
SET_VOLTAIC = 0x2A1
SET_VOLDRAGO = 0x2A2
SET_VOLTAIC_ARTIFACT = 0x12A1
SET_DEATHRALL = 0x2A3
SET_LEGION_TOKEN = 0x2A4
SET_CYENE = 0x2A5
SET_ICYENE = 0x12A5
SET_DRAGOCYENE = 0x22A5
SET_DAEMON = 0x718
SET_DAEDRIC_RELIC = 0x719
SET_ARCHDAEMON = 0x1718
SET_NECROTIC = 0x29f
SET_NECROTICRYPT = 0x129f
SET_WIZARDRAKE = 0x12A7
SET_BEASKETEER = 0x12A8
SET_STAR_RELIC = 0x12A9
SET_STELLARIUS = 0x12D9
SET_DIVINE_ = 0x12E0
SET_IRON_SAGA = 0x12EC
SET_KIJIN = 0x12EA
SET_LEGENDS_AND_MYTHS = 0xFB0
SET_KNIGHTS_OF_THE_FALLEN = 0xFA0
SET_REVELATIA = 0x19f
SET_ZODIAKIERI = 0x12D7
SET_AZHIMAOU = 0x311
SET_NOVALXON = 0x313
SET_ALEKRON = 0x316
SET_KEGAI = 0x1315
SET_KYOSHIN = 0x131C


--Common used Flags
ASTRAL_FLAG = 999800  -- Astral Overlay Flag Check
EFFECT_EXTRA_ASTRAL = 3305
REGISTER_FLAG_ASTRAL_STATE = 999799

--Common used Counters and Effects
COUNTER_ICE = 0x1015
COUNTER_BLAZE = 0x1515


--Dragocyene Frostrine Cost Bypass
function Aimer.FrostrineCheckEnvironment(tp)
    local envactive=Duel.IsPlayerAffectedByEffect(tp,999721)
    return envactive and Duel.GetFlagEffect(tp,999721)<=0
end

function Aimer.FrostrineCounterCost(e,tp,eg,ep,ev,re,r,rp,chk,counter_amount,extra_cost)
    counter_amount = counter_amount or 3 -- Default to 3 if no amount is provided
    if chk == 0 then
        return Aimer.FrostrineCheckEnvironment(tp) or Duel.IsCanRemoveCounter(tp,1,1,COUNTER_ICE,counter_amount,REASON_COST)
    end
    local check = 0
    if Duel.GetCounter(tp,1,1,COUNTER_ICE)>=counter_amount and Aimer.FrostrineCheckEnvironment(tp) then
        if Duel.SelectYesNo(tp, aux.Stringid(999721,1)) then
            Duel.RegisterFlagEffect(tp,999721,RESET_PHASE + PHASE_END, 0, 1)
            Duel.Hint(HINT_CARD,0,999721)
            check = check + 1
        end
    elseif Duel.GetCounter(tp,1,1,COUNTER_ICE)<counter_amount and Aimer.FrostrineCheckEnvironment(tp) then
        Duel.RegisterFlagEffect(tp,999721,RESET_PHASE+PHASE_END,0,1)
        Duel.Hint(HINT_CARD,0,999721)
        check = check + 1
    end
    if check == 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        Duel.RemoveCounter(tp,1,1,COUNTER_ICE,counter_amount,REASON_COST)
    end
    -- Always apply the extra cost function
    if extra_cost then
        extra_cost(e,tp,eg,ep,ev,re,r,rp,chk) -- Pass chk to the extra_cost function
    end
end
-----------------------------------



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


--Gets the cards current Position (Monsters/Spell/Traps)
function Aimer.GetCardPositionInfo(c)
    local seq=c:GetSequence()
    local pos=0 
    if c:IsSpellTrap() or (c:IsMonster() and c:IsFacedown()) then 
        pos=POS_FACEUP_DEFENSE 
    else 
        pos=c:GetPosition() 
    end
    local seqbit=0
    if c:IsLocation(LOCATION_MMZONE) then 
        seqbit=2^seq 
    elseif c:IsLocation(LOCATION_STZONE) then 
        seqbit=1<<seq 
    elseif c:IsLocation(LOCATION_EMZONE) then
        if seq==5 then 
            seqbit=2 
        elseif seq==6 then 
            seqbit=8 
        end 
    end
    return seq,pos,seqbit
end

--Moves cards to another Appropriate Zone that the card can be in Normally
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

--Flips both Monster and Spell/Traps (opposite position they have currently)
function Aimer.FlipCard(e,tc,tp)
    local chpos=0
    local pos=tc:GetPosition()
    local faceup=(pos&POS_FACEUP)~=0
    if tc:IsMonster() then
        local facedown=(pos&POS_FACEDOWN_DEFENSE)~=0
        if faceup then
            chpos=POS_FACEDOWN_DEFENSE
        elseif facedown then
            -- Choose between POS_FACEUP_ATTACK and POS_FACEUP_DEFENSE
            chpos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
        end
        Duel.ChangePosition(tc,chpos)
    else
        local facedown=(pos&POS_FACEDOWN)~=0
        if faceup then
            chpos=POS_FACEDOWN
        elseif facedown then
            chpos=POS_FACEUP
        end
        if chpos==POS_FACEDOWN then
            Duel.ChangePosition(tc,chpos)
            Duel.RaiseSingleEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
            Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
        elseif chpos==POS_FACEUP then
            Duel.ChangePosition(tc,chpos)
            Duel.RaiseSingleEvent(tc,EVENT_CHANGE_POS,e,REASON_EFFECT,tp,tp,0)
            Duel.RaiseEvent(tc,EVENT_CHANGE_POS,e,REASON_EFFECT,tp,tp,0)
        end
    end
end

--Specifies the Token to be Summoned
function Aimer.DeathrallSummonByRaceCheck(tp,race,p,pos,seqbit)
    local token_id=0
    if race==RACE_FIEND then token_id=TOKEN_LEGION_F
    elseif race==RACE_PYRO then token_id=TOKEN_LEGION_P
    elseif race==RACE_ZOMBIE then token_id=TOKEN_LEGION_Z
    else return end
    local token=Duel.CreateToken(tp,token_id)
    Duel.SpecialSummon(token,0,tp,p,false,false,pos,seqbit)
end



-- Add Voltaic Equip Per Chain Effect
function Aimer.AddVoltaicEquipEffect(c,id,s)
    --Apply Flag for One Name per Turn
    local function hdexcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
    -- Check if there are "Voltaic" monsters on the field
    local function hdexfilter(c,tp)
        return c:IsMonster() and c:IsSetCard(SET_VOLTAIC) and c:IsControler(tp) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
    end
    local function hdexcon(e,tp,eg,ep,ev,re,r,rp)
        local g=eg:IsExists(hdexfilter,1,nil,tp)
        return g
    end
    -- Targeting condition for the Equip effect
    local function hdextg(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        local g=eg:IsExists(hdexfilter,1,nil,tp)
        if chk==0 then
            return Duel.GetFlagEffect(tp,999566)==0 and #eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) and not c:IsForbidden()
        end
        Duel.RegisterFlagEffect(tp,999566,RESET_CHAIN,0,1)
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
    local function regop(e,tp,eg,ep,ev,re,r,rp)
    local tg=eg:Filter(hdexfilter,nil,tp)
        for tc in aux.Next(eg) do
            if tc:IsSummonType(SUMMON_TYPE_PENDULUM) and tc:GetFlagEffect(100000001)>0  then return end
                tc:RegisterFlagEffect(999567,RESET_CHAIN,0,1)
                Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+999567,re,r,tp,ep,ev)
            end
                local g=e:GetLabelObject():GetLabelObject()
                if Duel.GetCurrentChain()==0 then g:Clear() end
                g:Merge(tg)
                g:Remove(function(c) return c:GetFlagEffect(999567)==0 end,nil)
                e:GetLabelObject():SetLabelObject(g)
                if #g>0 and not Duel.HasFlagEffect(tp,999567) then
                    Duel.RegisterFlagEffect(tp,999567,RESET_CHAIN,0,1)
                    Duel.RaiseEvent(g,EVENT_CUSTOM+999567,re,r,tp,ep,ev) 
        end
    end
    local function regop2(e,tp,eg,ep,ev,re,r,rp)
    local tg=eg:Filter(hdexfilter,nil,tp)
        for tc in aux.Next(eg) do
            Debug.Message("Position" .. tc:GetPosition())
            if tc:IsSummonType(SUMMON_TYPE_PENDULUM) and tc:GetFlagEffect(100000001)==0 and tc:IsFacedown() then return end
                tc:RegisterFlagEffect(999567,RESET_CHAIN,0,1)
                Duel.RaiseSingleEvent(tc,EVENT_CUSTOM+999567,re,r,tp,ep,ev)
            end
                local g=e:GetLabelObject():GetLabelObject()
                if Duel.GetCurrentChain()==0 then g:Clear() end
                g:Merge(tg)
                g:Remove(function(c) return c:GetFlagEffect(999567)==0 end,nil)
                e:GetLabelObject():SetLabelObject(g)
                if #g>0 and not Duel.HasFlagEffect(tp,999567) then
                    Duel.RegisterFlagEffect(tp,999567,RESET_CHAIN,0,1)
                    Duel.RaiseEvent(g,EVENT_CUSTOM+999567,re,r,tp,ep,ev) 
        end
    end
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_CUSTOM+999567)
    e1:SetCountLimit(3,999557)
    e1:SetRange(LOCATION_DECK)
    e1:SetCost(hdexcost)
    e1:SetCondition(hdexcon)
    e1:SetTarget(hdextg)
    e1:SetOperation(hdexop)
    c:RegisterEffect(e1)
    --Collect Groups of Event Cards
    local g=Group.CreateGroup()
    g:KeepAlive()
    e1:SetLabelObject(g)
    --Keep track of monsters flipped/summoned
    local e3a=Effect.CreateEffect(c)
    e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3a:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3a:SetRange(LOCATION_DECK)
    e3a:SetLabelObject(e1)
    e3a:SetOperation(regop)
    c:RegisterEffect(e3a)
    local e3b=e3a:Clone()
    e3b:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e3b)
    local e3c=e3a:Clone()
    e3c:SetCode(EVENT_FLIP)
    c:RegisterEffect(e3c)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_CUSTOM+999568)
    e4:SetRange(LOCATION_DECK)
    e4:SetLabelObject(e1)
    e4:SetOperation(regop2)
    c:RegisterEffect(e4)
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
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTargetRange(LOCATION_SZONE,0)
    e2:SetCondition(Aimer.VoltaicPendGrantCon)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_PZONE))
    e2:SetLabelObject(e1)
    c:RegisterEffect(e2)
    --register by default
    if reg==nil or reg then
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(1160)
        e3:SetType(EFFECT_TYPE_ACTIVATE)
        e3:SetCode(EVENT_FREE_CHAIN)
        e3:SetRange(LOCATION_HAND)
        c:RegisterEffect(e3)
    end
end

function Aimer.VoltaicPendGrantCon(e,c)
    local c=e:GetHandler()
    local tp=c:GetControler()
    local pgl=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local pgr=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    return pgr==c and pgl and not pgl:IsOriginalSetCard(SET_VOLTAIC)
end

function Aimer.VoltaicPendFilter(c,e,tp,lscale,rscale,lvchk)
    if lscale>rscale then lscale,rscale=rscale,lscale end
    local lv=0
    if c.pendulum_level then
        lv=c.pendulum_level
    else
        lv=c:GetLevel()
    end
    return ((c:IsSetCard(SET_VOLTAIC) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false,POS_FACEDOWN_DEFENSE)) or (c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false,POS_FACEUP)))
        and (lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) and not c:IsForbidden()
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
        Duel.RegisterFlagEffect(tp,10000000,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
        Duel.HintSelection(c,true)
        Duel.HintSelection(rpz,true)
        local ge1=Effect.CreateEffect(e:GetHandler())
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_ADJUST)
        ge1:SetLabelObject(sg)
        ge1:SetCountLimit(1)
        ge1:SetCondition(Aimer.VPRCon)
        ge1:SetOperation(Aimer.VPRegop)
        Duel.RegisterEffect(ge1,0)
        Duel.RegisterFlagEffect(tp,100000001,RESET_PHASE+PHASE_END,0,1)
        for tc in sg:Iter() do
            tc:RegisterFlagEffect(100000001,RESET_EVENT+RESET_TURN_SET,0,1)
        end
    end
end


function Aimer.VPRCon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentChain()==0
end

function Aimer.VPRfilter(c)
    return c:IsSetCard(SET_VOLTAIC) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end

--Raise Custom Event
function Aimer.VPRegop(e,tp,eg,ep,ev,re,r,rp)
    local sg=e:GetLabelObject()
    local tg=sg:Filter(Aimer.VPRfilter,nil)
    if Duel.GetFlagEffect(tp,100000001)==0 then return end
    Duel.ResetFlagEffect(tp,100000001)
    local sg=aux.SelectUnselectGroup(tg,e,tp,0,#tg,nil,1,tp,HINTMSG_POS_CHANGE)
    Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
    Duel.RaiseEvent(tg,EVENT_CUSTOM+999568,re,r,tp,ep,ev)
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




--Synchro monster, m-n tuners + m-n monsters
function Aimer.KegaiSynchroAddProcedure(c,...)
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
    e1:SetTargetRange(POS_FACEUP,0)
    e1:SetCondition(Aimer.KegaiSynchroCondition(...))
    e1:SetTarget(Aimer.KegaiSynchroTarget(...))
    e1:SetOperation(Aimer.KegaiSynchroOperation())
    e1:SetValue(SUMMON_TYPE_SYNCHRO)
    c:RegisterEffect(e1)
end

function Aimer.KegaiAddSynchroMaterialEffect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
    e1:SetRange(LOCATION_STZONE)
    e1:SetCondition(Aimer.KegaiAddMaterialCondition)
    e1:SetValue(Aimer.KegaiAddMaterialValue)
    c:RegisterEffect(e1)
end

function Aimer.KegaiAddMaterialCondition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_STZONE)
    and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)<Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)
end

function Aimer.KegaiAddMaterialValue(e,mc,sc)
    return sc:IsType(TYPE_SYNCHRO) and (sc:IsCode(999902) or sc:IsCode(999903))
end

function Aimer.KegaiSynchroCondition(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
    return  function(e,c,smat,mg,min,max)
                if c==nil then return true end
                if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
                -- Check if can be synchro mat/banish
                local function synchfilter(c)
                    return c:IsCanBeSynchroMaterial() or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup() and c:IsSetCard(SET_KEGAI) and c:IsCanBeSynchroMaterial())
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
                    dg=Duel.GetMatchingGroup(synchmatfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_SZONE,LOCATION_MZONE,c)
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

function Aimer.KegaiSynchroTarget(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
            -- Check if can be synchro mat/banish
            local function synchfilter(c)
                return c:IsCanBeSynchroMaterial() or (c:IsLocation(LOCATION_SZONE) and c:IsFaceup() and c:IsSetCard(SET_KEGAI) and c:IsCanBeSynchroMaterial())
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
                    dg=Duel.GetMatchingGroup(synchmatfilter,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_SZONE,LOCATION_MZONE,c)
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





function Aimer.KegaiSynchroOperation()
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
        local rg=g:Filter(Card.IsLocation,nil,LOCATION_SZONE)
        -- Send S/T Kegais
        if #rg>0 then
            Duel.SendtoGrave(rg,REASON_MATERIAL+REASON_SYNCHRO)
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
                        attributes[bitPos] = nil
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


-- Legion Token Special Summon Check
function Aimer.LegionTokenSP(tp, race)
    local token
    if race == RACE_FIEND then
        token = Duel.CreateToken(tp, TOKEN_LEGION_F)
    elseif race == RACE_PYRO then
        token = Duel.CreateToken(tp, TOKEN_LEGION_P)
    elseif race == RACE_ZOMBIE then
        token = Duel.CreateToken(tp, TOKEN_LEGION_Z)
    else
        return nil  -- Return nil if the race does not match any case
    end
    return token
end

--Deathrall Link Proc (2+ GreaterThan)
function Aimer.AddLinkProcedureDeathrall(c,f,min,max,specialchk,desc)
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
    e1:SetCondition(Aimer.DCondition(f,min,max,specialchk))
    e1:SetTarget(Aimer.DTarget(f,min,max,specialchk))
    e1:SetOperation(Aimer.DOperation(f,min,max,specialchk))
    e1:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(e1)
end
function Aimer.DConditionFilter(c,f,lc,tp)
    local res1=c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
    local res2=false
    local formud_eff=c:IsHasEffect(50366775)
    if formud_eff then
        local label={formud_eff:GetLabel()}
        for i=1,#label-1,2 do
            c:AssumeProperty(label[i],label[i+1])
        end
        res2=c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
    end
    return res1 or res2
end
function Aimer.DGetLinkCount(c)
    if c:IsLinkMonster() and c:GetLink()>1 then
        return 1+0x10000*c:GetLink()
    else return 1 end
end
function Aimer.DCheckRecursive(c,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
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
    local res=Aimer.DCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
        or (#sg<maxc and mg:IsExists(Aimer.DCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)}))
    sg:RemoveCard(c)
    return res
end
function Aimer.DCheckRecursive2(c,tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
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
            local res=secondg:IsExists(Aimer.DCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        else
            local res=Aimer.DCheckGoal(tp,sg,lc,minc,f,specialchk,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        end
    end
    local res=Aimer.DCheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
    sg:RemoveCard(c)
    return res
end
function Aimer.DCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
    for _,filt in ipairs(filt) do
        if not sg:IsExists(filt[2],1,nil,filt[3],tp,sg,Group.CreateGroup(),lc,filt[1],1) then
            return false
        end
    end
    return #sg>=minc and sg:CheckWithSumGreater(Aimer.DGetLinkCount,lc:GetLink(),#sg,#sg)
        and (not specialchk or specialchk(sg,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end
function Aimer.DCondition(f,minc,maxc,specialchk)
    return  function(e,c,must,g,min,max)
                if c==nil then return true end
                if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
                local tp=c:GetControler()
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
                end
                local mg=g:Filter(Aimer.DConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                if mustg:IsExists(aux.NOT(Aimer.DConditionFilter),1,nil,f,c,tp) or #mustg>max then return false end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.DConditionFilter,nil,f,c,tp)
                local mg_tg=mg+tg
                local res=mg_tg:Includes(mustg) and #mustg<=max
                if res then
                    if #mustg==max then
                        local sg=Group.CreateGroup()
                        res=mustg:IsExists(Aimer.DCheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    elseif #mustg<max then
                        local sg=mustg
                        res=mg_tg:IsExists(Aimer.DCheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    end
                end
                aux.DeleteExtraMaterialGroups(emt)
                return res
            end
end
function Aimer.DTarget(f,minc,maxc,specialchk)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
                end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                local mg=g:Filter(Aimer.DConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.DConditionFilter,nil,f,c,tp)
                local sg=Group.CreateGroup()
                local finish=false
                local cancel=false
                sg:Merge(mustg)
                local mg_tg=mg+tg
                while #sg<max do
                    local filters={}
                    if #sg>0 then
                        Aimer.DCheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
                    end
                    local cg=mg_tg:Filter(Aimer.DCheckRecursive,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
                    if #cg==0 then break end
                    finish=#sg>=min and #sg<=max and Aimer.DCheckGoal(tp,sg,c,min,f,specialchk,filters)
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
                    Aimer.DCheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
                    sg:KeepAlive()
                    e:SetLabelObject({sg,filters,emt})
                    return true
                else
                    aux.DeleteExtraMaterialGroups(emt)
                    return false
                end
            end
end
function Aimer.DOperation(f,minc,maxc,specialchk)
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
                        local res1=tc:IsCanBeLinkMaterial(c,tp) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
                        local label={formud_eff:GetLabel()}
                        for i=1,#label-1,2 do
                            tc:AssumeProperty(label[i],label[i+1])
                        end
                        local res2=tc:IsCanBeLinkMaterial(c,tp) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
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



--add procedure to persistent traps
function Aimer.AddPersistentProcedure(c,p,f,category,property,hint1,hint2,con,cost,tg,op,anypos,limit,hardlimit,code,stage2)
    --Note: p==0 is check persistent trap controler, p==1 for opponent's, PLAYER_ALL for both player's monsters
    --anypos is check for face-up/any
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(999722,2))
    if category then
        e1:SetCategory(category)
    end
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetRange(LOCATION_SZONE)
    if hardlimit==true then
        e1:SetCountLimit(limit,code)
    else
        e1:SetCountLimit(0+limit)
    end
    e1:SetCode(EVENT_FREE_CHAIN)
    if hint1 or hint2 then
        if hint1==hint2 then
            e1:SetHintTiming(hint1)
        elseif hint1 and not hint2 then
            e1:SetHintTiming(hint1,0)
        elseif hint2 and not hint1 then
            e1:SetHintTiming(0,hint2)
        else
            e1:SetHintTiming(hint1,hint2)
        end
    end
    if property then
        e1:SetProperty(EFFECT_FLAG_CARD_TARGET+property)
    else
        e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    end
    if con then
        e1:SetCondition(con)
    end
    if cost then
        e1:SetCost(cost)
    end
    e1:SetTarget(Aimer.PersistentTarget(tg,p,f))
    e1:SetOperation(op)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetLabelObject(e1)
    e2:SetCondition(Aimer.PersistentTgCon)
    e2:SetOperation(Aimer.PersistentTgOp(anypos,stage2))
    c:RegisterEffect(e2)
end
function Aimer.PersistentFilter(c,p,f,e,tp,tg,eg,ep,ev,re,r,rp)
    return (p==PLAYER_ALL or c:IsControler(p)) and (not f or f(c,e,tp)) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,c,0))
end
function Aimer.PersistentTarget(tg,p,f)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
                local player=nil
                if p==0 then
                    player=tp
                elseif p==1 then
                    player=1-tp
                elseif p==PLAYER_ALL or p==nil then
                    player=PLAYER_ALL
                end
                if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() and Aimer.PersistentFilter(chkc,player,f,e,tp) end
                if chk==0 then return Duel.IsExistingTarget(Aimer.PersistentFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,player,f,e,tp,tg,eg,ep,ev,re,r,rp)
                    and player~=nil end
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
                local g=Duel.SelectTarget(tp,Aimer.PersistentFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,player,f,e,tp)
                if tg then tg(e,tp,eg,ep,ev,re,r,rp,g:GetFirst(),1) end
            end
end
function Aimer.PersistentTgCon(e,tp,eg,ep,ev,re,r,rp)
    return re==e:GetLabelObject()
end
function Aimer.PersistentTgOp(anypos,stage2)
    return function(e,tp,eg,ep,ev,re,r,rp)
            local c=e:GetHandler()
            local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
            if c:IsRelateToEffect(re) and tc and (anypos or tc:IsFaceup()) and tc:IsRelateToEffect(re) then
                c:SetCardTarget(tc)
                c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD)
                if stage2 then
                    stage2(e,tp,eg,ep,ev,re,r,rp,tc)
                end
            else
        end
    end
end
function Aimer.PersistentTargetFilter(e,c)
    return e:GetHandler():IsHasCardTarget(c)
end


-- Function to set up the global check effect
function Aimer.AddAstralShift(c)
    -- Set the astral_shift metatable property for the card
    local mt=Duel.GetMetatable(c:GetCode())
    if not mt then
        mt={}
        Duel.SetMetatable(c:GetCode(),mt)
    end
    mt.astral_shift={id=c:GetCode()}
    -- Effect that handles the Astral Shift
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_MOVE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsLocation(LOCATION_MZONE) and e:GetHandler():GetPreviousSequence()~=e:GetHandler():GetSequence() end)
    e1:SetOperation(Aimer.HandleAstralShift)
    c:RegisterEffect(e1)
   -- Register the continuous effect that triggers on EVENT_ASTRAL_EFFECT_PROC
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_ASTRAL_EFFECT_PROC)
    e2:SetOperation(Aimer.AstralEffectSwapTrigger)
    c:RegisterEffect(e2)
    -- Register chain resolution and trigger the swap
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetOperation(Aimer.AstralEffectSwapOnChainSolved)
    c:RegisterEffect(e3)
end

-- Function to handle the Astral Shift effect
function Aimer.HandleAstralShift(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c or not c:IsFaceup() then return end -- Ensure the handler is valid and face-up
    
    -- Collect all other monsters on the field
    local otherCards={}
    local monsters=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(monsters) do
        if tc~=c then
            table.insert(otherCards,tc)
        end
    end

    -- Function to get the previous sequence of a card in monster zones
    local function GetPrevSequence(card)
        return card:GetPreviousSequence() or card:GetSequence()
    end

    -- Function to check if two ranges overlap
    local function RangeOverlap(start1,end1,start2,end2)
        return not (end1<start2 or end2<start1)
    end

    -- Function to check if the card crossed paths with another card
    local function PathsIntersected(card, otherCardsList)
        local prevSeq=GetPrevSequence(card)
        local newSeq=card:GetSequence()
        -- Normalize the sequences to always check from a lower to a higher index
        local cStart,cEnd=math.min(prevSeq,newSeq),math.max(prevSeq,newSeq)
        local intersectedCards={}
        for _, tc in ipairs(otherCardsList) do
            local tcCurrentSeq=tc:GetSequence()
            local tcStart,tcEnd=tcCurrentSeq,tcCurrentSeq
            -- Check if the paths overlap
            if RangeOverlap(cStart,cEnd,tcStart,tcEnd) then
                -- Check if the card has the astral_shift metatable property
                local mt = Duel.GetMetatable(tc:GetCode())
                if mt and mt.astral_shift and tc:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==0 then
                    table.insert(intersectedCards,tc)
                end
            end
        end
        return intersectedCards
    end

    -- Check if the current card crossed paths with any other card
    local intersectedCards=PathsIntersected(c,otherCards)

    if #intersectedCards>0 then
        -- Get the moved card's sequence (newSeq)
        local newSeq=c:GetSequence()
        -- Apply the overlay logic: place the moved monster on top of the intersected stationary monster
        for _, tc in ipairs(intersectedCards) do
            -- Overlay the two monsters
            Duel.Overlay(c,Group.FromCards(tc)) -- Place the moved monster (c) on top of the intersected monster (tc)
            if c:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==0 then c:RegisterFlagEffect(REGISTER_FLAG_ASTRAL_STATE,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET,0,0) end
            --[[Duel.RaiseEvent(c,EVENT_ASTRAL_SHIFT,e,0,tp,tp,0)--]]
            --[[Duel.RaiseEvent(tc,EVENT_ASTRAL_SHIFT,e,0,tp,tp,0)--]]
        end
        Duel.RaiseEvent(c,EVENT_ASTRAL_SHIFT,e,0,tp,tp,0)
         -- Check for cards with "EFFECT_EXTRA_ASTRAL" in all locations
        local extraAstralCards = Duel.GetMatchingGroup(Aimer.FilterExtraAstralCards,tp,LOCATION_ALL,0,nil)
        -- Prompt the player to select one card from the group
        if #extraAstralCards>0 and Duel.SelectYesNo(tp,4500) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
            local selectedCard=extraAstralCards:Select(tp,1,1,nil):GetFirst()
            -- Add the selected card to the overlay group
            Duel.Hint(HINT_CARD,0,selectedCard:GetCode())
            Duel.Overlay(c,Group.FromCards(selectedCard))
            --[[Duel.RaiseEvent(selectedCard,EVENT_ASTRAL_SHIFT,e,0,tp,tp,0)--]]
            Aimer.ApplyFlagToAllWithSameName(selectedCard,tp)
        end
    end
end

-- Function to filter cards with EFFECT_EXTRA_ASTRAL and no flag effects with their own IDs
function Aimer.FilterExtraAstralCards(tc)
    return tc:IsHasEffect(EFFECT_EXTRA_ASTRAL) and tc:GetFlagEffect(tc:GetCode())==0
end

-- Function to get all cards with the same name as the selected card
function Aimer.GetCardsWithSameName(card, tp)
    return Duel.GetMatchingGroup(function(tc) return tc:GetCode()==card:GetCode() end,tp,LOCATION_ALL,0,nil)
end

-- Function to apply a flag effect to all cards with the same name as the selected card
function Aimer.ApplyFlagToAllWithSameName(selectedCard, tp)
    local cardsWithSameName = Aimer.GetCardsWithSameName(selectedCard,tp)
    cardsWithSameName:ForEach(function(tc)
        -- Register the flag effect directly on each card
        tc:RegisterFlagEffect(selectedCard:GetCode(),RESET_PHASE+PHASE_END,0,1)
    end)
end




-- Effect to trigger AstralEffectSwapProc after chain resolution
function Aimer.AstralEffectSwapTrigger(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Set a flag to indicate AstralEffectSwapProc should trigger after chain resolution
    c:RegisterFlagEffect(c:GetCode(),RESET_CHAIN,0,1)  -- Use a unique flag ID
end

-- Effect to actually execute AstralEffectSwapProc after the chain has resolved
function Aimer.AstralEffectSwapOnChainSolved(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Check if the flag is set (AstralEffectSwapProc was triggered during a resolving chain)
    if c:GetFlagEffect(c:GetCode())>0 then
        -- Clear the flag
        c:ResetFlagEffect(c:GetCode())
        -- Now execute the AstralEffectSwapProc
        Aimer.AstralEffectSwapProc(e,tp,eg,ep,ev,re,r,rp)
    end
end




--Overlay swapping effect
function Aimer.AstralEffectSwapProc(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local pos=c:GetPosition()
    local tp=e:GetHandlerPlayer()
    local selfseq=c:GetSequence()
    local og=c:GetOverlayGroup()
    if og:GetCount()==0 then return end
    -- Get bottom material (the card that was on the bottom of the overlay stack)
    local BottomMaterial=og:GetMinGroup(Card.GetSequence):GetFirst()
    -- Check if both BottomMaterial and the current monster (c) have the Astral flag
    if c:GetFlagEffect(ASTRAL_FLAG)>0 and BottomMaterial:GetFlagEffect(ASTRAL_FLAG)>0 then
        return  -- Don't proceed if both have the flag
    end
    -- Define temporary holder for the materials and (c)
    local locs=LOCATION_EXTRA|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_HAND
    local TemporaryMaterialHolder=Duel.GetFieldGroup(tp,locs,locs):GetFirst()
    -- Attach the materials and then the handler to the temporary holder
    Duel.Overlay(TemporaryMaterialHolder,og)
    Duel.Overlay(TemporaryMaterialHolder,c)
    -- Move the bottom material to the field
    Duel.MoveToField(BottomMaterial,tp,tp,LOCATION_MZONE,pos,true,1<<selfseq)
    -- Define new group of materials that will be attached to BottomMaterial
    local NewMaterials=og:Clone()
    NewMaterials:RemoveCard(BottomMaterial)
    -- Convert group to table
    local materialsTable={}
    local tc=NewMaterials:GetFirst()
    while tc do
        table.insert(materialsTable,tc)  -- Add each card to the table except c
        tc=NewMaterials:GetNext()
    end
    -- Attach all materials except the card handler
    for i=#materialsTable,1,-1 do
        Duel.Overlay(BottomMaterial,materialsTable[i])  -- Overlay each card from last to first
    end
    -- Finally, overlay the handler (c) last
    Duel.Overlay(BottomMaterial,c)
    -- Place Effect Condition Flag first on the new Top Material
    if BottomMaterial:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==0 then BottomMaterial:RegisterFlagEffect(REGISTER_FLAG_ASTRAL_STATE,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET,0,0) end
    -- Set the Astral flag effect on the current handler (c)
    if c:GetFlagEffect(ASTRAL_FLAG)==0 then c:RegisterFlagEffect(ASTRAL_FLAG,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET,0,1) end
    -- Check if both BottomMaterial and the current monster (c) have the Astral flag
    if c:GetFlagEffect(ASTRAL_FLAG)>0 and BottomMaterial:GetFlagEffect(ASTRAL_FLAG)>0 then
        -- Register an End Phase effect to send the handler and materials to the bottom of the deck
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetCode(EVENT_ADJUST)
        e1:SetCountLimit(1)
        e1:SetCondition(Aimer.SendToDeckCondition)
        e1:SetOperation(Aimer.SendToDeckOperation)
        e1:SetLabelObject(BottomMaterial)
        Duel.RegisterEffect(e1,tp)
    end
end

--Condition for sending to the deck during the End Phase
function Aimer.SendToDeckCondition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetLabelObject():IsLocation(LOCATION_MZONE)
end

--Operation for sending the handler and materials to the bottom of the deck during the End Phase
function Aimer.SendToDeckOperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    if not c:IsLocation(LOCATION_MZONE) then return end
    local og=c:GetOverlayGroup()
     -- Define temporary holder for the materials and (c)
    local locs=LOCATION_EXTRA|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_HAND
    local tog=Duel.GetFieldGroup(tp,locs,locs):GetFirst()
    if og:GetCount()==0 then return end
    -- Attach all overlay materials to the temporary holder
    if tog then
        Duel.Overlay(tog,og)
    end
    -- Now send the handler (c) to the bottom of the deck
    Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_RULE)
    Duel.RaiseEvent(c,EVENT_ASTRAL_SHIFT_END,e,REASON_EFFECT,tp,tp,0)
    -- Collect all overlay materials into a table, in the correct order (top to bottom)
    local materialsTable={}
    for tc in aux.Next(og) do
        table.insert(materialsTable,tc)
    end
    -- Send each material to the bottom of the deck in order (top to bottom)
    for i=#materialsTable,1,-1 do
        local mat=materialsTable[i]
        Duel.SendtoDeck(mat,nil,SEQ_DECKBOTTOM,REASON_RULE)
    end
end



--Shio to Suna Ritual Proc
function Aimer.ShiotoSunaAddProcedure(c,id,s)
    local function flfilter(c)
        return c:IsFaceup() and c:GetLeftScale()>=0
    end
    local function spcon(e,c,tp)
        if c==nil then return true end
        if (e:GetHandler():IsLocation(LOCATION_EXTRA) and e:GetHandler():IsFacedown()) then return false end
        local lv=e:GetHandler():GetLevel()
        local tp=e:GetHandlerPlayer()
        local rg=Duel.GetMatchingGroup(flfilter,tp,LOCATION_PZONE,0,nil)
        local emzcheck=((not e:GetHandler():IsLocation(LOCATION_EXTRA) and aux.ChkfMMZ(1)(sg,e,tp,mg)) or (e:GetHandler():IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0))
        if #rg==1 then return rg:GetFirst():GetLeftScale()>=lv and emzcheck end
        return aux.SelectUnselectGroup(rg,e,tp,1,2,function(sg,e,tp,mg) return sg:GetSum(Card.GetLeftScale)>=lv and emzcheck end,0)
    end
    local function sptg(e,tp,eg,ep,ev,re,r,rp,c)
        local c=e:GetHandler()
        local lv=c:GetLevel()
        local rg=Duel.GetMatchingGroup(flfilter,tp,LOCATION_PZONE,0,nil)
        local emzcheck=((not e:GetHandler():IsLocation(LOCATION_EXTRA) and aux.ChkfMMZ(1)(sg,e,tp,mg)) or (e:GetHandler():IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0))
        local g=aux.SelectUnselectGroup(rg,e,tp,1,2,function(sg,e,tp,mg) return sg:GetSum(Card.GetLeftScale)>=lv and emzcheck end,1,tp,HINTMSG_ADJUST,nil,nil,true)
        if #g>0 then
            local total_scale=g:GetSum(Card.GetLeftScale)
            if total_scale<lv then return false end
            g:KeepAlive()
            e:SetLabelObject(g)
            return true
        end
        return false
    end
        local function spop(e,tp,eg,ep,ev,re,r,rp,c)
        local c=e:GetHandler()
        local g=e:GetLabelObject()
        if not g then return end
        local lv=c:GetLevel()
        local total_reduction=lv
        if #g==1 then
            local tc=g:GetFirst()
            local max_reduce=math.min(tc:GetLeftScale(),total_reduction)
            local reduce=max_reduce
            if reduce>0 then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_LSCALE)
                e1:SetValue(-reduce)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_UPDATE_RSCALE)
                tc:RegisterEffect(e2)
            end
            c:SetMaterial(tc)
        else
            local remaining_reduction=total_reduction
            -- Filter the cards in g for the one in the left pendulum zone
            local left_tc=g:Filter(function(c) return c:IsLocation(LOCATION_PZONE) and c:GetSequence()==0 end,nil)
            local right_tc=g:Filter(function(c) return c:IsLocation(LOCATION_PZONE) and c:GetSequence()==4 end,nil)
            left_tc=left_tc:GetFirst()
            right_tc=right_tc:GetFirst()
            -- Get the first card that matches
            if left_tc then
                local left_max_reduce=math.min(left_tc:GetLeftScale(),remaining_reduction)
                local check_max_reduce=math.min(right_tc:GetLeftScale()+1,math.max(0,remaining_reduction-right_tc:GetLeftScale()))
                local left_choices={}
                for i=check_max_reduce,left_max_reduce do table.insert(left_choices,i) end
                Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
                local left_reduce=Duel.AnnounceNumber(tp,table.unpack(left_choices))
                if left_reduce>0 then
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_UPDATE_LSCALE)
                    e1:SetValue(-left_reduce)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    left_tc:RegisterEffect(e1)
                    local e2=e1:Clone()
                    e2:SetCode(EFFECT_UPDATE_RSCALE)
                    left_tc:RegisterEffect(e2)
                end
                remaining_reduction=remaining_reduction-left_reduce
            end
            if right_tc and remaining_reduction>0 then
                local right_max_reduce=math.min(right_tc:GetLeftScale(),remaining_reduction)
                if right_max_reduce>0 then
                    local e2=Effect.CreateEffect(c)
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_UPDATE_LSCALE)
                    e2:SetValue(-right_max_reduce)
                    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                    right_tc:RegisterEffect(e2)
                    local e3=e2:Clone()
                    e3:SetCode(EFFECT_UPDATE_RSCALE)
                    right_tc:RegisterEffect(e3)
                end
            end
            --Set materials for both left and right pendulum zones if applicable
            local mg=Group.CreateGroup()
            if left_tc then mg:AddCard(left_tc) end
            if right_tc then mg:AddCard(right_tc) end
            c:SetMaterial(mg)
        end
        g:DeleteGroup()
    end
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(4501)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND+LOCATION_EXTRA)
    e1:SetCountLimit(1,{id,10})
    e1:SetCondition(spcon)
    e1:SetTarget(sptg)
    e1:SetOperation(spop)
    e1:SetValue(SUMMON_TYPE_RITUAL)
    c:RegisterEffect(e1)
end



--Novalxon Link 2 Proc
function Aimer.AddExtraLinkProcedure(c,f,min,max,specialchk,desc)
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
    e1:SetCondition(Aimer.ExCondition(f,min,max,specialchk))
    e1:SetTarget(Aimer.ExTarget(f,min,max,specialchk))
    e1:SetOperation(Aimer.ExOperation(f,min,max,specialchk))
    e1:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(e1)
end
function Aimer.ExConditionFilter(c,f,lc,tp)
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
function Aimer.ExGetLinkCount(c)
    if c:IsLinkMonster() and c:GetLink()>1 then
        return 1+0x10000*c:GetLink()
    else return 1 end
end
function Aimer.ExCheckRecursive(c,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
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
    local res=Aimer.ExCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
        or (#sg<maxc and mg:IsExists(Aimer.ExCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)}))
    sg:RemoveCard(c)
    return res
end
function Aimer.ExCheckRecursive2(c,tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
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
            local res=secondg:IsExists(Aimer.ExCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        else
            local res=Aimer.ExCheckGoal(tp,sg,lc,minc,f,specialchk,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        end
    end
    local res=Aimer.ExCheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
    sg:RemoveCard(c)
    return res
end
function Aimer.ExCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
    for _,filt in ipairs(filt) do
        if not sg:IsExists(filt[2],1,nil,filt[3],tp,sg,Group.CreateGroup(),lc,filt[1],1) then
            return false
        end
    end
    -- Check if any card in the selected materials has the Astral State flag
    local has_astral_state=sg:IsExists(function(c) return c:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)>0 end,1,nil)
    -- If so, override the required link material count
    local required_count=has_astral_state and 1 or lc:GetLink()
    local min_required=has_astral_state and 1 or minc
    return #sg>=min_required and sg:CheckWithSumEqual(Aimer.ExGetLinkCount,required_count,#sg,#sg)
        and (not specialchk or specialchk(sg,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end

function Aimer.ExCondition(f,minc,maxc,specialchk)
    return  function(e,c,must,g,min,max)
                if c==nil then return true end
                if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
                local tp=c:GetControler()
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
                end
                local mg=g:Filter(Aimer.ExConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                if mustg:IsExists(aux.NOT(Aimer.ExConditionFilter),1,nil,f,c,tp) or #mustg>max then return false end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.ExConditionFilter,nil,f,c,tp)
                local mg_tg=mg+tg
                local res=mg_tg:Includes(mustg) and #mustg<=max
                if res then
                    if #mustg==max then
                        local sg=Group.CreateGroup()
                        res=mustg:IsExists(Aimer.ExCheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    elseif #mustg<max then
                        local sg=mustg
                        res=mg_tg:IsExists(Aimer.ExCheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    end
                end
                aux.DeleteExtraMaterialGroups(emt)
                return res
            end
end
function Aimer.ExTarget(f,minc,maxc,specialchk)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
                end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                local mg=g:Filter(Aimer.ExConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.ExConditionFilter,nil,f,c,tp)
                local sg=Group.CreateGroup()
                local finish=false
                local cancel=false
                sg:Merge(mustg)
                local mg_tg=mg+tg
                while #sg<max do
                    local filters={}
                    if #sg>0 then
                        Aimer.ExCheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
                    end
                    local cg=mg_tg:Filter(Aimer.ExCheckRecursive,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
                    if #cg==0 then break end
                    finish=#sg>=min and #sg<=max and Aimer.ExCheckGoal(tp,sg,c,min,f,specialchk,filters)
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
function Aimer.ExOperation(f,minc,maxc,specialchk)
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

--Kyoshin Link Procedure
function Aimer.KyoshinLinkProcedure(c,f,min,max,specialchk,desc,spcon)
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
    e1:SetCondition(Aimer.KyoshinLinkCondition(f,min,max,specialchk,spcon))
    e1:SetTarget(Aimer.KyoshinLinkTarget(f,min,max,specialchk))
    e1:SetOperation(Aimer.KyoshinLinkOperation(f,min,max,specialchk))
    e1:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(e1)
end
function Aimer.KyoshinLinkConditionFilter(c,f,lc,tp)
    local res1=c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
    local res2=false
    local formud_eff=c:IsHasEffect(EFFECT_FORMUD_SKIPPER)
    if formud_eff then
        local label={formud_eff:GetLabel()}
        for i=1,#label-1,2 do
            c:AssumeProperty(label[i],label[i+1])
        end
        res2=c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
    end
    return res1 or res2
end
function Aimer.KyoshinLinkGetLinkCount(c)
    if c:IsLinkMonster() and c:GetLink()>1 then
        return 1+0x10000*c:GetLink()
    else return 1 end
end
function Aimer.KyoshinLinkCheckRecursive(c,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
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
        local res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
        if not res then
            sg:RemoveCard(c)
            return false
        end
    end
    local res=Aimer.KyoshinLinkCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
        or (#sg<maxc and mg:IsExists(Aimer.KyoshinLinkCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)}))
    sg:RemoveCard(c)
    return res
end
function Aimer.KyoshinLinkCheckRecursive2(c,tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
    if #sg>maxc then return false end
    sg:AddCard(c)
    for _,filt in ipairs(filt) do
        if not filt[2](c,filt[3],tp,sg,mg,lc,filt[1],1) then
            sg:RemoveCard(c)
            return false
        end
    end
    if not og:IsContains(c) then
        local res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
        if not res then
            sg:RemoveCard(c)
            return false
        end
    end
    if #(sg2-sg)==0 then
        if secondg and #secondg>0 then
            local res=secondg:IsExists(Aimer.KyoshinLinkCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        else
            local res=Aimer.KyoshinLinkCheckGoal(tp,sg,lc,minc,f,specialchk,{table.unpack(filt)})
            sg:RemoveCard(c)
            return res
        end
    end
    local res=Aimer.KyoshinLinkCheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
    sg:RemoveCard(c)
    return res
end
function Aimer.KyoshinLinkCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
    for _,filt in ipairs(filt) do
        if not sg:IsExists(filt[2],1,nil,filt[3],tp,sg,Group.CreateGroup(),lc,filt[1],1) then
            return false
        end
    end
    return #sg>=minc and sg:CheckWithSumEqual(Aimer.KyoshinLinkGetLinkCount,lc:GetLink(),#sg,#sg)
        and (not specialchk or specialchk(sg,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end
function Aimer.KyoshinLinkCondition(f,minc,maxc,specialchk,spcon)
    return  function(e,c,must,g,min,max)
                if c==nil then return true end
                if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
                local tp=c:GetControler()
                if spcon and not spcon(e,e,tp,SUMMON_TYPE_LINK) then
                    return false
                end
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE|LOCATION_STZONE,0,nil)
                end
                local mg=g:Filter(Aimer.KyoshinLinkConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                if mustg:IsExists(aux.NOT(Aimer.KyoshinLinkConditionFilter),1,nil,f,c,tp) or #mustg>max then return false end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.KyoshinLinkConditionFilter,nil,f,c,tp)
                local mg_tg=mg+tg
                local res=mg_tg:Includes(mustg) and #mustg<=max
                if res then
                    if #mustg==max then
                        local sg=Group.CreateGroup()
                        res=mustg:IsExists(Aimer.KyoshinLinkCheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    elseif #mustg<max then
                        local sg=mustg
                        res=mg_tg:IsExists(Aimer.KyoshinLinkCheckRecursive,1,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt)
                    end
                end
                aux.DeleteExtraMaterialGroups(emt)
                return res
            end
end
function Aimer.KyoshinLinkTarget(f,minc,maxc,specialchk)
    return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
                if not g then
                    g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE|LOCATION_STZONE,0,nil)
                end
                if min and min < minc then return false end
                if max and max > maxc then return false end
                min = min or minc
                max = max or maxc
                local mg=g:Filter(Aimer.KyoshinLinkConditionFilter,nil,f,c,tp)
                local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
                if must then mustg:Merge(must) end
                local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
                tg:Match(Aimer.KyoshinLinkConditionFilter,nil,f,c,tp)
                local sg=Group.CreateGroup()
                local finish=false
                local cancel=false
                sg:Merge(mustg)
                local mg_tg=mg+tg
                while #sg<max do
                    local filters={}
                    if #sg>0 then
                        Aimer.KyoshinLinkCheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
                    end
                    local cg=mg_tg:Filter(Aimer.KyoshinLinkCheckRecursive,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
                    if #cg==0 then break end
                    finish=#sg>=min and #sg<=max and Aimer.KyoshinLinkCheckGoal(tp,sg,c,min,f,specialchk,filters)
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
                    Aimer.KyoshinLinkCheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
                    sg:KeepAlive()
                    e:SetLabelObject({sg,filters,emt})
                    return true
                else
                    aux.DeleteExtraMaterialGroups(emt)
                    return false
                end
            end
end
function Aimer.KyoshinLinkOperation(f,minc,maxc,specialchk)
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
                    local formud_eff=tc:IsHasEffect(EFFECT_FORMUD_SKIPPER)
                    if formud_eff then
                        local res1=tc:IsCanBeLinkMaterial(c,tp) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
                        local label={formud_eff:GetLabel()}
                        for i=1,#label-1,2 do
                            tc:AssumeProperty(label[i],label[i+1])
                        end
                        local res2=tc:IsCanBeLinkMaterial(c,tp) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
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
