local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	--Xyz Mat
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atctg)
	e1:SetOperation(s.atcop)
	c:RegisterEffect(e1)
	--Xyz Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	c:RegisterEffect(e2)
end
	
s.listed_series={0x12D9}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x12D9,lc,sumtype,tp)
end
function s.atcfilter(c,lg)
	return not lg:IsContains(c) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x12D9)
end
function s.atcgyfilter(c)
	return c:IsSetCard(0x12D9)
end
function s.atctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	lg:AddCard(c)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.atcgyfilter,tp,LOCATION_GRAVE,0,1,nil)
	 and Duel.IsExistingTarget(s.atcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.atcgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local g=Duel.SelectTarget(tp,s.atcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg)
	e:SetLabelObject(g:GetFirst())
end
function s.atcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local sc=e:GetLabelObject()
	if sc:IsRelateToEffect(e) and sc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(sc,tc,true)
	end
end


function s.filter1(c,e,tp,lg,zones)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and c:IsFaceup() and c:IsSetCard(0x12D9)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode(),pg,zones) and lg:IsContains(c)
end
function s.filter2(c,e,tp,mc,code,pg,zones)
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x12D9) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,~zones)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local zone={}
	lg:AddCard(c)
	zone[0]=c:GetLinkedZone(0)&0x1f
	zone[1]=c:GetLinkedZone(1)&0x1f
	local zones=nil
	local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_EMZONE,0,nil)
	if (c:IsInExtraMZone() and #dg==0) or (c:IsInMainMZone() and #dg>0) then
		zones=zone[tp]+0x60
	else
		zones=zone[tp]
	end
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp,lg) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,~zones)>0
	and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp,lg,zones) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp,lg,zones)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	local zone={}
	zone[0]=c:GetLinkedZone(0)&0x1f
	zone[1]=c:GetLinkedZone(1)&0x1f
	local zones=nil
	local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_EMZONE,0,nil)
	if (c:IsInExtraMZone() and #dg==0) or (c:IsInMainMZone() and #dg>0) then
		zones=zone[tp]+0x60
	else
		zones=zone[tp]
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE,~zones)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode(),pg,zones)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP,~zones)
		sc:CompleteProcedure()
	end
end
