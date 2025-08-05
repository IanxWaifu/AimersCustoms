--Kegai - Kokuka Daisosei
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_KEGAI),extrafil=s.extragroup,extraop=s.extraop,matfilter=s.matfilter,stage2=s.stage2,location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,forcedselection=s.ritcheck,extratg=s.extratg})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
     --Register destruction of monsters
    aux.GlobalCheck(s,function()
        s[0]=0
        s[1]=0
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_DESTROYED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=ge1:Clone()
        ge2:SetCode(EVENT_REMOVE)
        Duel.RegisterEffect(ge2,0)
        aux.AddValuesReset(function()
            s[0]=0
            s[1]=0
        end)
    end)
end

s.listed_series={SET_KEGAI}

function s.checkfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsOriginalType(TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER) and c:IsPreviousControler(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if s.checkfilter(tc,0) then
            local p=tc:GetPreviousControler()
            s[p]=s[p]+1
        end
        tc=eg:GetNext()
    end
end

function s.fcheck(tp,sg,fc,mg)
    return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end

function s.extragroup(e,tp,mg)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
    local rg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
    if s[tp] and s[tp]>0 and #rg>0 then
        return rg
    else return g end
end

function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    Duel.Destroy(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end

function s.matfilter(c,e)
    return c:IsDestructable(e) and c:IsOriginalType(TYPE_MONSTER) and (c:IsSetCard(SET_KIJIN) or c:IsSetCard(SET_KEGAI))
end

function s.ritcheck(e,tp,g,sc)
    return #g>=1 and aux.dncheck(g) and s.fcheck(tp,g,sc)
end

function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
    if #g>0 then
            Duel.HintSelection(g)
            Duel.BreakEffect()
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        end
    end
end


