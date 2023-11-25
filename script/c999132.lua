--Wizardrake Condemnation
--Scripted by IanxWaifu
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:IsSetCard(0x12A7) and ((c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_HAND)) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE+LOCATION_HAND end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE+LOCATION_HAND end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,loc,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
	end
end


function s.desfilter(c,e)
    return c:IsSetCard(0x12A7) and c:IsDestructable(e) and not (c:IsAttack(0) and c:IsDefense(0)) and c:IsOriginalType(TYPE_MONSTER)
      and not (c:IsControler(1-e:GetHandlerPlayer()) and Duel.GetFieldGroupCount(1-e:GetHandlerPlayer(),LOCATION_MZONE,0) == 1 and c:IsType(TYPE_MONSTER))
end

function s.statfil(c,e)
    return c:IsFaceup() and not c:IsImmuneToEffect(e)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e) 
        and Duel.IsExistingMatchingCard(s.statfil,tp,0,LOCATION_MZONE,1,nil,e) end
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,Duel.GetMatchingGroup(s.statfil,tp,0,LOCATION_MZONE,nil,e),0,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local tg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e)
    local g=Duel.GetMatchingGroup(s.statfil,tp,0,LOCATION_MZONE,nil,e)
    if #tg>0 and #g>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 then
        local dc=Duel.GetOperatedGroup():GetFirst()
        local c=e:GetHandler()
        g:ForEach(function(tc)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(-dc:GetAttack())
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            e2:SetValue(-dc:GetDefense())
            tc:RegisterEffect(e2)
        end)
    end
end



