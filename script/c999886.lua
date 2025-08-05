--Kegai - Hakkai Daimetsu
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustFirstBeRitualSummoned()
	--Target banished "Kegai", add/Special
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e,tp) return e:GetHandler():IsRitualSummoned() and s[tp]==0 end)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thsptg)
	e2:SetOperation(s.thspop)
	c:RegisterEffect(e2)
	--Special Summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(function(e,tp) return s[tp]==0 end)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(function(e,tp) return e:GetHandler():IsRitualSummoned() and s[tp]>0 end)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.thsptg)
	e5:SetOperation(s.thspop)
	c:RegisterEffect(e5)
	--Special Summon itself
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(function(e,tp) return s[tp]>0 end)
	e6:SetCountLimit(1,{id,1})
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e7)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
end

s.listed_names={id}
s.listed_series={SET_KEGAI}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsCode(999887) and (tc:GetSummonType()&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL then
			local p=tc:GetSummonPlayer()
			s[p]=s[p]+1
		end
		tc=eg:GetNext()
	end
end

function s.thspfilter(c,e,tp,ft)
	return c:IsSetCard(SET_KEGAI) and c:IsMonster() and c:IsFaceup()
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thspfilter(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.thspfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.thspfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,ft)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	aux.ToHandOrElse(tc,tp,
		function()
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2) --"Special Summon it"
	)
end

function s.plfilter(c)
	return c:IsSetCard(SET_KEGAI) and not c:IsForbidden() and c:IsMonster()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) 
	and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_GRAVE|LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_GRAVE|LOCATION_HAND|LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        Duel.BreakEffect()
        Duel.Destroy(g,REASON_EFFECT)
    end
end