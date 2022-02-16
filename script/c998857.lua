--Scripted by IanxWaifu
--Sidereum Temporus
local s,id=GetID()
function s.initial_effect(c)
	--Custom Fusion Activation
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsCode,32775808),matfilter=s.matfil,extrafil=s.extrafilter,stage2=s.stage2,extraop=s.extraop})
	c:RegisterEffect(e1)
	AshBlossomTable=AshBlossomTable or {}
	table.insert(AshBlossomTable,e1)
end

--Material Check
function s.matfil(c,e,tp,chk)
	return c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsAbleToGrave() or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove())
end
function s.filter(c)
	return (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)) or (c:IsAbleToGrave() and c:IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK))
end

--Flag Check for 1 Deck Material and Gy banish
function s.checkmat(tp,sg,fc)
	return fc:IsType(TYPE_FUSION) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end

function s.extrafilter(e,tp,mg)
	if Duel.GetFlagEffect(tp,998858)>0 then
		local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,nil)
end



--Remove Materials
function s.extraop(e,tc,tp,sg)
	local tg=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #tg>0 and Duel.GetFlagEffect(tp,998858)>0 then
	Duel.ResetFlagEffect(tp,998858) end
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end

--Continuous Application
function s.stage2(e,tc,tp,sg,chk)
	if chk~=0 then return end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.tgcon)
	e1:SetOperation(s.tgop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,id)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetLabelObject(tc)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	Duel.RegisterEffect(e2,tp)
end
--Send during next End Phase
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc,REASON_EFFECT)
end


--Draw 1 Card
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:IsPreviousPosition(POS_FACEUP) and not tc:IsLocation(LOCATION_EXTRA)
		and (not re or re:GetHandler()~=tc)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.BreakEffect()
	end
end