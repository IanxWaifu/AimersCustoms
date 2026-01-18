--Scripted by Aimer
--Exosister Hailey
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
     --Special Summon Xyz
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_GRAVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(_,tp,_,_,_,_,_,rp)return rp==1-tp end)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_names={8958662}
s.listed_series={SET_EXOSISTER}

-- filter for search (Deck or GY)
function s.thfilter(c)
    return c:IsSetCard(SET_EXOSISTER) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.can_be_listed_with_field_monster(tp,addedcard)
    -- check if any monster you control has its code listed in addedcard's text
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return false end
    for tc in aux.Next(g) do
        local code=tc:GetCode()
        if Card.ListsCode(addedcard,code) then
            return true
        end
    end
    return false
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- select and add
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,tc)
        -- optional Special Summon it if you control a monster whose name is listed in that monster's text
        -- and if the added card can be Special Summoned
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and s.can_be_listed_with_field_monster(tp,tc) then
            if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                -- Special Summon the card from the hand
                Duel.BreakEffect()
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
                -- If you control "Exosister Lillie", gain 800 LP
                if Duel.IsExistingMatchingCard(s.ctrl_lillie,tp,LOCATION_MZONE,0,1,nil) then
                    Duel.BreakEffect()
                    Duel.Recover(tp,800,REASON_EFFECT)
                end
            end
        end
    end
end

-- check controlling "Exosister Lillie" by name (works even if you don't have its script id handy)
function s.ctrl_lillie(c)
    return c and c:GetCode()==8958662
end

function s.spfilter(c,e,tp,mc)
    return c:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(SET_EXOSISTER) and mc:IsCanBeXyzMaterial(c,tp)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        local c=e:GetHandler()
        local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
        return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
    local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
    if #pg>1 or (#pg==1 and not pg:IsContains(c)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
    if sc then
        local mg=Group.FromCards(c)
        sc:SetMaterial(mg)
        Duel.Overlay(sc,mg)
        if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
            sc:CompleteProcedure()
        end
    end
end