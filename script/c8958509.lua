--Vylon Beta
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x30),1,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x30),1,99)
	c:EnableReviveLimit()
	--Equip destroyed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Cost Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.lpcostval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_ACTIVATE_COST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chkc then return chkc==tc end
	if chk==0 then
		return tc and tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_MONSTER)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and tc:IsCanBeEffectTarget(e)
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,tc,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	if not tc or not tc:IsLocation(LOCATION_GRAVE) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Equip(tp,tc,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	-- ATK +500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	-- DEF +500 (clone)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e3)
	-- Treated as "Vylon"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetValue(0x30) -- Vylon setcode
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e4)
end
function s.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end


function s.lpcostval(e,re,rp,val)
	if not re then return val end
	local rc=re:GetHandler()
	if re:IsMonsterEffect() and rc:IsSetCard(SET_VYLON)  then return 0 end
	return val
end

function s.GetTotalActivateCost(tp,te)
	local LP_COSTS={[74064212]=500,[38679204]=500,[1281505]=500,[75886890]=500,[8958505]=500,[8958507]=1000}
    local total=LP_COSTS[te:GetHandler():GetCode()] or 0
    for _,eff in ipairs(Duel.GetPlayerEffect(tp,EFFECT_ACTIVATE_COST)) do
        local h=eff:GetHandler()
        local extra=LP_COSTS[h:GetCode()]
        if extra then total=total+extra end
    end
    return total
end

function s.lptg(e,te,tp)
    local lp=s.GetTotalActivateCost(tp,te)
    if lp>0 then e:SetLabel(lp) return true end
    return false
end

function s.lpop(e,tp)
    local lp=e:GetLabel() or 0
    if lp>0 then Duel.Recover(tp,lp,REASON_EFFECT) end
end


function s.repfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_EQUIP) and c:IsDestructable()
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if Duel.GetFlagEffect(tp,id)~=0 then return false end
    if chk==0 then
        if (r & REASON_EFFECT)==0 then return false end
        return Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_SZONE,0,1,nil)
    end
    if Duel.SelectEffectYesNo(tp,c,96) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_SZONE,0,1,1,nil)
        if #g>0 then
            e:SetLabelObject(g:GetFirst())
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
            return true
        end
    end
    return false
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
    end
end

