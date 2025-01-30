--Novalxon Parallax
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)
    --Banish
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.rmtg2)
    e2:SetOperation(s.rmop2)
    c:RegisterEffect(e2)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

function s.rmrescon(sg,e,tp,mg)
    return sg:GetCount()==2 and sg:IsExists(s.chfilter,1,nil,tp) and sg:IsExists(s.chofilter,1,nil,tp)
end
function s.chfilter(c,tp)
    return c:IsSetCard(SET_NOVALXON) and c:IsFaceup() and c:IsControler(tp)
end
function s.chofilter(c,tp)
    return c:IsControler(1-tp) and (c:IsMonster() or c:IsFacedown()) or (not c:IsStatus(STATUS_ACTIVATED) and not c:IsStatus(STATUS_CHAINING) and c:IsSpellTrap() and c:IsFaceup())
end
function s.rmfilter(c,e)
    return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
    if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rmrescon,0) end
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rmrescon,1,tp,HINTMSG_REMOVE)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end


function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg==2 then
        local g1=tg:Filter(Card.IsControler,nil,tp)
        local g2=tg:Filter(Card.IsControler,nil,1-tp)  
        local data=e:GetLabelObject()
        if #g1>0 and #g2>0 then
            Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
            local tc=g2:GetFirst()
            Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)
            tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetLabelObject(tc)
            e1:SetCountLimit(1)
            e1:SetLabel(Duel.GetTurnCount())
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetCondition(s.retcon)
            e1:SetOperation(s.retop)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
--Return next turn
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
        if g:GetFlagEffect(id)~=0 then
            return Duel.GetTurnCount()==e:GetLabel()
        else
         e:Reset()
        return false
    end
end

function s.retfilter(c)
    return c:GetFlagEffect(id)~=0
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    local seq=tc:GetPreviousSequence()
    local zone=0x1<<seq
    local p=tc:GetOwner()
    if tc:IsType(TYPE_FIELD) then
        Duel.MoveToField(tc,p,p,LOCATION_FZONE,tc:GetPreviousPosition(),true)
    else
        if seq>4 then
            Duel.SendtoGrave(tc,REASON_RULE+REASON_RETURN)
        else
            Duel.ReturnToField(tc,tc:GetPreviousPosition(),zone,p)
        end
    end
end


function s.rmfilter2(c)
    return c:IsSetCard(SET_NOVALXON) and not c:IsCode(id) and c:IsAbleToRemove()
end
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter2,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end