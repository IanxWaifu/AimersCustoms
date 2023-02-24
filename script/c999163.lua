--Scripted by IanxWaifu
--Sacred Star Relics - Grounds of the Seven
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)	
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(s.atkfilter))
	c:RegisterEffect(e3)
	--atk loss
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(s.atkfilter))
	c:RegisterEffect(e4)
	--atk loss
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
	--atkup
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,{id,1})
	e6:SetCondition(s.atkcon2)
	e6:SetCost(s.atkcost2)
	e6:SetOperation(s.atkop2)
	c:RegisterEffect(e6)
end

s.listed_names={id}
s.listed_series={0x12A8,0x12A9}


--Search
function s.filter(c)
	return (c:IsSetCard(0x12A9) or c:IsSetCard(0x12A8)) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Negate Eff Filter
function s.atkfilter(c)
	return c:GetAttack()==0 and c:IsFaceup()
end

--Lose 500
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if not d then return false end
	if a:IsControler(1-tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a:IsControler(tp) and a:IsFaceup() and a:IsSetCard(0x12A9) and a:GetControler()~=d:GetControler()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(1-tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end

function s.eqfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsFaceup() and c:IsSetCard(0x12A8)
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttackTarget()
	if not c then return false end
	if c:IsControler(1-tp) then c=Duel.GetAttacker() end
	e:SetLabelObject(c)
	return c and c~=e:GetHandler() and c:IsSetCard(0x12A9)
		and c:GetEquipGroup():FilterCount(s.eqfilter,nil)>0 and c:IsRelateToBattle()
end
function s.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetLabelObject()
	local eq=c:GetEquipGroup():Filter(s.eqfilter,nil)
	if chk==0 then return eq>0 end
	local tg=eq:Select(tp,1,1,nil)
	Duel.SendtoGrave(tg,REASON_COST)
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
	end
end
