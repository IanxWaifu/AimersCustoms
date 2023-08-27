--Scripted by IanxWaifu
--Kro'akoth, Necrotic Severer
local s,id=GetID()

local function CountAttributes(att)
    local count = 0
    while att > 0 do
        count = count + (att & 1)
        att = att >> 1
    end
    return count
end

local chosenAttribute = 0

function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	Fusion.AddProcMixRep(c,true,true,s.mfilter2,1,99,s.mfilter1)
    --Special Summon 
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.thcost)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    -- Gain Attribute
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.thcon)
    e4:SetOperation(s.attrOperation)
    c:RegisterEffect(e4)
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_MATERIAL_CHECK)
    e6:SetValue(s.valcheck)
    e6:SetLabelObject(e4)
    c:RegisterEffect(e6)
    --Mill from deck
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_DECKDES)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetCountLimit(1,{id,1})
    e7:SetRange(LOCATION_MZONE)
    e7:SetTarget(s.tgtg)
    e7:SetOperation(s.tgop)
    c:RegisterEffect(e7)
    --destroy
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,2))
    e8:SetCategory(CATEGORY_DESTROY)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e8:SetCode(EVENT_BATTLE_CONFIRM)
    e8:SetCondition(s.descon)
    e8:SetTarget(s.destg)
    e8:SetOperation(s.desop)
    c:RegisterEffect(e8)
end

s.listed_series={0x29f}
s.material={999415}
s.material_setcode={0x129f}

function s.mfilter1(c)
	return c:IsCode(999415)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_WYRM,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_EARTH,fc,sumtype,tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
    
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
    
function s.thfilter(c)
    return c:IsSetCard(0x29f) and c:IsMonster() and c:IsAbleToHand()
end
    
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
    
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,g)
    end
end




function s.tgfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_FUSION)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
    local ct=g:GetClassCount(Card.GetCode)
    if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
    Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,Duel.GetDecktopGroup(tp,ct),ct,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
    local ct=g:GetClassCount(Card.GetCode)
    Duel.DiscardDeck(tp,ct,REASON_EFFECT)
    Duel.BreakEffect()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(function(e,c) return ct end)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end













function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local att = c:GetAttribute()
    local bc=c:GetBattleTarget()
    local att = c:GetAttribute()
    local sharedAttribute = att & bc:GetAttribute() ~= 0
    local attCount = 0
    while att > 0 do
        if att & 0x1 ~= 0 then
            attCount = attCount + 1
        end
        att = att >> 1
    end
    return attCount > 1 and c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and sharedAttribute
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bc=e:GetHandler():GetBattleTarget()
    Duel.SetTargetPlayer(1-tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 then
    -- Prompt the player to select an attribute to lose
        local att_to_lose = Duel.AnnounceAttribute(tp, 1, c:GetAttribute())
        c:ResetFlagEffect(id) -- Reset the flag before setting a new one
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1, att_to_lose)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(att_to_lose)
        c:RegisterEffect(e1)
    end
end





function s.attrOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local att = e:GetLabel()
    if att > 0 then
        local e5 = Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e5:SetRange(LOCATION_MZONE)
        e5:SetCode(EFFECT_ADD_ATTRIBUTE)
        e5:SetValue(att)
        e5:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e5)
    end
end
function s.valcheck(e, c)
    local att = 0
    local g = c:GetMaterial()
    for tc in aux.Next(g) do
        att = bit.bor(att, tc:GetAttribute())
    end
    e:GetLabelObject():SetLabel(att)
end
