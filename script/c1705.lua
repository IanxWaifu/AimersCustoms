function c1705.initial_effect(c)
c:EnableReviveLimit()
	--Move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1705,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c1705.seqtg)
	e1:SetOperation(c1705.seqop)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(c1705.pcon)
	c:RegisterEffect(e2)
	--DBL Damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(c1705.pcon)
	e3:SetOperation(c1705.regop)
	c:RegisterEffect(e3)
end
function c1705.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function c1705.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=0
	if s==1 then nseq=0
	elseif s==2 then nseq=1
	elseif s==4 then nseq=2
	elseif s==8 then nseq=3
	else nseq=4 end
	Duel.MoveSequence(c,nseq)
end
function c1705.pcon(e)
	local p=1-e:GetHandlerPlayer()
	local seq=4-e:GetHandler():GetSequence()
	return Duel.GetFieldCard(p,LOCATION_MZONE,seq)
end
function c1705.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttackTarget()
	if not tc or tc==c then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(c1705.damcon)
	e1:SetOperation(c1705.damop)
	e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e1)
end
function c1705.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return e:GetHandler()==Duel.GetAttacker() and ep~=tp
end
function c1705.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end