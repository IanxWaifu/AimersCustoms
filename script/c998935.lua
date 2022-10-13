--Scripted by IanxWaifu
--Iron Saga - Ruins of Reconception
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xyzconEP)
	e1:SetOperation(s.xyzopEP)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

s.listed_series={0x1A0}
s.listed_names={id}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	local p3=false
	local p4=false
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) then
			if tc:IsCode(998920) then p1=true end
			if tc:IsCode(998921) then p2=true end
			if tc:IsCode(998922) then p3=true end
			if tc:IsCode(998923) then p4=true end
		end
	end
	if p1 then Duel.RegisterFlagEffect(tp,998970,RESET_PHASE+PHASE_END,0,1) end
	if p2 then Duel.RegisterFlagEffect(tp,998971,RESET_PHASE+PHASE_END,0,1) end
	if p3 then Duel.RegisterFlagEffect(tp,998972,RESET_PHASE+PHASE_END,0,1) end
	if p4 then Duel.RegisterFlagEffect(tp,998973,RESET_PHASE+PHASE_END,0,1) end
end
--Property Checks
function s.xyzfilter(c,e,tp)
    return (c:IsCode(998920) or c:IsCode(998921) or c:IsCode(998922) or c:IsCode(998923)) and c:IsMonster() and c:IsCanBeXyzMaterial(c,tp) and ((c:IsFaceup() and c:IsLocation(LOCATION_REMOVED+LOCATION_MZONE)) or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE))
end
function s.rescon(checkfunc)
    return function(sg,e,tp,mg)
        return sg:CheckDifferentProperty(checkfunc)
    end
end

--Xyz Conditions
function s.xyzconEP(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,998970)>0 and Duel.GetFlagEffect(tp,998971)>0 and Duel.GetFlagEffect(tp,998972)>0 and Duel.GetFlagEffect(tp,998973)>0
   		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp) 
end


--Xyz Summon EP
function s.xyzopEP(e,tp,eg,ep,ev,re,r,rp,c,og)
    local c=e:GetHandler()
    local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.xyzfilter),tp,LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e,tp)
   	local checkfunc=aux.PropertyTableFilter(Card.GetCode,998920,998921,998922,998923)
    local og=aux.SelectUnselectGroup(sg,e,tp,1,4,s.rescon(checkfunc),1,tp,HINTMSG_CONFIRM,s.rescon(checkfunc))
    c:SetMaterial(og)
    Duel.RegisterFlagEffect(0,id+1,RESET_CHAIN,0,1)
    Duel.Overlay(c,og)
    Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,true,false,POS_FACEUP)
    c:CompleteProcedure()
    Duel.ShuffleHand(tp)
end