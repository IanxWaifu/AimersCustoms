--Scripted by IanxWaifu
--Impudence Converged
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.sprcon)
	e2:SetTarget(s.sprmtg)
	e2:SetOperation(s.sprmop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}

function s.thfilter(c)
	return c:ListsArchetype(SET_LEGION_TOKEN) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


function s.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_DEATHRALL) and c:IsType(TYPE_LINK)
end
function s.sprcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and eg:IsExists(s.spfilter,1,nil,tp)
end

function s.tgfilter(c,tp,rmv_chk,sp_chk)
	return (c:IsSetCard(SET_DEATHRALL) or c:ListsArchetype(SET_LEGION_TOKEN)) and ((sp_chk and c:IsAbleToRemove()) or (rmv_chk and c:IsSSetable())) and not c:IsCode(id) and c:IsSpellTrap()
end
function s.sprmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local rmv_chk=c:IsAbleToRemove()
	local sp_chk=c:IsSSetable()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp,rmv_chk,sp_chk) end
	if chk==0 then return (rmv_chk or sp_chk) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,tp,rmv_chk,sp_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp,rmv_chk,sp_chk)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.adfilter(c,tp,g)
	return c:IsSSetable() and g:IsExists(Card.IsAbleToRemove,1,c)
end
function s.sprmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	local g=Group.FromCards(c,tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:FilterSelect(tp,s.adfilter,1,1,nil,tp,g)
	if #sg>0 and Duel.SSet(tp,sg)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		g:GetFirst():RegisterEffect(e2)
		Duel.Remove(g:Sub(sg),POS_FACEUP,REASON_EFFECT)
	end
end