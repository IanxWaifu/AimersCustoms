--Scripted by Aimer
--Genosynx Khilaguin
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzmatfilter,4,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

function s.xyzmatfilter(c,xyz,sumtype,tp)
	return c:IsLevel(4) and (c:IsOriginalType(TYPE_TRAP) or (c:IsType(TYPE_SPIRIT) and c:IsMonster()))
end
function s.cfilter(c)
	return c:IsSetCard(SET_GENOSYNX) and c:IsTrap()
end
function s.ovfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_XYZ) and c:IsControler(tp)
end

function s.xyzop(e,tp,chk,mc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local tc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil):Select(tp,1,1,nil):GetFirst()
	if not tc then return false end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.attach_on_spsummon)
	Duel.RegisterEffect(e1,tp)
	return true
end

function s.attach_on_spsummon(e,tp,eg,ep,ev,re,r,rp)
	if not e then return end
	local c=e:GetHandler()
	if not c then return end
	if not eg or not eg:IsContains(c) then return end
	local tc=e:GetLabelObject()
	if not tc then return end
	if not (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) then return end
	if not c:IsCode(id) then return end
	if tc:IsLocation(LOCATION_OVERLAY) then e:Reset() return end
	Duel.Overlay(c,tc)
	e:Reset()
end

------------------------
--Draw same number and shuffle
function s.drthfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drthfilter,1,nil,tp)
end

function s.setfilter(c,e,tp)
	return c:IsSpellTrap() and c:IsSSetable(e,tp)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.drthfilter,nil,tp)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	e:SetLabel(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,ct)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct<=0 then return end
	if Duel.Draw(tp,ct,REASON_EFFECT)~=ct then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<ct then return end
	-- shuffle same number from hand into Deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,ct,ct,nil)
	if #g~=ct then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- then you can Set 1 Spell/Trap from hand
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local sc=sg:GetFirst()
		if sc then Duel.SSet(tp,sc) end
	end
end

--Choose Return Effect
function s.mfilter(c)
	return c:IsAbleToHand()
end
function s.sfilter(c)
	return c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mgmon=c:GetOverlayGroup():Filter(Card.IsMonster,nil)
	local mgst=c:GetOverlayGroup():Filter(Card.IsSpellTrap,nil)
	local rmg=Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
	local rsg=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local opt=0
	if chk==0 then return (#mgmon>0 and rmg) or (#mgst>0 and rsg) end
	if (#mgmon>0 and rmg) and (#mgst>0 and rsg) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
		e:SetLabel(opt)
	elseif (#mgmon>0 and rmg) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,4))
		e:SetLabel(opt)
	elseif (#mgst>0 and rsg) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,5))+1
		e:SetLabel(opt)
	else return end		
		if opt==0 then
		local mg=mgmon:Select(tp,1,1,nil):GetFirst()
		Duel.SendtoGrave(mg,REASON_COST)
		Duel.RaiseSingleEvent(mg,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	elseif opt>0 then
		local sg=mgst:Select(tp,1,1,nil):GetFirst()
		Duel.SendtoGrave(sg,REASON_COST)
		Duel.RaiseSingleEvent(sg,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end


function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rmg=Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
	local rsg=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return rmg or rsg end
	local op=e:GetLabel()
	if op==0 then
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,mg,#mg,0,0)
	elseif op>0 then
		local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if mg and opt==0 then
		Duel.SendtoHand(mg,nil,REASON_EFFECT)
	end
	if sg and opt>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
