--Scripted by IanxWaifu
--Shio to Suna ★ Ayaka
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	Aimer.ShiotoSunaAddProcedure(c,id,s)
	--pendulum summon
	Pendulum.AddProcedure(c)
	c:EnableUnsummonable()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_REVIVE_LIMIT)
	e0:SetCondition(s.rvlimit)
	c:RegisterEffect(e0)
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.indcon)
	e3:SetOperation(s.indop)
	c:RegisterEffect(e3)
	--Reduce Target Destroy
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,4})
	e5:SetCost(s.excost)
	e5:SetTarget(s.extg)
	e5:SetOperation(s.exop)
	c:RegisterEffect(e5)
	--be material
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,5))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetCountLimit(1,{id,6})
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(s.sccon)
	e6:SetTarget(s.sctg)
	e6:SetOperation(s.scop)
	c:RegisterEffect(e6)
end
function s.excon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.rvlimit(e)
	return not e:GetHandler():IsLocation(LOCATION_HAND) and not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or ((st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and c:IsLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_PZONE) and c:IsReason(REASON_DESTROY) and c:IsFaceup())
end
function s.descon(e)
	return e:GetHandler():GetLeftScale()<=0
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsReason(REASON_BATTLE) and re and e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	--Unaffected by activated effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.unaval)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.indtg(e,c)
	return c:IsSetCard(0x12F0) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.unaval(e,te)
	local tc=te:GetOwner()
	return tc:IsSummonType(SUMMON_TYPE_SPECIAL) and tc:IsSummonLocation(LOCATION_EXTRA) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end


function s.exfilter(c,lv)
	return c:IsFaceup() and c:GetLeftScale()>=lv
end
function s.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lv=e:GetHandler():GetLevel()
	local rg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_PZONE,0,nil,lv)
	if chk==0 then return #rg>0 end
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_ADJUST,nil,nil,true)
	if #g>0 then
	local tc=g:GetFirst()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(-c:GetLevel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	tc:RegisterEffect(e2)
	end
end
function s.exfilter2(c)
	return c:IsAbleToHand()
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.exfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.exfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.exfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end





function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount() and not e:GetHandler():IsReason(REASON_RETURN) 
end
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	local c=e:GetHandler()
	return rc:IsSetCard(0x12F0)
end
function s.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12F0)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_PZONE,0,nil)
	if chk==0 then return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_ADJUST,nil,nil,true)
	if #g>0 then
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	local t={}
	local p=1
	for i=1,2 do
		if i then
			t[p]=i
			p=p+1
		end
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(ac)
end
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ac=e:GetLabel()
	local op=0
	if tc:GetLeftScale()==0 and ac>0 then
	--Force Positive
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(ac)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	tc:RegisterEffect(e2)
	--Force Negative
	elseif tc:GetLeftScale()==1 and ac==2 then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(ac)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	tc:RegisterEffect(e2)
	--Optional
elseif not (tc:GetLeftScale()==1 and ac==2) and not (tc:GetLeftScale()==0 and ac>0) then
	local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_LSCALE)
	if op==0 then
		e3:SetValue(ac)
		else e3:SetValue(-ac) end
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_RSCALE)
	tc:RegisterEffect(e4)
	end
end