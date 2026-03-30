--Scripted by Aimer
--Genosynx Giadremida
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzmatfilter,4,2,nil,nil,Xyz.InfiniteMats)
	-- (Quick Effect): Detach 1 "Genosynx" Trap from an Xyz Monster you control; apply its Set activation effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.freecon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	local e01=e1:Clone()
	e01:SetCode(EVENT_CHAINING)
	e01:SetCondition(s.chaincon)
	c:RegisterEffect(e01)
	-- When a card is Set to the Spell/Trap Zone: Target 1 Spell/Trap on the field; return it to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SSET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

function s.freecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end

function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>0 and re~=nil
end

function s.xyzmatfilter(c,xyz,sumtype,tp)
	return c:IsLevel(4) and (c:IsOriginalType(TYPE_TRAP) or (c:IsType(TYPE_SPIRIT) and c:IsMonster()))
end

-- ---------- Marker fetch: get the Set-route ACTIVATE effect from the Trap ----------
function s.getseteffect(tc)
	-- Most reliable: returns an Effect if tc currently has this code
	local em=tc:IsHasEffect(GENOSYNX_SET_ACT)
	if em then
		local te=em:GetLabelObject()
		if te and (te:GetType()&EFFECT_TYPE_ACTIVATE~=0) then
			return te
		end
	end
	-- Fallback: scan own effects for the marker code
	local effs={tc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==GENOSYNX_SET_ACT then
			local te=eff:GetLabelObject()
			if te and (te:GetType()&EFFECT_TYPE_ACTIVATE~=0) then
				return te
			end
		end
	end
	return nil
end


-- Trap must be a Genosynx Trap and have the set-route marker
function s.copyfilter(c)
	return c:IsSetCard(SET_GENOSYNX) and c:IsOriginalType(TYPE_TRAP)
		and c:IsAbleToGrave()
		and s.getseteffect(c)~=nil
end

-- gather all legal Genosynx Traps that are currently overlays of Xyz you control
function s.getoverlaytraps(tp)
	local g=Group.CreateGroup()
	local xg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,nil)
	local xc=xg:GetFirst()
	while xc do
		local og=xc:GetOverlayGroup()
		if og and og:GetCount()>0 then
			local tc=og:GetFirst()
			while tc do
				if s.copyfilter(tc) then g:AddCard(tc) end
				tc=og:GetNext()
			end
		end
		xc=xg:GetNext()
	end
	return g
end
-- ---------- helper: can this Trap's copied ACTIVATE effect pay its cost right now? ----------
function s.canpaycopiedcost(sc,te,e,tp,eg,ep,ev,re,r,rp)
	if not te then return true end
	local cost=te:GetCost()
	if not cost then return true end
	-- pull the activation args that this trap would normally use
	local _,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	ceg=ceg or Group.CreateGroup()
	cep=cep or tp
	cev=cev or 0
	cre=cre or nil
	cr=cr or 0
	crp=crp or tp
	return cost(e,tp,ceg,cep,cev,cre,cr,crp,0)
end
function s.cancopytrap(sc,te,e,tp,eg,ep,ev,re,r,rp)
	if not te then return false end
	local con=te:GetCondition()
	if con and not con(te,tp,eg,ep,ev,re,r,rp) then return false end
	local _,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	ceg=ceg or Group.CreateGroup()
	cep=cep or tp
	cev=cev or 0
	cre=cre or nil
	cr=cr or 0
	crp=crp or tp
	-- cost legality (chk==0)
	local cost=te:GetCost()
	if cost and not cost(e,tp,ceg,cep,cev,cre,cr,crp,0) then return false end
	-- target legality (chk==0)  << this is the part you were missing
	local tg=te:GetTarget()
	if tg and not tg(e,tp,ceg,cep,cev,cre,cr,crp,0) then return false end
	return true
end

--Target Copy Check
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- delegate "chkc" legality to the copied target func (if any)
	if chkc then
		local pack=e:GetLabelObject()
		if not pack then return false end
		local te,ceg,cep,cev,cre,cr,crp=pack[2],pack[3],pack[4],pack[5],pack[6],pack[7],pack[8],pack[9]
		local con=te:GetCondition()
		local tg=te and te:GetTarget()
		return con and con(te,tp,eg,ep,ev,re,r,rp) and tg and tg(e,tp,ceg,cep,cev,cre,cr,crp,chk,chkc)
	end
	-- legality check
	if chk==0 then
		local g=s.getoverlaytraps(tp)
		if not re then g=g:Filter(function(c) local te=s.getseteffect(c) return not (te and te:IsHasProperty(EFFECT_FLAG_EVENT_PLAYER)) and not (te and te:GetCode()==EVENT_CHAINING) end,nil) end
		g=g:Filter(function(c) local te=s.getseteffect(c) return te and s.cancopytrap(c,te,e,tp,eg,ep,ev,re,r,rp) end,nil)
		return #g>0
	end
	-- select overlay trap to copy
	local g=s.getoverlaytraps(tp)
	if not re then g=g:Filter(function(c) local te=s.getseteffect(c) return not (te and te:GetCode()==EVENT_CHAINING) end,nil) end
	g=g:Filter(function(c) local te=s.getseteffect(c) return te and s.cancopytrap(c,te,e,tp,eg,ep,ev,re,r,rp) end,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	local te=s.getseteffect(sc)
	if not te then return end
	local _,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	ceg=ceg or Group.CreateGroup()
	cep=cep or tp
	cev=cev or 0
	cre=cre or nil
	cr=cr or 0
	crp=crp or tp
	e:SetProperty(te:GetProperty())
	local cost=te:GetCost()
	if cost then
		if not cost(e,tp,ceg,cep,cev,cre,cr,crp,0) then return end
		cost(e,tp,ceg,cep,cev,cre,cr,crp,1)
	end
	local tg=te:GetTarget()
	if tg and not tg(e,tp,ceg,cep,cev,cre,cr,crp,0) then return end
	if tg then
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		Duel.ClearOperationInfo(0)
	end
	e:SetLabelObject({sc,te,ceg,cep,cev,cre,cr,crp})
end
--Effect Copy Operation
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local pack=e:GetLabelObject()
	if not pack then return end
	local sc,te,ceg,cep,cev,cre,cr,crp=table.unpack(pack)
	if not sc or not te then return end
	if Duel.SendtoGrave(sc,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		local op=te:GetOperation()
		if op then
			op(e,tp,ceg,cep,cev,cre,cr,crp)
		end
		e:SetLabelObject(nil)
	end
end


-- ---------- S/T bounce on set ----------
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL|TYPE_TRAP) and c:IsAbleToHand()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

--leave field special summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.sstrapfilter(c,tp)
	if not (c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_TRAP)) then return false end
	if c:IsForbidden() then return false end
	return Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sstrapfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sstrapfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		tc:AddMonsterAttribute(TYPE_EFFECT|TYPE_SPIRIT|TYPE_TRAP)
		tc:AddMonsterAttributeComplete()
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_BEAST)
		e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
		tc:RegisterEffect(e1,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(ATTRIBUTE_DARK)
		tc:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_LEVEL)
		e4:SetValue(4)
		tc:RegisterEffect(e4,true)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_SET_BASE_ATTACK)
		e5:SetValue(2000)
		tc:RegisterEffect(e5,true)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_SET_BASE_DEFENSE)
		e6:SetValue(2000)
		tc:RegisterEffect(e6,true)
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
	end
end