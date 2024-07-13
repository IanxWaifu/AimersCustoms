--Dragonic Icyene Ritual
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_DRAGOCYENE),extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,stage2=s.stage2,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck,specificmatfilter=s.specificfilter,extratg=s.extratg})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end

s.listed_series={SET_ICYENE,SET_DRAGOCYENE}

function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
    local newgroup=Group.CreateGroup()
    local nametable={}
    for tc in aux.Next(g) do
        local name=tc:GetCode()
        if not nametable[name] then
            nametable[name]=true
            newgroup:AddCard(tc)
        end
    end
    return newgroup
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.matfilter(c)
    return c:IsAbleToGrave() and c:IsMonster() and c:IsSetCard(SET_ICYENE)
end

function s.specificfilter(c,rc,mg,tp)
    return s.checksum(mg,rc:GetLevel())
end

function s.ritcheck(e,tp,g,sc)
    local tuners=g:FilterCount(Card.IsType,nil,TYPE_TUNER)
    return tuners==1 and #g>=2 and aux.dncheck(g)
end

function s.checksum(mg,level)
    for n=2,mg:GetCount() do
        if mg:CheckWithSumEqual(Card.GetLevel,level,n,n,aux.dncheck) then
            return true
        end
    end
    return false
end


function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
   tc:AddCounter(COUNTER_ICE,1)
end