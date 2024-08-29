--Scripted by IanxWaifu
--Deathrall Nihilazanthis
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials
	Fusion.AddProcMix(c,true,true,s.mfilter1,aux.FilterBoolFunctionEx(Card.IsLocation,LOCATION_MZONE))
	--Cannot be used as Fusion Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Gain Race
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.rccon)
    e2:SetOperation(s.rcop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_MATERIAL_CHECK)
    e3:SetValue(s.valcheck)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
    --multi attack
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_MATERIAL_CHECK)
    e5:SetValue(s.valcheck2)
    e5:SetLabelObject(e4)
    c:RegisterEffect(e5)
    --extra summon
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e6:SetOperation(s.sumop)
    c:RegisterEffect(e6)
    --Remove Attacking
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,2))
    e7:SetCategory(CATEGORY_REMOVE)
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e7:SetCode(EVENT_BATTLE_START)
    e7:SetTarget(s.tgtg)
    e7:SetOperation(s.tgop)
    c:RegisterEffect(e7)
    --Target and Des
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,3))
    e8:SetCategory(CATEGORY_DESTROY)
    e8:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e8:SetProperty(EFFECT_FLAG_DELAY)
    e8:SetCode(EVENT_LEAVE_FIELD)
    e8:SetCountLimit(1,id)
    e8:SetTarget(s.destg)
    e8:SetOperation(s.desop)
    c:RegisterEffect(e8)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end

function s.mfilter1(c)
	return c:IsSetCard(SET_DEATHRALL) or c:IsSetCard(SET_LEGION_TOKEN)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsLocation(LOCATION_MZONE)
end

function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=e:GetLabel()
    if rc>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_ADD_RACE)
        e1:SetValue(rc)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

function s.valcheck(e,c)
    local rc=0
    local g=c:GetMaterial()
    for tc in aux.Next(g) do
        rc=bit.bor(rc,tc:GetRace())
    end
    e:GetLabelObject():SetLabel(rc)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local mat=e:GetLabel()
    if mat>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(mat)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end


function s.valcheck2(e,c)
    local count=0
    local g=c:GetMaterial()
    local countedTypes={}
    
    for tc in aux.Next(g) do
        local race=tc:GetRace()
        -- Check if the race has been counted already
        if not countedTypes[race] then
            countedTypes[race]=true
            count = count + 1  -- Increment count for each unique race
        end
    end
    
    -- Set the count as the label on the label object
    e:GetLabelObject():SetLabel(count)
end


-- Opponent's Battling Monster
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    
    if chk==0 then
        if not tc or tc:IsControler(tp) or not tc:IsAbleToGrave(tp) then
            return false
        end
        -- Ensure at least one race of the handler matches the opponent's monster's race
        local handlerRaces = c:GetRace()
        local targetRaces = tc:GetRace()
        if bit.band(handlerRaces, targetRaces) ~= 0 then
            return true
        end
        return false
    end
    
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, tc, 1, 0, 0)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tc = e:GetHandler():GetBattleTarget()
    if tc and tc:IsRelateToBattle() then
        Duel.SendtoGrave(tc, REASON_EFFECT)
    end
end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
