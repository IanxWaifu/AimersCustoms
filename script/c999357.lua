--Scripted by IanxWaifu
--Necroticrypt Deathsinger
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),4,2)
	c:EnableReviveLimit()
	--Gains ATK/DEF equal to the total ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.statcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)
	--Add or Special
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1,id)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)

end
function s.oppfilter(c,tp)
    return c:GetOwner()~=tp
end
function s.statcon(e,tp,eg,ep,ev,re,r,rp)
    local mg=e:GetHandler():GetOverlayGroup()
    return mg:IsExists(s.oppfilter,1,nil,e:GetHandlerPlayer())
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    local mg=e:GetHandler():GetOverlayGroup()
    return not mg:IsExists(s.oppfilter,1,nil,e:GetHandlerPlayer())
end
function s.atkfilter(c,tp)
	return c:GetAttack()>=0 and c:GetOwner()~=tp
end
function s.deffilter(c,tp)
	return c:GetDefense()>=0 and c:GetOwner()~=tp
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer() 
	local g=e:GetHandler():GetOverlayGroup():Filter(s.atkfilter,nil,tp)
	return g:GetSum(Card.GetAttack)
end
function s.defval(e,c)
	local tp=e:GetHandlerPlayer() 
	local g=e:GetHandler():GetOverlayGroup():Filter(s.deffilter,nil,tp)
	return g:GetSum(Card.GetDefense)
end


function s.indval(e, c)
    local g = e:GetHandler():GetOverlayGroup()
    local races = {} -- Store the races of Xyz Materials
    for tc in aux.Next(g) do
        table.insert(races, tc:GetRace()) -- Store the race of each Xyz Material
    end
    local targetRace = c:GetRace() -- Get the race of the target card

    -- Check if any of the stored races matches the target race
    for _, race in ipairs(races) do
        if race == targetRace then
            -- Check if the target card is face-up
            if c:IsFaceup() then
                return true -- If a match is found and the target card is face-up, return true
            end
        end
    end

    return false -- If no match is found or the target card is not face-up, return false
end



function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=re:GetHandler()
	local b1=check:IsDestructable()
	local b2=Duel.IsChainNegatable(ev)
	local xyz1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
	local xyz2=Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	local opt=0
	if chk==0 then return (xyz1 and b1) or (xyz2 and b2) end
	if ((xyz1 and b1) and (xyz2 and b2)) then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))
		e:SetLabel(opt)
	elseif (xyz1 and b1) then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,0))
		e:SetLabel(opt)
	elseif (xyz2 and b2) then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,1))+1
		e:SetLabel(opt)
	else return end		
		if opt==0 then
		local sg=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST,sg)
		elseif opt>0 then
		local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		local og=tc:GetOverlayGroup()
		Duel.SendtoGrave(og,REASON_COST)
	end
end


function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=re:GetHandler()
	local b1=check:IsDestructable()
	local b2=Duel.IsChainNegatable(ev)
	if chk==0 then return b1 or b2 end
	local op=e:GetLabel()
	if op==0 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,check,1,1-tp,check:GetLocation())
	elseif op>0 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,check,1,1-tp,check:GetLocation())
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local check=re:GetHandler()
	local b1=check:IsDestructable()
	local b2=Duel.IsChainNegatable(ev)
	if b1 and opt==0 then
		Duel.Destroy(check,REASON_EFFECT)
	end
	if b2 and opt>0 then
		Duel.NegateEffect(ev)
	end
end



function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x129f)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x129f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsType(TYPE_XYZ)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	local c=e:GetHandler()
	if chk==0 then return (e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and b1) or (e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) and b2) end
	if (b1 and b2) then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		e:SetLabel(op)
	elseif (b1) then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
		e:SetLabel(op)
	elseif (b2) then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
		e:SetLabel(op)
	else return end		
		if op==0 then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
		elseif op>0 then
		local og=c:GetOverlayGroup()
		Duel.SendtoGrave(og,REASON_COST)
		Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end


function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=e:GetLabel()
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif op>0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	if b1 and opt==0 then
		--To hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #tc>0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleDeck(tp)
		end
	end
	if b2 and opt>0 then
		--Special Summon 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    -- Check if the summoning card or its source is a "0x29f" card
    return not c:IsSetCard(0x29f) and (sumtype&SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL and not se:GetHandler():IsSetCard(0x29f)
end
