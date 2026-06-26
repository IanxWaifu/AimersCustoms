--Scripted by Aimer
--Sylvestrie Anima Transcendence
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_SYLVESTRIE),extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck,extratg=s.extratg})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	c:RegisterEffect(e1)
	--Return to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rthcon)
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SYLVESTRIE}
s.listed_names={id,99829475}


function s.fcheck(tp,sg,fc)
    local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
    if not fc:IsCode(99829475) or Duel.GetFlagEffect(tp,id)>0 then
        return ct==0
    end
    return ct<=2
end

function s.extragroup(e,tp,mg)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
    --Deck materials (only if flag not active)
    if Duel.GetFlagEffect(tp,id)==0 then
        local rg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil,e)
        g:Merge(rg)
    end
    return g
end

function s.matcheck(tp,sg,fc)
    -- If not Naturanthis, forbid Deck materials
    if not fc:IsCode(99829475) then
        if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
            return false
        end
    end
    if Duel.GetFlagEffect(tp,id)>0 then
        if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
            return false
        end
    end
    return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if mat:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
    Duel.ReleaseRitualMaterial(mat,true)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end

function s.matfilter(c,e)
    return c:IsReleasableByEffect(e) and c:IsMonster() and c:IsSetCard(SET_SYLVESTRIE) and c:IsCanBeRitualMaterial()
end

function s.ritcheck(e,tp,g,sc)
    if not sc:IsCode(99829475) then
        if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
            return false
        end
    end
    if Duel.GetFlagEffect(tp,id)>0 then
        if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
            return false
        end
    end
    return #g>=1 and aux.dncheck(g) and s.fcheck(tp,g,sc)
end


--Return to hand
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rp==1-tp and re:IsActiveType(TYPE_FIELD) and rc and rc:IsLocation(LOCATION_FZONE)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end