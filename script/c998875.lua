--Scripted by IanxWaifu
--Revelatia - Penumbra Mithrite
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(s.matfilter),1,aux.FilterBoolFunctionEx(s.matfilter2),1)
	--become unaffected/send
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.edescost)
	e1:SetCondition(s.edescon)
	e1:SetTarget(s.edestg)
	e1:SetOperation(s.edesop)
	c:RegisterEffect(e1)
	--Special Summon itself during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	--Leave Field Target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Disable Effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(s.discon2)
	e4:SetOperation(s.disop2)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
	--Disable Resolve
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.discon3)
	e6:SetOperation(s.disop3)
	c:RegisterEffect(e6)
end
s.listed_series={0x19f}
s.listed_names={id}
--Material Filter
function s.matfilter(c,fc,st,tp)
	return c:IsType(TYPE_FUSION)
end

function s.matfilter2(c,fc,st,tp)
	return c:IsSetCard(0x19f) and c:IsType(TYPE_FUSION)
end

function s.edescost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT+RESET_PHASE+PHASE_END,0,0)
end
function s.cdfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsSetCard(0x19f)
end
function s.edescon(e,tp,eg,ep,ev,re,r,rp)
	local category=re:GetCategory()
	local ex,tg,tc=Duel.GetOperationInfo(ev,category)
	if rp==tp then return false end
	if category==CATEGORY_DESTROY or category==CATEGORY_RELEASE or category==CATEGORY_TOGRAVE or category==CATEGORY_REMOVE or category==CATEGORY_TODECK or category==CATEGORY_TOHAND then return true end
	return ex and tg~=nil and tc+tg:FilterCount(s.cdfilter,nil,tp)-#tg>0
end
function s.edestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local category=re:GetCategory()
	local ex,tg,tc=Duel.GetOperationInfo(ev,category)
	local g=tg:Filter(s.cdfilter,nil,tp)
	Duel.SetTargetCard(g)
end
function s.edesop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if not g then return end
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_CHAIN)
		tc:RegisterEffect(e1)
	end
end





function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(id)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end




--Disable Resolve
function s.discon3(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return loc==LOCATION_GRAVE and re:GetHandler():GetFlagEffect(id)>0
end

function s.disop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end





function s.tgfilter(c,tp)
	return c:IsControler(1-tp)
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and eg:IsExists(s.tgfilter,1,nil,tp) and (rc:IsSetCard(0x19f))
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.tgfilter,nil,tp)
	if #g>0 then
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id,RESET_EVENT+0x17a0000,0,1)
		end
	end
end
