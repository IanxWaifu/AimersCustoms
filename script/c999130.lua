--Scripted by IanxWaifu
--Wizardrake Zolvarith
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon procedure
	Fusion.AddProcMixRep(c,true,true,s.tfilter,1,99,s.ffilter)
	--destroy end phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x12A7}
s.listed_names={id}
function s.tfilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x12A7,fc,sumtype,tp)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x12A7,fc,sumtype,tp) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCountLimit(1,{id,1})
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
	local ct=e:GetHandler():GetMaterialCount()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g==0 or ct==0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.Hint(HINT_CARD,0,id)
	local sg=g:Select(tp,1,ct,nil)
	Duel.HintSelection(sg)
	Duel.Destroy(sg,REASON_EFFECT)
end