--Wizardrake Ghorgias, Prince of the Evil Eyed
--Scripted by IanxWaifu
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCost(s.pccost)
	e0:SetTarget(s.pctg)
	e0:SetOperation(s.pcop)
	c:RegisterEffect(e0)
	--Special Proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTargetRange(POS_FACEUP,0)
	e1:SetCountLimit(1,{id,1})
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetValue(4775)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,2})
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.hdexcon)
	e2:SetTarget(s.hdextg)
	e2:SetOperation(s.hdexop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,3})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--Destroy 1 card on the field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,4})
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end

--Place to opponent's Pendulum Zone
function s.pccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic()  end
end
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(1-tp,LOCATION_PZONE,0) or Duel.CheckLocation(1-tp,LOCATION_PZONE,1))
		and e:GetHandler():IsLocation(LOCATION_HAND) and not e:GetHandler():IsForbidden() end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(1-tp,LOCATION_PZONE,0) and not Duel.CheckLocation(1-tp,LOCATION_PZONE,1) and not e:GetHandler():IsLocation(LOCATION_HAND) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.MoveToField(e:GetHandler(),1-tp,1-tp,LOCATION_PZONE,POS_FACEUP,true)
end

--Special Proc
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.tgfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsCode(id)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_PZONE,LOCATION_PZONE,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_DESTROY,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
end


--Destroy "Wizardrake"
function s.hdexfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x12A7) and not c:IsCode(id)
end
function s.hdexcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.hdexfilter,nil,tp)
	return #g>0
end
function s.hdextg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #eg>0 end
		local g=eg:Filter(s.hdexfilter,nil,tp)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.hdexop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=eg:FilterSelect(tp,s.hdexfilter,1,1,nil,tp)
		if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--Search
function s.thfilter(c)
	return (c:IsSetCard(0x12A7) or c:IsSetCard(0x129)) and c:IsSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Gain Effect - Destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (tc1 and tc2 and tc1:IsSetCard(0x12A7) and tc2:IsSetCard(0x12A7)) then return false end
	local st=e:GetHandler():GetSummonType()
	return (e:GetHandler():GetSummonType()==SUMMON_TYPE_PENDULUM) or st==(SUMMON_TYPE_SPECIAL+4775)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end