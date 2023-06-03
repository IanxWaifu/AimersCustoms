--Zodiakieri Scorpio
function c9945510.initial_effect(c)
	--spirit return
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c9945510.splimit)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,9945510)
	e2:SetCondition(c9945510.spcon)
	e2:SetOperation(c9945510.spop)
	c:RegisterEffect(e2)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9945510,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c9945510.cost)
	e3:SetTarget(c9945510.actg)
	e3:SetCountLimit(3,9945460)
	e3:SetOperation(c9945510.acop)
	c:RegisterEffect(e3)
end
function c9945510.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x12D7)
end
function c9945510.spfilter(c)
	return c:IsDestructable()
end
function c9945510.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c9945510.spfilter,c:GetControler(),LOCATION_SZONE,0,1,nil)
end
function c9945510.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c9945510.spfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function c9945510.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(9945510)==0 end
	e:GetHandler():RegisterFlagEffect(9945510,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
end
--activate
function c9945510.actfilter(c,e,tp)
	local type_spell=TYPE_SPELL
	local type_trap=TYPE_TRAP
	if not c:IsType(type_spell|type_trap) then return end
	return c:IsSetCard(0x12D7) and c:CheckActivateEffect(false,false,false)~=nil and c:IsType(TYPE_SPELL+TYPE_TRAP) and not (c:IsStatus(STATUS_SET_TURN) and c:IsType(TYPE_QUICKPLAY+TYPE_TRAP)) and not c:IsFaceup()
end
function c9945510.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
 	if loc==0 then return false end
	if chk==0 then return loc>0 and Duel.IsExistingMatchingCard(c9945510.actfilter,tp,loc,0,1,nil,e,tp) end
end
function c9945510.acop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
  	if loc==0 then return false end
    local g=Duel.GetMatchingGroup(c9945510.actfilter,tp,loc,0,nil,e,tp)
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
    e1:SetOperation(c9945510.faop)
    Duel.RegisterEffect(e1,tp)
    sc:RegisterFlagEffect(9945550,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)

end
function c9945510.faop(e,tp,eg,ep,ev,re,r,rp)
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