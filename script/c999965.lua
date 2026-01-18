--Kyoshin - Jaryoku no Kanchü
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript("AimersAux.lua")
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_MSET)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.acost)
    e1:SetTarget(s.actg)
    e1:SetOperation(s.acop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SSET)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_CHANGE_POS)
    e3:SetCondition(s.accon2)
    c:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.accon3)
    c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCost(Cost.SelfBanish)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.pltg)
	e5:SetOperation(s.plop)
	c:RegisterEffect(e5)
end

s.listed_names={id}
s.listed_series={SET_KYOSHIN}

function s.accon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return (c:GetPreviousPosition()&POS_FACEUP)~=0 and (c:GetPosition()&POS_FACEDOWN)~=0 end,1,nil)
end

function s.accon3(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsFacedown,1,nil)
end

function s.sendfilter(c)
    return c:IsSetCard(SET_KYOSHIN)
    and c:IsOriginalType(TYPE_MONSTER)
    and c:IsAbleToGraveAsCost()
end

function s.retfilter(c,tp,codes)
    if c:IsControler(1-tp) then
        return c:IsFacedown()
        and c:IsAbleToHand()
        and c:IsLocation(LOCATION_ONFIELD)
    end
    return c:IsControler(tp)
    and c:IsSetCard(SET_KYOSHIN)
    and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED)
    and c:IsAbleToHand()
    and not codes[c:GetCode()]
end

function s.sendcheck(sg,e,tp)
    local codes={}
    for c in aux.Next(sg) do
        codes[c:GetCode()]=true
    end
    local g=Duel.GetMatchingGroup(s.retfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_ONFIELD,nil,tp,codes)
    return #g>=#sg
end


function s.acost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_STZONE,0,nil)
    if chk==0 then
        return aux.SelectUnselectGroup(g,e,tp,1,#g,s.sendcheck,0,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.sendcheck,1,tp)
    Duel.SendtoGrave(sg,REASON_COST)
    e:SetLabel(#sg)
    local codes={}
    for tc in aux.Next(sg) do
        codes[tc:GetCode()]=true
    end
    e:SetLabelObject(codes)
end


function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetLabel()
    local codes=e:GetLabelObject() or {}
    local g=Duel.GetMatchingGroup(s.retfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_ONFIELD,nil,tp,codes)
    if chk==0 then return #g>=ct end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,0,0)
end


function s.acop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    local codes=e:GetLabelObject() or {}
    local g=Duel.GetMatchingGroup(s.retfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_ONFIELD,nil,tp,codes)
    if #g<ct then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,ct,ct,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
end


function s.plfilter(c)
	local p=c:GetOwner()
	if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsSetCard(SET_KYOSHIN) and c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0 and c:CheckUniqueOnField(p)
		and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.plfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tp,0)
    end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		tc:RegisterEffect(e1)
	end
end