--Scripted by IanxWaifu
--Kijin, Höshako no Kyuseishu
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
    	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_RITUAL),7,2)
    c:EnableReviveLimit()
    -- Unaffected by opponent's card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)
    -- Special Summon Xyz Material and negate effect
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- Target and send to GY, set Continuous Spell/Trap from Deck or GY to field
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(1000000,1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.tgcost)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end

s.ritual_material_required=1

--[[-- Filter for Xyz Summon
function s.ovfilter(c)
    return c:IsRitualMonster() and c:IsType(TYPE_MONSTER)
end--]]

-- Immune to Opponent's Card Effects
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetHandler():IsType(TYPE_CONTINUOUS) 
    	and te:GetHandler():IsSetCard(0x12EA) and (te:GetHandler():IsPreviousLocation(LOCATION_REMOVED) or te:GetHandler():IsPreviousLocation(LOCATION_GRAVE))
end


--Check if the activation can be negated
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    return  rp~=tp and ((re:IsActiveType(TYPE_MONSTER) and (re:GetHandler():IsLocation(LOCATION_HAND) or re:GetHandler():IsLocation(LOCATION_GRAVE))) or g and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE))
        and Duel.IsChainDisablable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end

--Select an Xyz Material to Special Summon and negate the effect
function s.xyzcheck(c,e,tp)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
        return e:GetHandler():GetOverlayGroup():IsExists(s.xyzcheck,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local matg=c:GetOverlayGroup()
    local tg=matg:FilterSelect(tp,s.xyzcheck,1,1,nil,e,tp)
    local tc=tg:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
        Duel.NegateEffect(ev)
    end
end

--Send to GY
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.tgtg (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.setfilter(c,tp,code)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and not c:IsCode(code) and c:IsSSetable() and c:IsSetCard(0x12EA)
end

-- Add this function to the card's existing functions table
function s.tgop (e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        -- Send the targeted card to the GY
        Duel.SendtoGrave(tc,REASON_EFFECT)
        -- Check if the sent card was a Continuous Spell/Trap Card
        if not tc:IsType(TYPE_CONTINUOUS) and tc:IsSetCard(0x12EA) then return end
        -- Set 1 Continuous Spell/Trap Card from your Deck or GY to your field, but with a different name
        local code=tc:GetCode()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local tg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,code)
        if tg then
            Duel.SSet(tp,tg)
            Duel.ConfirmCards(1-tp,tg)
        end
    end
end