--Scripted by IanxWaifu
--Necroticrypt Wraithwalker
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),3,2)
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
	--Limit battle target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(s.atlimit)
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)
    --destroy
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BATTLE_CONFIRM)
    e4:SetCountLimit(1,id)
    e4:SetCondition(s.descon)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
	--attach
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetTarget(s.attachtg)
	e5:SetOperation(s.attachop)
	c:RegisterEffect(e5)
end

s.listed_series={0x129f,0x29f}
s.listed_names={id}

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

function s.atktg(e, c)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup()
    local races = {} -- Store the races of Xyz Materials
    for tc in aux.Next(g) do
        table.insert(races, tc:GetRace()) -- Store the race of each Xyz Material
    end
    local target = Duel.GetAttacker() or Duel.GetAttackTarget()
    if target and target:IsControler(1 - e:GetHandlerPlayer()) and target:IsFaceup() then
        local targetRace = target:GetRace() -- Get the race of the target card
        -- Check if any of the stored races matches the target race
        for _, race in ipairs(races) do
            if race == targetRace then
                return true -- If a match is found, return true
            end
        end
    end
    return false -- If no match is found, return false
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local check=c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,bc:GetRace())
	if not bc or not check or c:GetFlagEffect(id)~=0 then return end
	if not e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) and bc:IsDestructable() then
	Duel.Hint(HINT_CARD,0,id) 
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		if Duel.Destroy(bc,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_DETACH_MATERIAL,e,0,0,0,0)
		end
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