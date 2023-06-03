--Zodiakieri Aquarius
function c9945520.initial_effect(c)
	--spirit return
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c9945520.splimit)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9945520,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,9945520)
	e2:SetTarget(c9945520.target)
	e2:SetOperation(c9945520.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--Activate
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(9945520,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(c9945520.cost)
	e5:SetTarget(c9945520.actg)
	e5:SetCountLimit(3,9945460)
	e5:SetOperation(c9945520.acop)
	c:RegisterEffect(e5)
end
function c9945520.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x12D7)
end
function c9945520.cfilter1(c)
	return c:IsSetCard(0x12D7) and c:IsAbleToDeck() and c:IsAbleToHand()
end

function c9945520.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c9945520.cfilter1,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c9945520.cfilter1,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c9945520.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg1=sg:Select(tp,1,1,nil)
		local c=e:GetHandler()
		Duel.SendtoDeck(sg1,nil,2,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		sg:Sub(sg1)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c9945520.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(9945520)==0 end
	e:GetHandler():RegisterFlagEffect(9945520,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
end
--activate
function c9945520.actfilter(c,e,tp)
	local type_spell=TYPE_SPELL
	local type_trap=TYPE_TRAP
	if not c:IsType(type_spell|type_trap) then return end
	return c:IsSetCard(0x12D7) and c:CheckActivateEffect(false,false,false)~=nil and c:IsType(TYPE_SPELL+TYPE_TRAP) and not (c:IsStatus(STATUS_SET_TURN) and c:IsType(TYPE_QUICKPLAY+TYPE_TRAP)) and not c:IsFaceup()
end
function c9945520.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
 	if loc==0 then return false end
	if chk==0 then return loc>0 and Duel.IsExistingMatchingCard(c9945520.actfilter,tp,loc,0,1,nil,e,tp) end
end
function c9945520.acop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
  	if loc==0 then return false end
    local g=Duel.GetMatchingGroup(c9945520.actfilter,tp,loc,0,nil,e,tp)
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
    e1:SetOperation(c9945520.faop)
    Duel.RegisterEffect(e1,tp)
    sc:RegisterFlagEffect(9945550,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)

end
function c9945520.faop(e,tp,eg,ep,ev,re,r,rp)
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