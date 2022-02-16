--Scripted by IanxWaifu
--Revelatia - Aegra Astra
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.spcon)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Custom Fusion Activation
	local e3=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsCode,32775808),matfilter=s.matfil,extrafil=s.extrafilter,extraop=s.extraop})
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	AshBlossomTable=AshBlossomTable or {}
	table.insert(AshBlossomTable,e1)
end
--Cannot SPSummon from Extra, except "Revelatia"
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x19f)
end
--Cannot Extra Deck SP
function s.spcost(e,tc,tp,sg,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x19f)
end

--Special Summon from Hand
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x19f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Material Check
function s.matfil(c,e,tp,chk)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE) and c:IsAbleToRemove()
end
function s.filter(c)
	return (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE)) or (c:IsAbleToGrave() and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA))
end

--Flag Check for 1 Deck Material and Gy banish
function s.checkmat(tp,sg,fc)
	return fc:IsType(TYPE_FUSION) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
function s.duelfcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1 and sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fcheck2(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end

function s.extrafilter(e,tp,mg)
	if Duel.GetFlagEffect(tp,998858)>0 and Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) then
		local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA,0,nil)
		if eg and #eg>0 then
			return eg,s.duelfcheck
		end
	end
	if Duel.GetFlagEffect(tp,998858)>0 then
		local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	if Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) then
		local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck2
		end
	end
	return Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,nil)
end



--Remove Materials
function s.extraop(e,tc,tp,sg)
	local tg=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #tg>0 and Duel.GetFlagEffect(tp,998858)>0 then
	Duel.ResetFlagEffect(tp,998858) end
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_HAND+LOCATION_MZONE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end