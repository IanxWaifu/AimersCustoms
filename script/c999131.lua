--Scripted by IanxWaifu
--Wizardrake Taliesin the Periapt
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x12A7),1,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),1)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	--Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	--cannot be target
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.ctg)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
s.listed_series={0x12A7}
s.listed_names={id}

function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0 and sg:IsExists(s.cchk1,1,nil,sg,tp)
end
function s.cchk1(c,sg,tp)
	return c:IsSetCard(0x12A7) and c:IsControler(tp) and c:IsOriginalType(TYPE_MONSTER) and sg:IsExists(s.cchk2,1,nil,sg,tp)
end
function s.cchk2(c,sg,tp)
	return c:IsRace(RACE_DRAGON) and c:IsOriginalType(TYPE_MONSTER) and sg:FilterCount(s.cchk3,c,tp)==1 and c:IsControler(1-tp)
end
function s.cchk3(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsOriginalType(TYPE_MONSTER) and c:IsControler(1-tp)
end
function s.nfilter(c,set)
	return c:IsSetCard(set) and c:IsAbleToRemoveAsCost()
end
function s.cfilter(c,race)
	return c:IsRace(race) and c:IsAbleToRemoveAsCost()
end
function s.hspcon(e,c)
	local c=e:GetHandler()
	if c==nil then return true end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.nfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,c,0x12A7)
	local rg2=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_ONFIELD,c,RACE_DRAGON)
	local rg3=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_ONFIELD,c,RACE_SPELLCASTER)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	rg:Merge(rg3)
	return Duel.GetMZoneCount(tp,c)>-1 and #rg1>0 and #rg2>0 and #rg3>0 
		and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.nfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,c,0x12A7)
	rg:Merge(Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_ONFIELD,c,RACE_DRAGON))
	rg:Merge(Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_ONFIELD,c,RACE_SPELLCASTER))
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	Duel.Destroy(sg,REASON_COST+REASON_FUSION+REASON_MATERIAL)
	c:SetMaterial(sg)
	sg:DeleteGroup()
end

--Add from Deck
function s.thfilter(c)
	return (c:IsCode(999128) or c:IsCode(999116)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Send to GY
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil)  end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,1,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--Dragon Fusion Monsters cannot be targeted
function s.ctg(e,c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and c:IsFaceup() 
end


