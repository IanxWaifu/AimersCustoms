--Azhimaou - Conflagration of Infernum
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
	e1:SetCost(s.lvcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
function s.lvfilter(c)
	return c:HasLevel() and c:IsSetCard(SET_AZHIMAOU) and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_SYNCHRO)) and ((c:IsLocation(LOCATION_HAND) and not c:IsPublic()) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
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
				return tp~=rp or not (e:GetHandler():IsType(TYPE_TRAP) and e:GetHandler():IsSetCard(SET_AZHIMAOU))
			end
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local set=SET_AZHIMAOU
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlimit(set))
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	if #g>0 then
	local tc=g:GetFirst()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) then
		if Duel.NegateRelatedChain(tc,RESET_TURN_SET)~=0 and not tc:IsDisabled() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		Duel.AdjustInstantly()
		if tc:IsDisabled() and tc:IsFaceup() then
			Duel.BreakEffect() 
			Duel.Destroy(tc,REASON_EFFECT)
		end
			if not e:GetHandler():IsRelateToEffect(e) or not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
			local ct=Duel.GetCurrentChain()
			local dg=Duel.GetFieldGroup(tp,LOCATION_GRAVE,LOCATION_GRAVE)
				if ct>1 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.BreakEffect()
		            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		            local dg2=dg:Select(tp,1,1,nil)
		            Duel.HintSelection(dg2)
		            Duel.Remove(dg2,POS_FACEUP,REASON_EFFECT)
            	end
            end
		end	
	end
end