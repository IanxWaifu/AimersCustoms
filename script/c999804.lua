--Novalxon Matron Entrophyra
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--Special summon procedure (from extra deck)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ASTRAL_SHIFT_END)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.selfspcon)
	e1:SetCost(s.selfcost)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Special any #
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Neg Effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	--Negate Summons
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

function s.cfilter(c,tp)
	return c:IsControler(tp)
end
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.selfcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(e1,tp)
end

--Special Summon Limit
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c==e:GetHandler()
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_REMOVED) then return c:IsFaceup() and c:IsSetCard(SET_NOVALXON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	return c:IsSetCard(SET_NOVALXON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>5 then ft=5 end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=aux.SelectUnselectGroup(sg,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #g>0 then
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		Duel.SpecialSummonComplete()
	end
end


--Set up to 2
function s.setfilter(c)
	return c:IsSetCard(SET_NOVALXON) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SET)
	if #sg>0 then
		Duel.SSet(tp,sg)
	end
end


--Remove Effs
function s.scfilter(c)
	return c:IsSetCard(SET_NOVALXON) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsAbleToRemove() and ep==1-tp --[[and re:IsActiveType(TYPE_MONSTER)--]]
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc --[[and te:IsActiveType(TYPE_MONSTER)--]] then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				g:AddCard(tc)
			end
		end
		return g:IsContains(chkc) end
	if chk==0 then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc --[[and te:IsActiveType(TYPE_MONSTER)--]] then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				g:AddCard(tc)
			end
		end
		local dg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
		return #g>0 and #g<=#dg
	end
	local g=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if tc --[[and te:IsActiveType(TYPE_MONSTER)--]] then
			local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
			g:AddCard(tc)
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1,i)
		end
	end
  	g:KeepAlive()
    e:SetLabelObject(g)
	local i=g:GetFirst():GetFlagEffectLabel(id)
	local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	local dg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	if #g>#dg then return end
	if #g>0 and #g<=#dg then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=dg:Select(tp,#g,#g,nil)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end





--Remove Specials
function s.disfilter(c,tp)
	return not c:IsSummonPlayer(tp) and c:IsLocation(LOCATION_MZONE) and not c:IsDisabled() and c:IsAbleToRemove()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.disfilter,nil,tp)
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,ct,nil) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,ct,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,ct,0,0)
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.disfilter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	local dg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	if #g>#dg then return end
	if #g>0 and #g<=#dg then
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local tg=dg:Select(tp,#g,#g,nil)
			Duel.BreakEffect()
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
	end
end