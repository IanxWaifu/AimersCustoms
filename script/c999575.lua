--Scripted by IanxWaifu
--Voltaic Vanguard, Gaizahar
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --[[Pendulum.AddProcedure(c, false)--]]
    Aimer.AddVoltaicPendProcedure(c,reg,aux.Stringid(id,0))
    -- Remain on Field
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e3:SetCode(EVENT_CHANGE_POS)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetRange(LOCATION_ONFIELD)
    e3:SetCondition(s.scondition)
    e3:SetOperation(s.dirop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SSET)
    c:RegisterEffect(e4)
    --change scale
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.pcon1)
	e5:SetCost(s.pcost)
	e5:SetOperation(s.pcop)
	c:RegisterEffect(e5)
    local e10=e5:Clone()
	e10:SetType(EFFECT_TYPE_QUICK_O)
	e10:SetCode(EVENT_FREE_CHAIN)
	e10:SetCondition(s.pcon2)
	c:RegisterEffect(e10)
    --Flip a Monster Card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_CHANGE_POS)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,{id,1})
	e6:SetCondition(s.flipcon)
	e6:SetTarget(s.fliptg)
	e6:SetOperation(s.flipop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SSET)
	c:RegisterEffect(e7)
	-- Flip and Set
    local e9=Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id,3))
    e9:SetType(EFFECT_TYPE_IGNITION)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCountLimit(1,{id,2})
    e9:SetCost(s.movecost)
    e9:SetTarget(s.movetg)
    e9:SetOperation(s.moveop)
    c:RegisterEffect(e9)
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e12:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
	e12:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e12:SetRange(LOCATION_PZONE)
	e12:SetCondition(s.syncon)
	e12:SetValue(s.synval)
	c:RegisterEffect(e12)
end

s.listed_names = {id}
s.listed_series = {SET_VOLTAIC, SET_VOLDRAGO}

function s.pcon1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsPlayerAffectedByEffect(tp,VOLTAICPENDQ)
end
function s.pcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,VOLTAICPENDQ)
end

function s.scondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not ((c:GetPreviousPosition() & POS_FACEUP) == 0)) and c:IsFacedown()
end

function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end


function s.pcfilter(c,pc)
	return c:IsMonster() and (c:IsSetCard(SET_VOLTAIC) or c:IsSetCard(SET_VOLDRAGO)) and c:GetLevel()~=pc:GetLeftScale() and c:IsAbleToGraveAsCost()
end
function s.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end

function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local scale=e:GetLabel()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LSCALE)
	e1:SetValue(scale)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RSCALE)
	e2:SetValue(scale)
	c:RegisterEffect(e2)
end



function s.tspcfilter(c,tp)
    if c:GetControler()~=tp then return false end
    if not (c:IsSetCard(SET_VOLTAIC) and c:IsType(TYPE_EQUIP)) then return false end
    return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) 
        and (c:GetDestination()==LOCATION_GRAVE or c:GetDestination()==LOCATION_REMOVED)
end


function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mc=e:GetHandler()
    if chk==0 then return eg:IsExists(s.tspcfilter,1,nil,tp) end
    Duel.Hint(HINT_CARD,0,id)
    -- Filter only archetype equip cards
    local g=eg:Filter(s.repfilter,nil,tp) 
    for tc in g:Iter() do
    	tc:CancelToGrave()
        aux.DelayedOperation(tc,PHASE_END,id,e,tp,
        function(ag)
            Duel.SendtoDeck(ag,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
        end)
    end
    return true
end

function s.repfilter(c,tp)
	return c:IsSetCard(SET_VOLTAIC) and c:IsType(TYPE_EQUIP) and c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp) 
end

function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

--monstercard is flipped down
function s.flipfilter(c)
	return (not ((c:GetPreviousPosition() & POS_FACEUP) == 0)) and c:IsFacedown() and c:IsOriginalType(TYPE_MONSTER)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.flipfilter,1,nil)
end

function s.ffilter(c)
	return ((c:IsFaceup() and c:IsCanTurnSet()) or c:IsFacedown()) and c:IsOriginalType(TYPE_MONSTER)
end

function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local fg=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #fg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=fg:Select(tp,1,1,nil)
		Duel.HintSelection(g)
    	for tc in aux.Next(g) do
            Aimer.FlipCard(e,tc,tp)
        end
    end
end


--move opponent's card
function s.movecost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_COST,tp,tp,0)
end

function s.movetg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Aimer.CanMoveCardToAppropriateZone,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp,nil) end
end

function s.moveop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp,Aimer.CanMoveCardToAppropriateZone,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	if #g>0 then
		 local tdg=g:GetFirst()
         local p=tdg:GetControler()
         Aimer.MoveCardToAppropriateZone(tdg,p)
	end
end

function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFacedown() and e:GetHandler():IsLocation(LOCATION_PZONE)
end

function s.synval(e,mc,sc) --this effect, this card and the monster to be summoned
	return sc:IsType(TYPE_SYNCHRO) and (sc:IsCode(999574) or sc:IsCode(999555))
end