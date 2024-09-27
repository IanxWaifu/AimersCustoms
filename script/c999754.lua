--Azhimaou - Depths of Tartarus
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1+EFFECT_COUNT_CODE_OATH})
	e1:SetCost(s.lvcost)
	e1:SetTarget(s.adtg)
	e1:SetOperation(s.adop)
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


function s.adfilter(c,e,tp)
	return c:IsSetCard(SET_AZHIMAOU)  and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)  end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlimit())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.chainlimit()
	return	function(e,rp,tp)
				return tp~=rp or not (e:GetHandler():IsType(TYPE_TRAP) and e:GetHandler():IsSetCard(SET_AZHIMAOU))
			end
end


function s.adop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.adfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	if not e:GetHandler():IsRelateToEffect(e) or not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
    local ct=Duel.GetCurrentChain()
    local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
    if ct>1 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local dg2=dg:Select(tp,1,1,nil)
        Duel.HintSelection(dg2)
        Duel.SendtoDeck(dg2,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end