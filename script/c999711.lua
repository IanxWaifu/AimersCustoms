--Dragonic Icyene Ritual
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_DRAGOCYENE),extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,stage2=s.stage2,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck,specificmatfilter=s.specificfilter,extratg=s.extratg})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
    --Place 1 "cyene" Continuous Spell/Trap on the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.tftg)
    e2:SetOperation(s.tfop)
    c:RegisterEffect(e2)
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

function s.ttfilter(c,tp)
    return c:IsSpellTrap() and (c:IsType(TYPE_CONTINUOUS) or c:IsType(TYPE_FIELD)) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsSetCard(SET_CYENE)
end

function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end

function s.tfop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,s.ttfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if not tc then return end
        local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
        if tc:IsType(TYPE_FIELD) then
        if fc then
            Duel.SendtoGrave(fc,REASON_RULE)
            Duel.BreakEffect()
        end
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    else
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

