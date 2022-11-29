function c1702.initial_effect(c)
c:EnableReviveLimit()
	--Move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1702,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c1702.seqtg)
	e1:SetOperation(c1702.seqop)
	c:RegisterEffect(e1)
	--Direct Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(c1702.dircon)
	c:RegisterEffect(e3)
	--Damage Reduce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e4:SetCondition(c1702.rdcon)
	e4:SetOperation(c1702.rdop)
	c:RegisterEffect(e4)
end
function c1702.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function c1702.seqop(e,tp,eg,ep,ev,re,r,rp)
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
function c1702.dircon(e)
	local p=1-e:GetHandlerPlayer()
	local seq=4-e:GetHandler():GetSequence()
	return Duel.GetFieldCard(p,LOCATION_MZONE,seq)==nil
end
function c1702.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function c1702.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev/2)
end