--Scripted by IanxWaifu
--Shio to Suna ★ Lumine
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
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.addcon)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
	--Place
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,{id,4})
	e5:SetCondition(s.excon)
	e5:SetTarget(s.extg)
	e5:SetOperation(s.exop)
	c:RegisterEffect(e5)
	--Turn Summon Scale Change
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,5))
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(s.sumcon)
	e7:SetOperation(s.sumop)
	c:RegisterEffect(e7)
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
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsReason(REASON_BATTLE) and re and e:GetHandler():IsPreviousLocation(LOCATION_PZONE)
end
function s.addfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x12F0) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


function s.exfilter(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:IsSetCard(0x12F0)  and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(s.exfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.exfilter),tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end





function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount() and not e:GetHandler():IsReason(REASON_RETURN) 
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


function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,{id,5})
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
end