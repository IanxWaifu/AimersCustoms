--Scripted by Aimer
--Sylvestrie Naturanthis
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Negate the activation of a card or effect, then destroy it depending
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Swap Field Spells
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.ctrltg)
	e2:SetOperation(s.ctrlop)
	c:RegisterEffect(e2)
	local rparams={filter=aux.FilterBoolFunction(aux.NecroValleyFilter(s.ritfilter)),lvtype=RITPROC_GREATER,extrafil=s.extragroup,matfilter=s.matfilter,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck,extratg=s.extratg}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.rittg(Ritual.Target(rparams),Ritual.Operation(rparams)))
    e3:SetOperation(s.ritop(Ritual.Target(rparams),Ritual.Operation(rparams)))
    c:RegisterEffect(e3)
    local e3b=e3:Clone()
	e3b:SetCode(EVENT_PHASE+PHASE_DRAW)
	c:RegisterEffect(e3b)
end

s.listed_series={SET_SYLVESTRIE}


function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SYLVESTRIE),tp,LOCATION_FZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.NegateActivation(ev) then return end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SYLVESTRIE),tp,0,LOCATION_FZONE,1,nil) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.ctrlfilter(c)
	return c:IsAbleToChangeControler() and (c:GetSequence()==5 or Duel.GetLocationCount(c:GetControler(),LOCATION_FZONE)>0)
end

function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctrlfilter,tp,LOCATION_FZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_FZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end

function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local c1=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local c2=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
	if not c1 or not c2 then return end
	if not s.ctrlfilter(c1) or not s.ctrlfilter(c2) then return end
	local p1=c1:GetControler()
	local p2=c2:GetControler()
	local pos1=c1:GetPosition()
	local pos2=c2:GetPosition()
	local seq1=c1:GetSequence()
	local seq2=c2:GetSequence()
	Duel.Remove(c1,POS_FACEUP,REASON_EFFECT)
	Duel.Remove(c2,POS_FACEUP,REASON_EFFECT)
	Duel.BreakEffect()
	local r1=Duel.MoveToField(c1,p1,p2,LOCATION_FZONE,pos1,true)
	local r2=Duel.MoveToField(c2,p2,p1,LOCATION_FZONE,pos2,true)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,c:GetCode())
	if r1~=0 and r2~=0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local dg=g:Select(tp,1,1,nil)
		Duel.HintSelection(dg)
		Duel.SendtoHand(dg,nil,REASON_EFFECT)
	end
end

function s.thfilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsAbleToHand() and not c:IsCode(id)
end

-----------Ritual Summon-------------
-- Extra group for ritual summoning

function s.ritfilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsLevelBelow(7)
end

function s.extragroup(e,tp,mg)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,e,tp)
    	if #g>0 then return g
    end
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,e:GetHandler(),1,tp,LOCATION_MZONE)
end

function s.matfilter(c,e,tp)
    return c:IsReleasableByEffect() and c==e:GetHandler()
end

function s.ritcheck(e,tp,g,sc)
    local c=e:GetHandler()
    return #g==1 and g:GetFirst()==c and s.fcheck(tp,g,sc)
end

function s.fcheck(tp,sg,fc)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
end

function s.rittg(rittg,ritop)
    return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if chk==0 then return rit end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
    end
end

function s.ritop(rittg,ritop)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
        if rit then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            ritop(e,tp,eg,ep,ev,re,r,rp)
        end
    end
end