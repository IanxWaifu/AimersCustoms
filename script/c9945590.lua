--Zodiakieri of the Eclipse
function c9945590.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
  	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	--ExRitual
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_REMOVE_TYPE)
	e1:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED+LOCATION_OVERLAY)
	e1:SetValue(TYPE_FUSION)
	c:RegisterEffect(e1)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9945590,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c9945590.setcon)
	e2:SetTarget(c9945590.settg)
	e2:SetOperation(c9945590.setop)
	e2:SetCountLimit(1,9945590)
	c:RegisterEffect(e2)
	
	--return to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9945590,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,9945591)
	e3:SetTarget(c9945590.thtg)
	e3:SetOperation(c9945590.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	c:RegisterEffect(e4)
	
	
	--Activate Spell/Trap
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(9945590,2))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(c9945590.actg)
	e5:SetCountLimit(1,9945592)
	e5:SetOperation(c9945590.acop)
	c:RegisterEffect(e5)
	--return
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c9945590.retreg)
	c:RegisterEffect(e6)
end
function c9945590.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0x1ee0000+RESET_PHASE+PHASE_END)
	e1:SetCondition(c9945590.retcon)
	e1:SetTarget(c9945590.rettg)
	e1:SetOperation(c9945590.retop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	c:RegisterEffect(e2)
end

c9945590.ritual_material_required=1

function c9945590.setfilter(c)
	return c:IsSetCard(0x12D7) and c:IsSSetable()
end
function c9945590.setcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end

function c9945590.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function c9945590.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,10,nil)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	local dc=g:GetCount()
	local dg=math.floor(dc/5)
	if dg>2 and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 then dg=2 end
	if dg~=0 and Duel.IsExistingMatchingCard(c9945590.setfilter,tp,LOCATION_DECK,0,1,nil)~=0
		and Duel.SelectYesNo(tp,aux.Stringid(9945590,1)) then
			Duel.BreakEffect()
			local tg=Duel.SelectMatchingCard(tp,c9945590.setfilter,tp,LOCATION_DECK,0,1,dg,nil)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			Duel.SSet(tp,tg)
			Duel.ConfirmCards(1-tp,tg)
	end
end
function c9945590.thfilter(c)
	return c:IsAbleToHand() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c9945590.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9945590.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(c9945590.thfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetChainLimit(c9945590.chlimit)
end
function c9945590.chlimit(e,ep,tp)
	return tp==ep
end
function c9945590.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,c9945590.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end



--activate
function c9945590.actfilter(c,e,tp)
	local type_spell=TYPE_SPELL
	local type_trap=TYPE_TRAP
	if not c:IsType(type_spell|type_trap) then return end
	return c:IsSetCard(0x12D7) and c:GetActivateEffect():IsActivatable(tp,true,true) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsFaceup()
end
function c9945590.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
 	if loc==0 then return false end
	if chk==0 then return loc>0 and Duel.IsExistingMatchingCard(c9945590.actfilter,tp,loc,0,1,nil,e,tp) end
end
function c9945590.acop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
  	if loc==0 then return false end
    local g=Duel.GetMatchingGroup(c9945590.actfilter,tp,loc,0,nil,e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    --activate
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_CHAIN_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(sc)
    e1:SetOperation(c9945590.faop)
    Duel.RegisterEffect(e1,tp)
    sc:RegisterFlagEffect(9945550,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)

end
function c9945590.faop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local te=tc:GetActivateEffect()
    local tep=tc:GetControler()
    if not te then return end
	local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if pre[1] then
		for i,eff in ipairs(pre) do
			local prev=eff:GetValue()
			if type(prev)~='function' or prev(eff,te,tep) then return end
		end
	end
	if tc:GetFlagEffect(9945550)==0 then return false end
	if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep) then
        Duel.Activate(te)
        Duel.BreakEffect()
        tc:ResetFlagEffect(9945550)
    end
    e:Reset()
end
