--Azhimaou - Tundras of Cocytus
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
	e1:SetCost(s.lvcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
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
	local lv=sg:GetLevel()
    local reduction=4
    if lv-reduction<1 then
        reduction=lv-1
    end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-reduction)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	sg:RegisterEffect(e1)
end

function s.chainlimit()
	return	function(e,rp,tp)
				return tp~=rp or not (e:GetHandler():IsType(TYPE_SPELL) and e:GetHandler():IsSetCard(SET_AZHIMAOU))
			end
end

--Send to GY and reduce ATk/DEF
function s.tgfilter(c)
	return c:IsSetCard(SET_AZHIMAOU) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.atkfilter(c)
	return c:IsFaceup() and (c:GetLevel()>0 or c:GetLink()>0 or c:GetRank()>0) and (c:GetAttack()>0 or c:GetDefense()>0)
end
function s.chkfilter(c)
	return not c:IsStatus(STATUS_ACT_FROM_HAND)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc or Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
    local tg=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
	if #tg>0 then
	    for sc in aux.Next(tg) do
	        -- Determine if it's a Link, Xyz (Rank), or other monster (Level)
	        local reduction = 0
	        if sc:IsType(TYPE_LINK) then
	            reduction = sc:GetLink()
	        elseif sc:IsType(TYPE_XYZ) then
	            reduction = sc:GetRank()
	        else
	            reduction = sc:GetLevel()
	        end
	        -- Apply the reduction to Attack
	        if reduction ~= 0 then
	            local e1=Effect.CreateEffect(c)
	            e1:SetType(EFFECT_TYPE_SINGLE)
	            e1:SetCode(EFFECT_UPDATE_ATTACK)
	            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	            e1:SetValue(reduction*-200)
	            sc:RegisterEffect(e1)
				local e2=e1:Clone()
			    e2:SetCode(EFFECT_UPDATE_DEFENSE)
			    sc:RegisterEffect(e2)
			end
		end
	end
    if not e:GetHandler():IsRelateToEffect(e) or not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
    local ct=Duel.GetCurrentChain()
    local dg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if ct>1 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local dg2=dg:Select(tp,1,1,nil)
        Duel.HintSelection(dg2)
        --Cannot activate its effects
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3302)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_TRIGGER)
		e3:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
		dg2:GetFirst():RegisterEffect(e3)
    end 
end
