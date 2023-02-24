--Scripted by IanxWaifu
--Revelatia - Statimento
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	s.material_count=2
	s.material={998866}
	s.min_material_count=2
	s.max_material_count=3
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetDescription(aux.Stringid(id,4))
	e0:SetCondition(Fusion.ConditionMix(true,true,s.fil1,s.ffilter,s.ffilter))
	e0:SetOperation(Fusion.OperationMix(true,true,s.fil1,s.ffilter,s.ffilter))
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetDescription(aux.Stringid(id,5))
	e0a:SetCondition(Fusion.ConditionMix(true,true,s.fil1,s.fil2))
	e0a:SetOperation(Fusion.OperationMix(true,true,s.fil1,s.fil2))
	c:RegisterEffect(e0a)
	--test
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
	--Special Summon Material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
	--Set directly
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetOperation(s.regop2)
	c:RegisterEffect(e5)
end
s.listed_names={id,998866}
s.material_setcode={0x19f}
function s.fil1(c,fc,sub1,sub2)
	return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,fc:GetControler(),998866) or (sub1 and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961))
end
function s.fil2(c,fc,sumtype,sub1,sub2)
	return c:IsType(TYPE_FUSION,fc,sumtype,fc:GetControler()) 
end



function s.matfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp)
end
function s.ffilter(c,fc,sub1,sub2,mg,sg,sumtype)
	return c:IsSetCard(0x19f,fc,sumtype,fc:GetControler()) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,fc:GetControler()),fc,sumtype,fc:GetControler()))
end

function s.fusfilter(c,code,fc,sumtype)
	return c:IsSummonCode(fc,sumtype,fc:GetControler(),code) and not c:IsHasEffect(511002961)
end


--After Resolve Destroy
--Flag Effect
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x19f) and (c:IsType(TYPE_FUSION) or c:GetPreviousTypeOnField()&TYPE_FUSION==TYPE_FUSION)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.GetFlagEffect(tp,id)==0 
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 then return false end
	return Duel.GetFlagEffect(tp,id)>0 
end
function s.desfilter(c,e)
	return c:IsDestructable(e)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.BreakEffect()
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

--Special Summon Material
function s.spfilter(c,e,tp)
	return c:IsControler(tp) and c:IsSetCard(0x19f) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	return eg:IsExists(s.spfilter,1,nil,e,tp) 
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=eg:Filter(s.spfilter,nil,e,tp)
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tc=g:Select(tp,1,1,nil)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then 
		local c=e:GetHandler()
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
	end
	Duel.SpecialSummonComplete()
end


--Set to field
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetPreviousLocation()~=c:GetLocation() and c:IsReason(REASON_MATERIAL) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(c:GetLocation())
		e1:SetCountLimit(1,{id,2})
		e1:SetTarget(s.settg)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

function s.setfilter(c)
	return c:IsSetCard(0x19f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end