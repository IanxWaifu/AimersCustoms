--Scripted by IanxWaifu
--Crux of the Necromancer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,999415),matfilter=s.matfil,extrafil=s.extrafilter,extraop=s.extraop})
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
end

s.listed_series={0x29f}
s.listed_names={id,CARD_ZORGA}


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