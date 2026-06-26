--Scripted by Aimer
--Verdantrie - Forest of Sylvestrie Spirits
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Replace to field
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1,id)
	e6:SetTarget(s.fhtg)
	e6:SetOperation(s.fhop)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_CONTROL)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_FZONE)
	e7:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e7:SetCountLimit(1,{id,1})
	e7:SetCondition(s.ctrlcon)
	e7:SetTarget(s.ctrltg)
	e7:SetOperation(s.ctrlop)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetCountLimit(1,{id,2})
	e8:SetCondition(s.rspcon)
	e8:SetTarget(s.rsptg)
	e8:SetOperation(s.rspop)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,3))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e9:SetRange(LOCATION_FZONE)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	e9:SetCountLimit(1,{id,3})
	e9:SetCondition(s.drspcon)
	e9:SetTarget(s.drsptg)
	e9:SetOperation(s.drspop)
	c:RegisterEffect(e9)
end
s.listed_series={SET_SYLVESTRIE}

function s.tgtg(e,c)
    return c:IsSetCard(SET_SYLVESTRIE)
        and c:IsOwner(e:GetHandlerPlayer())
end

function s.fhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.fhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local op
	op=Duel.SelectEffect(tp,{true,aux.Stringid(id,5)},{true,aux.Stringid(id,6)})
	local target_player=op==1 and tp or 1-tp
	-- Handle existing field spell replacement properly
	local fc=Duel.GetFieldCard(target_player,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
	end
	-- Move card to chosen field zone
	Duel.MoveToField(c,tp,target_player,LOCATION_FZONE,POS_FACEUP,true)
end

function s.ctrlfilter(c)
	return c:IsAbleToChangeControler() and (c:GetSequence()==5 or Duel.GetLocationCount(c:GetControler(),LOCATION_FZONE)>0) and c:IsSetCard(SET_SYLVESTRIE)
end
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsOwner(tp)
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_FZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_FZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end

function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local c1=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local c2=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
	if not c1 or not c2 then return end
	if not s.ctrlfilter(c1) or not s.ctrlfilter(c2) then return end
	-- store owners + positions
	local p1=c1:GetControler()
	local p2=c2:GetControler()
	local pos1=c1:GetPosition()
	local pos2=c2:GetPosition()
	-- store original sequences (important for engine consistency)
	local seq1=c1:GetSequence()
	local seq2=c2:GetSequence()
	-- remove both field spells safely
	Duel.Remove(c1,POS_FACEUP,REASON_EFFECT)
	Duel.Remove(c2,POS_FACEUP,REASON_EFFECT)
	Duel.BreakEffect()
	-- swap re-placement
	Duel.MoveToField(c1,p1,p2,LOCATION_FZONE,pos1,true)
	Duel.MoveToField(c2,p2,p1,LOCATION_FZONE,pos2,true)
end


----Special from Owners Deck
function s.rcfilter(c)
	return c:IsRitualMonster() and c:IsSetCard(SET_SYLVESTRIE)
end
function s.rspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rcfilter,1,nil) and e:GetHandler():GetControler()==e:GetHandler():GetOwner()
end

function s.rsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,e:GetHandler():GetOwner(),LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,e:GetHandler():GetOwner(),LOCATION_DECK)
end
function s.rspfilter(c,e,tp)
	return c:IsSpellTrap() and c:IsSetCard(SET_SYLVESTRIE) and not c:IsType(TYPE_FIELD)
end
function s.rspop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(p,aux.NecroValleyFilter(s.rspfilter),p,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

---Non-Owner
function s.drspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rcfilter,1,nil) and e:GetHandler():GetControler()~=e:GetHandler():GetOwner() 
end

function s.drsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,e:GetHandler():GetOwner(),LOCATION_GRAVE)
end
function s.drspfilter(c,e,tp)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.drspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetOwner()
	if Duel.GetLocationCount(p,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(p,s.drspfilter,p,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEUP)
	end
end