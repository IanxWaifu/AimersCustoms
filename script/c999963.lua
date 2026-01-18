--Kyoshin - Shinten no Amakagami
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.ffilter,3)
    local rparams={filter=aux.FilterBoolFunction(s.rspfilter),lvtype=RITPROC_GREATER,nil,nil,matfilter=s.matfilter,location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,forcedselection=s.ritcheck,nil}
    --Change effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.chcon)
    e1:SetTarget(s.chtg(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e1:SetOperation(s.chop(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e1)
    --Shuffle any number of Ritual Cards from your hand into the Deck, then draw the same number of cards
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
    --Search
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}
s.ritual_material_required=3

--Ritual Params
function s.rspfilter(c)
    return c:IsSetCard(SET_KYOSHIN) or c:IsLevel(7) 
end

function s.matfilter(c,e,tp)
    return c==e:GetHandler()
end

function s.ritcheck(e,tp,g,sc)
    local c=e:GetHandler()
    return #g==1 and g:GetFirst()==c and s.fcheck(tp,g,sc)
end

function s.fcheck(tp,sg,fc)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
end
--Fusion Materials
function s.ffilter(c,fc,sumtype,tp)
    return (c:IsType(TYPE_FUSION,fc,sumtype,tp) and c:IsRace(RACE_FAIRY,fc,sumtype,tp)) or (c:IsType(TYPE_RITUAL,fc,sumtype,tp) and c:IsRace(RACE_ILLUSION,fc,sumtype,tp))
end

--Change effect
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsSpellTrapEffect() and rp==1-tp
end
function s.chtg(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit and Duel.IsPlayerCanDraw(1-tp,1) and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil) end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
    end
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
function s.chop(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local g=Group.CreateGroup()
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if rit then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
            Duel.BreakEffect()
            Duel.ChangeTargetCard(ev,g)
            Duel.ChangeChainOperation(ev,s.repop)
        end
    end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_RULE,PLAYER_NONE,tp)>0 then
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end


--Shuffle and Draw
function s.tdfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsAbleToDeck()
end 
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local hg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND,0,nil)
    if #hg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=hg:Select(tp,1,#hg,nil)
    if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
    local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
    if ct>0 then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp,ct,REASON_EFFECT)
    end
end


--Search Ritual
function s.thfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
