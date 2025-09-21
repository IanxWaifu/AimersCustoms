--Epithex Nyssara
--Scripted by Aimer
--Created by Grummel
local s,id=GetID()
SET_EPITHEX = 0x91AC
CARD_IGNOMA_FIRE = 96155059
function s.initial_effect(c)
	--Special Summon itself (Quick Effect) and change target's name
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsMainPhase() end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local params={s.fusfilter,aux.FALSE,s.extrafilter,nil,s.stage2}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_EPITHEX,SET_IGNOMA}

-- e1: Special Summon + change target name
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsType(TYPE_MONSTER) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		--change name to "Ignoma-Fire"
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetValue(CARD_IGNOMA_FIRE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end


--Material Check

function s.fusfilter(c,tp,race)
    return c:IsSetCard(SET_EPITHEX)
end

function s.matfil(c,e,tp,chk)
	return c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsCanBeFusionMaterial()
end

function s.filter(c,tp)
	return ((c:IsControler(tp) and c:IsLocation(LOCATION_HAND+LOCATION_MZONE)) or (c:IsControler(1-tp) and c:IsFaceup() and  c:IsLocation(LOCATION_MZONE))) and c:IsCanBeFusionMaterial()
end

function s.extrafilter(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,tp)
	if #eg>0 then
		return eg,nil
	end
	return nil
end