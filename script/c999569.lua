--Scripted by IanxWaifu
--Voltaic Nomadic Journey
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Pendulum Place
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.pctg)
    e1:SetOperation(s.pcop)
    c:RegisterEffect(e1)
    -- Shuffle+Draw 1 Card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCost(s.tdcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

--Pendlulum Place
function s.pcfilter(c)
    return c:IsSetCard(SET_VOLTAIC) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
        and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pcfilter),tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    if #g>0 then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end

--BFG Shuffle+Draw
function s.tdfilter(c)
    return c:IsSetCard(SET_VOLTAIC_ARTIFACT) and c:IsAbleToDeck() and ((c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)) or c:IsLocation(LOCATION_GRAVE))
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if chk==0 then return #dg>0 and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #dg==0 then return end
    local ct=Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    if ct>1 then Duel.SortDeckbottom(tp,tp,ct) end
    if ct==#dg then
        Duel.BreakEffect()
        Duel.Draw(tp,ct,REASON_EFFECT)
    end
end