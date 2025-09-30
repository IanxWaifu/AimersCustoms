--Scripted by Aimer
--Zefrauin
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.pdtg)
	e1:SetOperation(s.pdop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.pzcon)
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	e3:SetCost(Cost.SelfRelease)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

end
s.listed_series={SET_ZEFRA}

function s.destfilter(c)
	return c:IsSetCard(SET_ZEFRA) and c:IsFaceup()
end
function s.pdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.destfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.destfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.destfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.pdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--------------------------------
-- Pendulum: Return self + place Zefra from hand
--------------------------------
function s.cfilter(c)
	return c:IsSetCard(SET_ZEFRA)
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end

function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.pzfilter(c)
	return c:IsSetCard(SET_ZEFRA) and c:IsType(TYPE_PENDULUM) and not c:IsCode(id)
end

function s.effilter(c)
	return c:IsSetCard(SET_ZEFRA) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and not c:IsCode(id)
end
-- operation
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local sg=Duel.GetMatchingGroup(s.effilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and Duel.CheckPendulumZones(tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tg=sg:Select(tp,1,1,nil)
			Duel.HintSelection(tg,true)
			Duel.BreakEffect()
			Duel.MoveToField(tg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end

--------------------------------
-- Monster: Tribute to Pendulum Special Summon
--------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsPendulumSummoned() or c:IsNormalSummoned()) and c:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:IsSetCard(SET_ZEFRA) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_PENDULUM,tp,tp,false,false,POS_FACEUP)
	end
end