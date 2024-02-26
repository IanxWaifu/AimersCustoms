--Scripted by IanxWaifu
--Intransigent Obstinance
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,tp)
		local b1=#g>0
		if b1 then return true end
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.opfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
		return b1 or b2
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
end


function s.filter(c,tp)
	return c:IsSetCard(SET_DEATHRALL) and c:IsType(TYPE_LINK) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetRace())
end

function s.spfilter(c,race)
	return c:IsSetCard(SET_DEATHRALL) and c:IsRace(race)
end

function s.opfilter(c,e,tp)
	local race=c:GetRace()
	return c:IsSetCard(SET_DEATHRALL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
	and c:IsRace(RACE_FIEND|RACE_PYRO|RACE_ZOMBIE) and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,race,0)
end

function s.lkfilter(c)
	return c:IsSetCard(SET_DEATHRALL) and c:IsLinkSummonable()
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,tp)
	local b1=#g>0
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.opfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)})
	if op==1 then
    	local dg=g:Select(tp,1,1,nil)
    	local fg=dg:GetFirst()
		Duel.HintSelection(fg)
 		local sequences = {}  -- Table to store sequences for each card
        local positions = {}  -- Table to store battle positions for each card
        local toDestroy = {}  -- Table to store tokens to be removed
        local displaceCards = {}  -- Table to store cards to be moved
        local dgt=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,fg:GetRace())
        local seq=fg:GetSequence()
        local pos=fg:GetPosition()
        table.insert(sequences,seq)
        table.insert(positions,pos)
        table.insert(toDestroy,fg)
        table.insert(displaceCards,dgt:GetFirst())
        -- Displace each token individually
        for _, card in ipairs(toDestroy) do
            Duel.SendtoGrave(card,REASON_RULE+REASON_LINK+REASON_MATERIAL)
            e:SetLabelObject(card)
        end
        -- Special Summon each card to its corresponding sequence
        for i, fg in ipairs(displaceCards) do
            local seq = sequences[i]
            local seq_bit = 2 ^ seq
            local pos = positions[i]
            local mat=e:GetLabelObject()
            fg:SetMaterial(mat)
            if Duel.MoveToField(fg,tp,tp,LOCATION_MZONE,pos,true,seq_bit) then
            	local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,1)
				fg:RegisterEffect(e1)
            end
            fg:CompleteProcedure()
        end
    elseif op==2 then
    	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    	local fmg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.opfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if Duel.SpecialSummon(fmg,0,tp,1-tp,false,false,POS_FACEUP)~=0 then
			local race = fmg:GetFirst():GetRace()
		    if race == RACE_FIEND then
		        token = Duel.CreateToken(tp,TOKEN_LEGION_F)
		    elseif race == RACE_PYRO then
		        token = Duel.CreateToken(tp,TOKEN_LEGION_P)
		    elseif race == RACE_ZOMBIE then
		        token = Duel.CreateToken(tp,TOKEN_LEGION_Z)
		    else
		        return
		    end
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		    local drg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		    if #drg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		    	Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=drg:Select(tp,1,1,nil)
				Duel.LinkSummon(tp,sg:GetFirst())
			end	    
		end
	end
end

