--Scripted by IanxWaifu
--TEST OVERLAY PROC
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Xyz
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.cfilter(c,tp)
	return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetOverlayCount(tp,1,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	
	--if not tc:IsRelateToEffect(e) or not tc:GetOverlayTarget():IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(s.thfil1,tp,LOCATION_MZONE,0,2,nil) then return end
	local g=Duel.GetOverlayGroup(tp,1,0):Select(tp,1,1,nil)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--eff 2 test
function s.costfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsSetCard(0x12D9) and c:IsType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) 
end
function s.costfilter2(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsSetCard(0x12D9) and c:IsType(TYPE_SPELL+TYPE_TRAP) 
end
function s.costfilter3(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and c:IsSetCard(0x12D9) and c:IsType(TYPE_MONSTER) 
end
function s.tfilter(c)
	return (c:IsSetCard(0x12D9) and c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0x12D9))
end
function s.mfilter1(c,mg,tp)
	return mg:IsExists(s.mfilter2,1,c,c,tp)
end
function s.mfilter2(c,c1,tp)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_OVERLAY,0,1,nil,Group.FromCards(c,c1))
end
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(nil,mg,2,2) and c:IsSetCard(0x12D9)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.tfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	local gs2=Duel.GetMatchingGroup(s.costfilter2,tp,LOCATION_SZONE,0,e:GetHandler())
	local gs3=Duel.GetMatchingGroup(s.costfilter3,tp,LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #mg>1
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_OVERLAY,0,1,nil,mg) and not (#gs3==1 and #gs2==0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local gs=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	local gs2=Duel.GetMatchingGroup(s.costfilter2,tp,LOCATION_SZONE,0,e:GetHandler())
	local gs3=Duel.GetMatchingGroup(s.costfilter3,tp,LOCATION_MZONE,0,e:GetHandler())
	local mg=Duel.GetMatchingGroup(s.tfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-2 then return end
	if #mg<=1 or (#gs3==1 and #gs2==0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local gs=Duel.SelectMatchingCard(tp,s.cosfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(gs,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	if #mg>1 then
	Duel.BreakEffect()
	local mg1=mg:FilterSelect(tp,s.mfilter1,1,1,nil,mg,tp)
	local mc=mg1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg2=mg:FilterSelect(tp,s.mfilter2,1,1,mc,mc,tp)
	mg1:Merge(mg2)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_OVERLAY,0,nil,mg1)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,mg1)
	end
end
end