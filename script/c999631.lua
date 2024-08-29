--Scripted by IanxWaifu
--Iniquity Besetting the Hexed
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.matcon)
	e1:SetTarget(s.mattg)
	e1:SetOperation(s.matop)
	c:RegisterEffect(e1)
	--Opponent cannot use Legion Tokens as Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
	--Set itself from the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND|LOCATION_DECK) end)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}
s.listed_names={id}


function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and ep==1-tp
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local g=Group.CreateGroup()
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			local tc=te:GetHandler()
			if tc and te:IsActiveType(TYPE_MONSTER) then
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
			if tc and te:IsActiveType(TYPE_MONSTER) then
				local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
				g:AddCard(tc)
			end
		end
		local dg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_LEGION_TOKEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		return #dg>0
	end
	local g=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if tc and te:IsActiveType(TYPE_MONSTER) then
			local loc=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_LOCATION)
			g:AddCard(tc)
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1,i)
		end
	end
  	g:KeepAlive()
    e:SetLabelObject(g)
	local i=g:GetFirst():GetFlagEffectLabel(id)
	local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
end

function s.rtfilter(c)
	return c:IsSetCard(SET_DEATHRALL) and c:IsType(TYPE_LINK) and c:IsFaceup() and c:IsAbleToRemove()
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	if #g>0 then
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+0x57a0000)
			tc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e2,true)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			tc:RegisterEffect(e3,true)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			tc:RegisterEffect(e4,true)
			tc:RegisterFlagEffect(0,RESET_EVENT+0x57a0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
		end
		g:DeleteGroup()
		if not Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_MZONE,0,1,nil) or not Duel.SelectYesNo(tp, aux.Stringid(id,1)) then return end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rt=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		Duel.HintSelection(rt)
		if Duel.Remove(rt,POS_FACEUP,REASON_COST+REASON_TEMPORARY)>0 then
			rt:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
			--Return it in the End Phase
			local e5=Effect.CreateEffect(e:GetHandler())
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_PHASE+PHASE_END)
			e5:SetLabelObject(rt)
			e5:SetCountLimit(1)
			e5:SetCondition(function(e) return e:GetLabelObject():HasFlagEffect(id) end)
			e5:SetOperation(function(e) Duel.ReturnToField(e:GetLabelObject()) end)
			e5:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e5,tp)
		end
	end
end


function s.statfilter(c)
	return c:IsSetCard(SET_LEGION_TOKEN) and c:IsFaceup()
end

function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	--Cannot be Link MAterial
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_LEGION_TOKEN) end)
	e1:SetValue(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	Duel.RegisterEffect(e4,tp)
	--lose stats
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(s.val)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e6,tp)
	aux.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,2),nil)

end

function s.val(e,c)
	local sg=Duel.GetMatchingGroup(s.statfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local stat=#sg*500
	return -stat
end


function s.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		Duel.SSet(tp,c)
	end
end