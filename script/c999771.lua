--Azhimaou - Empusthirix
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    Fusion.AddProcMixN(c,true,true,s.ffilter,3)
    c:EnableReviveLimit()
    --Must First be Fus/Special by card effect
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)
    --Mill 3 cards
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)
    --synchro custom
    local e2=Effect.CreateEffect(c)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(30765615)
    c:RegisterEffect(e2)
    --Set end phase
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.sumcon)
    e3:SetOperation(s.sumop)
    c:RegisterEffect(e3)
    -- Global check for "SET_AZHIMAOU" activation this turn
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_SOLVED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)   
    end)
end

local ActivatedAzhimaouCards={}

-- Function to check and add "SET_AZHIMAOU" card to the table for the player
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(SET_AZHIMAOU) and rp==tp then
        local CardID=rc:GetCode()
        -- Check if CardID is already in the table
        if not s.IsCardInIDTable(CardID) then
            table.insert(ActivatedAzhimaouCards,CardID)
        end
    end
end

-- Utility function to check if a card ID is in the table
function s.IsCardInIDTable(CardID)
    for _,id in ipairs(ActivatedAzhimaouCards) do
        if id==CardID then
            return true
        end
    end
    return false
end

-- Function to clear the table at the end of the turn
function s.clear_table(e,tp,eg,ep,ev,re,r,rp)
    ActivatedAzhimaouCards={}
end

function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
    return c:IsSetCard(SET_AZHIMAOU,fc,0,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,0,tp),fc,0,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
    return c:IsSummonCode(fc,0,tp,code) and not c:IsHasEffect(511002961)
end

function s.splimit(e,se,sp,st)
    return (not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)) or se:IsHasType(EFFECT_TYPE_ACTIONS) and se:GetHandler():IsSetCard(SET_AZHIMAOU)
end

--[[--Mill 3
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.DiscardDeck(tp,3,REASON_EFFECT)
end--]]

--Send 1
function s.tgfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

--Apply Eff
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)~=0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCountLimit(1,{id,2})
    e1:SetOperation(s.setop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    --[[Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)--]]
end

-- Filter function to check if the card can be Set and has not been used this turn
function s.setfilter(c)
    return c:IsSetCard(SET_AZHIMAOU) and (c:IsQuickPlaySpell() or c:IsNormalTrap()) and c:IsSSetable() and not s.IsCardInIDTable(c:GetCode())
end

-- Set up to 2 cards
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    --[[Duel.ResetFlagEffect(tp,id)--]]
    local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
    if #g==0 then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
        Duel.Hint(HINT_CARD,0,id)
        local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SET)
        if #sg>0 then
            Duel.SSet(tp,sg)
            for tc in aux.Next(sg) do
                --Return it to deck if it leaves the field
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetDescription(3301)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
                e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
                e1:SetValue(LOCATION_DECKBOT)
                tc:RegisterEffect(e1)
            end
        end
        s.clear_table(e,tp,eg,ep,ev,re,r,rp)
    end
end