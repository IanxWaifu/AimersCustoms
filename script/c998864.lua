--Scripted by IanxWaifu
--Revelatia - Tempusaltu
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	s.material_count=2
	s.material={998865}
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
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tgcost)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Special Summon Self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--End Phase SP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.actcon)
	e3:SetOperation(s.actop)
	c:RegisterEffect(e3)
end
s.listed_names={id,998865}
s.material_setcode={0x19f}
function s.fil1(c,fc,sub1,sub2)
	return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,fc:GetControler(),998865) or (sub1 and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961))
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



--Send Cards On Field To Grave
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--Special Summon Return
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ((c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) and  c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==tp and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and (rc:IsSetCard(0x19f)) and e:GetHandler():IsPreviousLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
--Apply Continuous Effect
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCountLimit(1,{id,3})
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--Special Summon
function s.actfilter(c,e,tp)
	return c:IsSetCard(0x19f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.actop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then return false end
	if Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then 
			--Apply Continuous Send
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCategory(CATEGORY_TOGRAVE)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetCountLimit(1,{id,4})
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.drcon)
			e1:SetTarget(s.drtg)
			e1:SetOperation(s.drop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

--Send 1 "Revelatia" from Deck when Special Summoned Leaves the Field
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsPreviousPosition(POS_FACEUP) and not tc:IsLocation(LOCATION_EXTRA)
		and (not re or re:GetHandler()~=tc) and ((rp==1-tp and e:GetHandler():IsReason(REASON_EFFECT)) or (r & REASON_FUSION == REASON_FUSION))
end
function s.drfilter(c)
	return c:IsSetCard(0x19f) and c:IsAbleToGrave()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_DECK,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.drfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end