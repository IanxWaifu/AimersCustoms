--Kegai - Hakkai Daimetsu
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_KEGAI),extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,stage2=s.stage2,location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,forcedselection=s.ritcheck,specificmatfilter=s.specificfilter,extratg=s.extratg})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end

s.listed_series={SET_KEGAI}

function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
    --[[local newgroup=Group.CreateGroup()
    local nametable={}
    for tc in aux.Next(g) do
        local name=tc:GetCode()
        if not nametable[name] then
            nametable[name]=true
            newgroup:AddCard(tc)
        end
    end--]]
    return g
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD)
end

function s.matfilter(c)
    return c:IsAbleToRemove() and c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(SET_KEGAI)
end

function s.specificfilter(c,rc,mg,tp)
    return rc:GetLocation()~=c:GetLocation()
end

function s.ritcheck(e,tp,g,sc)
    return #g>=1 and aux.dncheck(g) 
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
    if Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
    if #g>0 then
            Duel.HintSelection(g)
            Duel.BreakEffect()
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end


