--Scripted by IanxWaifu
--Necroticrypt Soulweaver
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),1,2)
	c:EnableReviveLimit()
	--Gains ATK/DEF equal to the total ATK/DEF of the "Zoodiac" monsters attached
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
	--decrease atk/def
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(-1000)
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- Special Summon Xyz Material and negate effect
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id)
    e5:SetCost(s.spcost)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
    --attach
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCountLimit(1)
	e6:SetTarget(s.attachtg)
	e6:SetOperation(s.attachop)
	c:RegisterEffect(e6)
end

s.listed_names={id}
s.listed_series={0x29f,0x129f}

function s.oppfilter(c,tp)
    return c:GetOwner()~=tp
end
function s.statcon(e,tp,eg,ep,ev,re,r,rp)
    local mg=e:GetHandler():GetOverlayGroup()
    return mg:IsExists(s.oppfilter,1,nil,e:GetHandlerPlayer())
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

function s.atlimit(e,c)
	return c~=e:GetHandler()
end

-- Define the custom targeting function
function s.atktg(e, c)
    local g = e:GetHandler():GetOverlayGroup()
    local races = {} -- Store the races of Xyz Materials
    for tc in aux.Next(g) do
        table.insert(races, tc:GetRace()) -- Store the race of each Xyz Material
    end
    local targetRace = c:GetRace() -- Get the race of the target card
    -- Check if any of the stored races matches the target race
    for _, race in ipairs(races) do
        if race == targetRace then
            return true -- If a match is found, return true
        end
    end
    return false -- If no match is found, return false
end



function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

--Select an Xyz Material to Special Summon and negate the effect
function s.xyzcheck(c,e,tp)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():GetOverlayGroup():IsExists(s.xyzcheck,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local matg=c:GetOverlayGroup()
    local tg=matg:FilterSelect(tp,s.xyzcheck,1,1,nil,e,tp)
    local tc=tg:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Banish it if it leaves the field
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(3300)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e0:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e0:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e0)
		if not tc:GetOwner()==1-tp then return end
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(0x129f)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_ZOMBIE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
    end
end

function s.attachfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.attachfilter(chkc) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end