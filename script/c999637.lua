--Scripted by IanxWaifu
--Deathrall Nihilazanthis
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials
	Fusion.AddProcMixRep(c,true,true,s.mfilter2,1,99,s.mfilter1)
	--Cannot be used as Fusion Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Gain Race
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.rccon)
    e2:SetOperation(s.rcop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_MATERIAL_CHECK)
    e3:SetValue(s.valcheck)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
    --Special Summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1,id)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
    --draw
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCondition(s.drcon)
	e5:SetTarget(s.drtg)
	e5:SetOperation(s.drop)
	c:RegisterEffect(e5)
	--Special from GY
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetHintTiming(TIMING_END_PHASE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.rtfcon)
	e6:SetTarget(s.rtftg)
	e6:SetOperation(s.rtfop)
	c:RegisterEffect(e6)
	--Register the fact it was sent to GY
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCondition(s.regcon)
	e7:SetOperation(s.regop)
	c:RegisterEffect(e7)
end

function s.mfilter1(c)
	return c:IsSetCard(SET_DEATHRALL) or c:IsSetCard(SET_LEGION_TOKEN)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_FIEND,fc,sumtype,tp) or c:IsRace(RACE_PYRO,fc,sumtype,tp) or c:IsRace(RACE_ZOMBIE,fc,sumtype,tp) or c:IsSetCard(SET_LEGION_TOKEN,fc,sumtype,tp)
end

function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=e:GetLabel()
    if rc>0 then
        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e5:SetRange(LOCATION_MZONE)
        e5:SetCode(EFFECT_ADD_RACE)
        e5:SetValue(rc)
        e5:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e5)
    end
end

function s.valcheck(e,c)
    local rc=0
    local g=c:GetMaterial()
    for tc in aux.Next(g) do
        rc=bit.bor(rc,tc:GetRace())
    end
    e:GetLabelObject():SetLabel(rc)
end

--draw during EP
function s.drfilter(c,tc)
    return c:IsFaceup() and c:IsSetCard(SET_LEGION_TOKEN) and bit.band(c:GetRace(),tc:GetRace())>0
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	Duel.Draw(p,ct,REASON_EFFECT)
end


function s.rcfilter(c,mcrace)
	return c:IsRace(mcrace)
end

function s.spfilter(c,e,tp)
    local mc = e:GetHandler()
    local mcrace = mc:GetRace()
    local tokenRaces = {RACE_FIEND, RACE_ZOMBIE, RACE_PYRO}
    -- Remove master card's race from tokenRaces table if it exists
    for i, race in ipairs(tokenRaces) do
        if race == mcrace then
            table.remove(tokenRaces, i)
            break
        end
    end
    -- Check if there are tokens on the field
    local mg = Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
    if mg:GetCount() > 0 then
        -- Check tokens' races and remove corresponding races from tokenRaces table
        for mrc in aux.Next(mg) do
            local race = mrc:GetRace()
            for i, tr in ipairs(tokenRaces) do
                if tr == race then
                    table.remove(tokenRaces, i)
                    break
                end
            end
        end
    end
    -- Check if the card matches the remaining races in tokenRaces
    local matchedRace = s.rcfilter(c, mcrace)
    -- Check if the remaining races in tokenRaces are not the same as "c"
    local validRace = false
    for _, remainingRace in ipairs(tokenRaces) do
        if remainingRace ~= c:GetRace() then
            validRace = true
            break
        end
    end
    return matchedRace and validRace and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(SET_DEATHRALL)
end



function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,RACE_FIEND,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    -- Determine the owner of the group of cards in eg
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_LEGION_F,SET_LEGION_TOKEN,TYPES_TOKEN,1000,1000,4,0,0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	    local raceCount = 0
		local excludedRace = 0
		local mg = Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
		for mrc in aux.Next(mg) do
		    local race = mrc:GetRace()
		    excludedRace = excludedRace | race
		end
		excludedRace = excludedRace & (RACE_FIEND+RACE_PYRO+RACE_ZOMBIE-g:GetFirst():GetRace())
		local race = 0
		if raceCount == 1 then
			local gRace=g:GetFirst():GetRace()
			if gRace == RACE_FIEND or gRace == RACE_PYRO or gRace == RACE_ZOMBIE then
		    race = Duel.AnnounceRace(tp,1,excludedRace)
		    e:SetLabel(race)
		else
			race = Duel.AnnounceRace(tp,1,excludedRace-gRace)
		    e:SetLabel(race)
			end
		else
			local gRace=g:GetFirst():GetRace()
			if gRace == RACE_FIEND or gRace == RACE_PYRO or gRace == RACE_ZOMBIE then
		    race = Duel.AnnounceRace(tp,1,RACE_FIEND+RACE_PYRO+RACE_ZOMBIE-excludedRace-gRace)
		    e:SetLabel(race)
		else
			race = Duel.AnnounceRace(tp,1,RACE_FIEND+RACE_PYRO+RACE_ZOMBIE-excludedRace)
		    e:SetLabel(race)
			end
		end
	    
	    local token
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
	end
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_LINK+REASON_MATERIAL)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end

function s.rtfcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and Duel.IsTurnPlayer(1-tp) and e:GetHandler():GetFlagEffect(id)>0
end

function s.rtftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.rtfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end