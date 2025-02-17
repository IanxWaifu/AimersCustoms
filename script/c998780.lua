--Scripted by IanxWaifu
--Girls’&’Artillery - Collapse
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.setcost)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

--Cost Tribute
function s.cfilter(c,e,ft,tp)
	return c:IsSetCard(0x12EE) and c:IsLinkMonster()
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLink(),c:GetCode()) and c:IsReleasable()
end
--Cost Tribute +1
function s.cfilter2(c,e,ft,tp)
	return c:IsSetCard(0x12EE) and c:IsLinkMonster()
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLink(),c:GetCode()) and c:IsReleasable()
end
--Special Summon Filters for Specific Link Ratings
function s.spfilter(c,e,tp,link,code)
	return c:IsSetCard(0x12EE) and c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code) and c:GetLink()==link
end
function s.spfilter2(c,e,tp,link,code)
	return c:IsSetCard(0x12EE) and c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code) and c:GetLink()==link+1
end


--ColumnGroup Check
function s.cgfilter(c)
	return c:IsSetCard(0x12EE) and c:IsLinkMonster() 
end
function s.cgfilter2(c)
	return c:IsSetCard(0x12EE) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

--Choice Eff
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=e:GetHandler():GetColumnGroup()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,ft,tp)
	local b2=Duel.CheckReleaseGroup(tp,s.cfilter2,1,nil,e,ft,tp) and cg:IsExists(s.cgfilter,1,nil)
	if chk==0 then return b1 and ft>-1 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end




function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	cg:AddCard(c)
	if e:GetLabel()==2 then return end
	if e:GetLabel()==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local rg=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,ft,tp)
		e:SetLabelObject(rg:GetFirst())
		local rt=Duel.Release(rg,REASON_EFFECT)
		if rt==0 then return end
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabelObject():GetLink(),e:GetLabelObject():GetCode())
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local rg=Duel.SelectReleaseGroup(tp,s.cfilter2,1,1,nil,e,ft,tp)
		e:SetLabelObject(rg:GetFirst())
		local rt=Duel.Release(rg,REASON_EFFECT)
		if rt==0 then return end
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabelObject():GetLink(),e:GetLabelObject():GetCode())
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if cg:IsExists(s.cgfilter2,1,nil) then
	c:CancelToGrave()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_LINK) and rc:IsSetCard(0x12EE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
	and e:GetHandler():IsType(TYPE_CONTINUOUS)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.setfilter(c)
	return c:IsSetCard(0x12EF) and c:IsSSetable() and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g:GetFirst())~=0 then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		g:GetFirst():RegisterEffect(e1,true)
	end
end