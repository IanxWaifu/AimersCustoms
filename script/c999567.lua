--Scripted by IanxWaifu
--Voltaic Praetorian, Tariqhir
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(s.matfilter),3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.hdexcon)
	e1:SetTarget(s.hdextg)
	e1:SetOperation(s.hdexop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.hdexcon2)
    c:RegisterEffect(e2)
    --Negate Effects
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	-- Monsters same column flip face-down
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.rthtg)
	e4:SetOperation(s.rthop)
	c:RegisterEffect(e4)
end

s.material_setcode=SET_VOLTAIC_ARTIFACT
s.listed_names = {id}
s.listed_series = {SET_VOLTAIC_ARTIFACT,SET_VOLDRAGO}

function s.matfilter(c)
	return c:IsSetCard(SET_VOLTAIC_ARTIFACT) or c:IsSetCard(SET_VOLDRAGO)
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(function(c) return (c:IsType(TYPE_EQUIP) and c:IsAbleToDeckOrExtraAsCost() and c:IsLocation(LOCATION_ONFIELD+LOCATION_HAND)) or (c:IsHasEffect(EFFECT_SYNCHRO_MAT_FROM_HAND) and c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(SET_VOLDRAGO) and c:IsAbleToRemove()) 
	end,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	if #g==0 then return end
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    -- Merge the two groups into one
    if #sg>0 then
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        local tg=Duel.GetOperatedGroup()
   		if tg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then 
        	g:Sub(sg)
    	end
    end
	if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)==0 then return end
	local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if #dg==0 then return end
	local ct=dg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>1 then
		Duel.SortDeckbottom(tp,tp,ct)
	end
end

function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end


function s.hdexcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not ((c:GetPreviousPosition() & POS_FACEDOWN) == 0)) and c:IsFaceup()
end
function s.hdexcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPosition(POS_FACEUP)
end

function s.mgfilter(c,fusc)
	return ((c:GetReason()&0x40008)==0x40008 or c:GetReasonCard()==fusc)
end

function s.hdexfilter(c,tp,mg,sc)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_VOLTAIC) and c:IsControler(tp) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,tp,mg,sc)
end

function s.eqfilter(c,tp,mg,sc)
	return c:IsSetCard(SET_VOLTAIC) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and mg:IsExists(s.mgfilter,1,nil,sc) and s.codefilter(c,mg)
end

function s.codefilter(c,mg)
	return not mg:IsExists(Card.IsCode,1,nil,c:GetCode())
end

function s.hdextg(e,tp,eg,ep,ev,re,r,rp,chk)
    local sc=e:GetHandler()
    local mg=sc:GetMaterial()
    if chk==0 then return #mg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.hdexfilter,tp,LOCATION_MZONE,0,1,nil,tp,mg,sc) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,0)
end

function s.hdexop(e,tp,eg,ep,ev,re,r,rp)
    local sc=e:GetHandler()
    local mg=sc:GetMaterial()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_DECK,0,nil,tp,mg,sc):Select(tp,1,1,nil,mg)
    if #g>0 then
        Duel.HintSelection(g,true)
        Duel.Equip(tp,g:GetFirst(),sc)
    end
end



--Target Negate
function s.disfilter(c)
	return c:IsNegatableMonster() and c:IsSetCard(SET_VOLTAIC)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.disfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,LOCATION_MZONE,0,1,nil) end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		--Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end


--Same Column as Facedowns
function s.rthfilter(c,e)
	return Aimer.VoltaicSameColumns(e,c) and c:IsCanTurnSet()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rthfilter,tp,0,LOCATION_MZONE,1,nil,e) end
	local sg=Duel.GetMatchingGroup(s.rthfilter,tp,0,LOCATION_MZONE,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,#sg,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.rthfilter,tp,0,LOCATION_MZONE,nil,e)
	for tc in aux.Next(sg) do
		if tc:IsCanTurnSet() then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
