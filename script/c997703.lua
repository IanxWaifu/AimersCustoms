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
	e2:SetCondition(s.spcon)
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
	local g1=Duel.SelectTarget(tp,s.atcgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g2=Duel.SelectTarget(tp,s.atcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg)
end
function s.atcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg~=2 then return end
	local xyz=nil
	local mat=nil
	for tc in tg:Iter() do
		if tc:IsLocation(LOCATION_GRAVE) then
			mat=tc
		elseif tc:IsLocation(LOCATION_MZONE) then
			xyz=tc
		end
	end
	if not xyz or not mat then return end
	if xyz==mat then return end
	if xyz:IsRelateToEffect(e) and xyz:IsFaceup()
		and mat:IsRelateToEffect(e)
		and not mat:IsImmuneToEffect(e) then
		Duel.Overlay(xyz,mat,true)
	end
end


function s.filter1(c,e,tp,lg,zones)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and c:IsFaceup() and c:IsSetCard(0x12D9)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode(),pg,zones) and lg:IsContains(c)
end
function s.filter2(c,e,tp,mc,code,pg,zones)
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x12D9) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c,zones)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.spcon(e)
	return e:GetHandler():GetSequence()>4
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	lg:AddCard(c)
	local zone={}
	zone[0]=c:GetLinkedZone(0)
	zone[1]=c:GetLinkedZone(1)
	local zones=c:GetLinkedZone(tp)
	local otherzones=~zones
	-- If player already controls an EMZ monster, block both EMZs
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLocation,LOCATION_EMZONE),tp,LOCATION_EMZONE,0,1,nil) then
	    otherzones = otherzones & (~0x60) 
	end
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp,lg) end
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,nil,nil,~otherzones)>0 and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp,lg,otherzones) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp,lg,otherzones)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	local zone={}
	zone[0]=c:GetLinkedZone(0)
	zone[1]=c:GetLinkedZone(1)
	local zones=c:GetLinkedZone(tp)
	local otherzones=~zones
	-- If player already controls an EMZ monster, block both EMZs
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLocation,LOCATION_EMZONE),tp,LOCATION_EMZONE,0,1,nil) then
	    otherzones = otherzones & (~0x60) 
	end
	if Duel.GetLocationCountFromEx(tp,tp,tc,nil,~otherzones)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode(),pg,otherzones)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP,otherzones)
		sc:CompleteProcedure()
	end
end

