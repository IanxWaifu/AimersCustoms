--Scripted by IanxWaifu
--Girls’&’Artillery - StrikeZone
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e2:SetValue(s.tg)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetLabelObject(e3)
	e4:SetCondition(s.secon)
	e4:SetTarget(s.setg)
	e4:SetOperation(s.seop)
	c:RegisterEffect(e4)
	--register when a card leaves the field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--if leaves the field draw
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(s.drcon)
	e5:SetTarget(s.drtg)
	e5:SetOperation(s.drop)
	c:RegisterEffect(e5)
end





function s.lvfdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetMutualLinkedGroupCount()>0 and c:IsSetCard(0x12EE)
end
--[[function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.lvfdfilter,1,nil) then
		local tc=eg:GetFirst()
		for tc in aux.Next(eg) do
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end--]]

function s.lvfdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetMutualLinkedGroupCount()>0 and c:IsSetCard(0x12EE)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsLocation(LOCATION_MZONE) and tc:GetMutualLinkedGroupCount()>0 and tc:IsSetCard(0x12EE) then
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end


--Condition Filter and Groups
function s.sefilter(c,e,tp)
	return c:IsSetCard(0x12EE) and c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetFlagEffect(id)>0
end
function s.secon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sefilter,1,nil,e,tp)
end

-- Reset Flag Effect if Condition is not met
function s.resetflageffect(eg)
	for tc in aux.Next(eg) do
		if tc:GetFlagEffect(id)>0 then
			tc:ResetFlagEffect(id)
		end
	end
end

-- Set Target
function s.setg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local conditionchk = Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		if not conditionchk then
			s.resetflageffect(eg)
		end
		return conditionchk
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,1)
end

--Special Summon
function s.seop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=eg:FilterSelect(tp,aux.NecroValleyFilter(s.sefilter),1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
	end
end


function s.tg(e,c)
	local lg=c:GetMutualLinkedGroupCount() 
	if lg>=1 then lg=lg+1 end
	return lg*200
end


function s.drfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(0x12EF) and c:GetPreviousTypeOnField()&TYPE_CONTINUOUS~=0
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drfilter,1,nil,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
