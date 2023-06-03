--Zodiakieri Cancer
function c9945495.initial_effect(c)
	--spirit return
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c9945495.splimit)
	c:RegisterEffect(e1)
	--Special
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9945495,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,9945495)
	e2:SetTarget(c9945495.sptg)
	e2:SetOperation(c9945495.spop)
	c:RegisterEffect(e2)
	--Set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9945495,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_NO_TURN_RESET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,9945496)
	e3:SetCondition(c9945495.setcon)
	e3:SetTarget(c9945495.settg)
	e3:SetOperation(c9945495.setop)
	c:RegisterEffect(e3)
	--Activate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9945495,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c9945495.cost)
	e4:SetTarget(c9945495.actg)
	e4:SetCountLimit(3,9945460)
	e4:SetOperation(c9945495.acop)
	c:RegisterEffect(e4)
end
function c9945495.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x12D7)
end
function c9945495.spfilter(c,e,tp)
	return c:IsSetCard(0x12D7) and not c:IsCode(9945495) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
end
function c9945495.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c9945495.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function c9945495.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9945495.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end


function c9945495.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and c~=e:GetHandler()
end
function c9945495.setfilter(c)
	return c:IsSetCard(0x12D7) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c9945495.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c9945495.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c9945495.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c9945495.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
	end
end
function c9945495.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(9945495)==0 end
	e:GetHandler():RegisterFlagEffect(9945495,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
end
--activate
function c9945495.actfilter(c,e,tp)
	local type_spell=TYPE_SPELL
	local type_trap=TYPE_TRAP
	if not c:IsType(type_spell|type_trap) then return end
	return c:IsSetCard(0x12D7) and c:CheckActivateEffect(false,false,false)~=nil and c:IsType(TYPE_SPELL+TYPE_TRAP) and not (c:IsStatus(STATUS_SET_TURN) and c:IsType(TYPE_QUICKPLAY+TYPE_TRAP)) and not c:IsFaceup()
end
function c9945495.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
 	if loc==0 then return false end
	if chk==0 then return loc>0 and Duel.IsExistingMatchingCard(c9945495.actfilter,tp,loc,0,1,nil,e,tp) end
end
function c9945495.acop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then loc=LOCATION_HAND+LOCATION_SZONE end
 	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and Duel.GetLocationCount(tp,LOCATION_FZONE)==0 then loc=LOCATION_SZONE end
  	if loc==0 then return false end
    local g=Duel.GetMatchingGroup(c9945495.actfilter,tp,loc,0,nil,e,tp)
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
    e1:SetOperation(c9945495.faop)
    Duel.RegisterEffect(e1,tp)
    sc:RegisterFlagEffect(9945550,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,0)

end
function c9945495.faop(e,tp,eg,ep,ev,re,r,rp)
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