--Scripted by IanxWaifu
--Sacred Seal- Sixth Star Relic
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={0x12A8,0x12A9}

--Apply Continuous
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--chain resolve attach
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(s.xyzcon)
	e1:SetOperation(s.xyzop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

end

--Xyz
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsControler(tp) and tc:IsSetCard(0x12A8) and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
function s.filter(c,e,tp,mc,code)
	return mc:IsAbleToGrave() and mc:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x12A9) and c:IsType(TYPE_XYZ)
end
function s.eqfilter(c)
	return c:IsSetCard(0x12A8) and not c:IsType(TYPE_XYZ)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp,tc,tc:GetCode())
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if #g<=0 or #tg<=0 or not tc or tc:IsFacedown() or not tc:IsAbleToGrave() or Duel.GetFlagEffect(tp,id)>0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.Hint(HINT_CARD,0,id)
		local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc,tc:GetCode()):GetFirst()
		if sc and #tg>0 and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		if sc and #tg>0 and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(math.ceil(tc:GetBaseAttack()/2))
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetValue(math.ceil(tc:GetBaseAttack()/2))
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e2)
				local eq=tg:Select(tp,1,1,nil):GetFirst()
				if eq and Duel.Equip(tp,eq,sc,true) then
					--Equip Limit
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_EQUIP_LIMIT)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					e1:SetValue(s.eqlimit)
					e1:SetLabelObject(sc)
					eq:RegisterEffect(e1)
				end
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end








--Equip
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount()
end
function s.eqfilter(c)
	return c:IsSetCard(0x12A8) and c:IsMonster() and not c:IsForbidden() and not c:IsType(TYPE_XYZ)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local tg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if #tg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg=tg:Select(tp,1,1,nil)
		Duel.Equip(tp,tc,sg:GetFirst())
		--Equip limit
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end