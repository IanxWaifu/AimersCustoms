--Scripted by IanxWaifu
--Crux of the Necromancer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,999415),matfilter=s.matfil,extrafil=s.extrafilter,extraop=s.extraop})
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    --Set to field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(function(_,tp) return Duel.GetFlagEffect(tp,id)>0 end)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
    --Check for Fusion Monsters sent to the GY
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_TO_GRAVE)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)
end

s.listed_series={0x29f}
s.listed_names={id,CARD_ZORGA}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    for tc in eg:Iter() do
        if (tc:GetOriginalLevel()>=8 or tc:GetOriginalRank()>=8) and tc:IsPreviousLocation(LOCATION_MZONE) then
            Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
        end
    end
end

--Material Check
function s.matfil(c,e,tp,chk)
    return (c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial()) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove())
end
function s.cfilter(c,tp)
    return (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)) or 
           (c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsCanBeFusionMaterial())
end

function s.filter(c, tp)
    -- To check opponent's monster zone and graveyard
    local oppAttributes = Aimer.GetUniqueAttributesByLocation(tp, LOCATION_MZONE + LOCATION_GRAVE, LOCATION_MZONE, 
        function(c) return c:IsFaceup() end, 
        function(c) return c:IsFaceup() end )
    
    -- Check if the card is in your opponent's graveyard and has at least one attribute you do not control
    if c:IsControler(1 - tp) and c:IsAbleToRemove() and c:IsFaceup() then
        local att = c:GetAttribute()
        for _, uniqueAtt in ipairs(oppAttributes) do
            if att & uniqueAtt > 0 then
                return true
            end
        end
    end

    return false
end


--Check for My GY and Fusion Monster
function s.checkmat(tp,sg,fc)
    return fc:IsType(TYPE_FUSION) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
function s.fcheck(tp, sg, fc)
    return sg:FilterCount(function(c)
        return c:IsControler(1 - tp) and c:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) end, nil) <= 1
end


function s.extrafilter(e,tp,mg)
    local eg1=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,nil,tp)
    local eg2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil,tp)
    eg1:Merge(eg2)
    if eg1 and #eg1>0 then
        return eg1,s.fcheck
    end
    return Group.CreateGroup(), s.fcheck -- Return an empty group if no valid cards were found
end



--Remove Materials
function s.extraop(e,tc,tp,sg)
    local rg1=sg:Filter(function(c)
        return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) end, nil)
    local rg2=sg:Filter(function(c) return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) end, nil)
    -- Merge the two groups into one
    rg1:Merge(rg2)
    if #rg1>0 then
        Duel.Remove(rg1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        sg:Sub(rg1)
    end
end

function s.setfilter(c,tp)
    return c:IsLocation(LOCATION_GRAVE)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg and eg:IsExists(s.setfilter,1,nil,tp)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return e:GetHandler():IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
   Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   if c:IsRelateToEffect(e) and c:IsSSetable() then
      Duel.SSet(tp,c)
        --Banish it if it leaves the field
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
   end
end