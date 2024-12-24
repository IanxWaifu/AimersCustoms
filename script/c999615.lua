--Scripted by IanxWaifu
--Deconsecration of Purity
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Change effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}


function s.tokenfilter(c)
	return c:IsType(TYPE_TOKEN)
end
function s.dgfilter(c)
	return c:IsSetCard(SET_DEATHRALL) and c:IsMonster() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) end
	local ct=Duel.GetMatchingGroup(s.tokenfilter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetRace)
	local dg=Duel.GetMatchingGroup(s.dgfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return ct>0 and dg:GetClassCount(Card.GetCode)>=ct end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sg=aux.SelectUnselectGroup(dg,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	sg:KeepAlive()
	e:SetLabelObject(sg)
end


function s.checkracefilter(c,CurrentMRace)
	return c:IsType(TYPE_TOKEN) and c:IsRace(CurrentMRace)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
    local sg=e:GetLabelObject()
    if #sg>0 then
        local sequences = {}  -- Table to store sequences for each card
        local positions = {}  -- Table to store battle positions for each card
        local toDestroy = {}  -- Table to store tokens to be removed
        local displaceCards = {}  -- Table to store cards to be moved
        for tc in aux.Next(sg) do
	            local CurrentMRace=tc:GetRace()
	            if g:IsExists(Card.IsRace,1,nil,CurrentMRace) then
        			Duel.ConfirmCards(tp,tc)
        			if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
	                local dc=Duel.GetMatchingGroup(s.checkracefilter,tp,LOCATION_MZONE,0,nil,CurrentMRace)
	                local dgt=dc:Select(tp,1,1,nil)
	                g:RemoveCard(dgt)
	                Duel.HintSelection(dgt)
	                local seq=dgt:GetFirst():GetSequence()
	                local pos=dgt:GetFirst():GetPosition()
	                table.insert(sequences,seq)
	                table.insert(positions,pos)
	                table.insert(toDestroy,dgt:GetFirst())
	                table.insert(displaceCards,tc)
	            end
            end
        end
        -- Displace each token individually
        for _, card in ipairs(toDestroy) do
            Duel.SendtoGrave(card,REASON_RULE)
        end
        -- Special Summon each card to its corresponding sequence
        for i, tc in ipairs(displaceCards) do
            local seq = sequences[i]
            local seq_bit = 2 ^ seq
            local pos = positions[i]
            if Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,pos,true,seq_bit) then
            	local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,1)
				tc:RegisterEffect(e1)
            	sg:RemoveCard(tc)
            end
        end
        -- Banish remaining revealed cards
        for tc in aux.Next(sg) do
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
        -- Finalize the displacement process
    end
end





function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_LEGION_TOKEN),tp,LOCATION_MZONE,0,1,nil)
end


function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DEATHRALL) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetRace())
end
function s.spfilter2(c,race)
	return c:IsFaceup() and c:IsRace(race) and c:IsType(TYPE_TOKEN)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
