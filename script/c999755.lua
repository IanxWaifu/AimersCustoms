--Azhimaou - Tombs of Haereticorum
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
	e1:SetCost(s.lvcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
end
function s.lvfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(SET_AZHIMAOU) and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_SYNCHRO)) and ((c:IsLocation(LOCATION_HAND) and not c:IsPublic()) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end

function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local sg=g:Select(tp,1,1,nil):GetFirst()
	Duel.HintSelection(sg)
	if sg:IsLocation(LOCATION_HAND) and not sg:IsPublic() then
		Duel.ConfirmCards(1-tp,sg)
	end
	local c=e:GetHandler()
	local lv=sg:GetLevel()
    local reduction=4
    if lv-reduction<0 then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		sg:RegisterEffect(e1)
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-reduction)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		sg:RegisterEffect(e1)
	end
end

function s.chainlimit()
	return	function(e,rp,tp)
				return tp~=rp or not (e:GetHandler():IsType(TYPE_SPELL) and e:GetHandler():IsSetCard(SET_AZHIMAOU))
			end
end

function s.setfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and not c:IsCode(id) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlimit())
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SSet(tp,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e2)
		--Apply Continuous burn or gain
		local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_DAMAGE)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAINING)
		e3:SetCountLimit(1)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		e3:SetLabelObject(tc)
		e3:SetCondition(s.damcon)
		e3:SetTarget(s.damtg)
		e3:SetOperation(s.damop)
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCategory(CATEGORY_RECOVER)
		e4:SetCondition(s.lpcon)
		e4:SetTarget(s.lptg)
		e4:SetOperation(s.lpop)
		Duel.RegisterEffect(e4,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESET_TOFIELD|RESET_TURN_SET,0,1)
		if not e:GetHandler():IsRelateToEffect(e) or not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		local ct=Duel.GetCurrentChain()
		local code=e:GetLabel()
		local tcode=tc:GetCode()
		if code~=0 and tc:IsLocation(LOCATION_SZONE) then
			local mg=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_DECK,0,nil,code,tcode)
			if ct>2 and #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=mg:Select(tp,1,1,nil)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end

function s.adfilter(c,code,tcode)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsType(TYPE_RITUAL) and not c:IsCode(code) and not c:IsCode(tcode) and c:IsAbleToHand()
end


function s.ritfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsMonster()
end
--Burn
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsLocation(LOCATION_ONFIELD) and tc:GetFlagEffect(id)>0 and tc:GetControler()==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and tc==re:GetHandler()
	and not Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if tc and tc:GetFlagEffect(id)>0 then
		Duel.Damage(p,d,REASON_EFFECT)
		tc:ResetFlagEffect(id)
	end
end

--Gain
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsLocation(LOCATION_ONFIELD) and tc:GetFlagEffect(id)>0 and tc:GetControler()==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and tc==re:GetHandler()
	and Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,1000)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if tc and tc:GetFlagEffect(id)>0 then
		Duel.Recover(p,d,REASON_EFFECT)
		tc:ResetFlagEffect(id)
	end
end