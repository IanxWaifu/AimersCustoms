--Scripted by Aimer
--Sylvestrie Anima Transcendence
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_SYLVESTRIE),extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck,extratg=s.extratg})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SYLVESTRIE}


function s.fcheck(tp,sg,fc,mg)
    return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end

function s.extragroup(e,tp,mg,fc)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
    if Duel.GetFlagEffect(tp,id)>0 then
        return g
    end
    if fc and fc:IsCode(99829475) then
        local rg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
        if #rg>0 then
            return rg
        end
    end
    return g
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if mat:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
    Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end

function s.matfilter(c,e)
    return c:IsReleasableByEffect(e) and c:IsMonster() and c:IsSetCard(SET_SYLVESTRIE)
end

function s.ritcheck(e,tp,g,sc)
    if Duel.GetFlagEffect(tp,id)>0 then
        if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
            return false
        end
    end
    return #g>=1 and aux.dncheck(g) and s.fcheck(tp,g,sc)
end