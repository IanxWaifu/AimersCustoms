--Scripted by IanxWaifu
--Daemon Belial, God’s Bane
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--Remove Attacking
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetTarget(s.rmtg2)
	e3:SetOperation(s.rmop2)
	c:RegisterEffect(e3)
end
s.listed_series={0x718,0x719}
s.listed_names={id}
s.listed_ritual_mat={999255}

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 and Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)<=1 end
end

function s.spfilter(c)
	return c:IsSetCard(0x718) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
    Duel.ConfirmDecktop(tp,5)
    if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return false end
    local g=Duel.GetDecktopGroup(tp,5):Filter(s.spfilter,nil,e,tp)
    local ct=0
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local ft=Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)
        local pz=0
        if ft==1 then pz=1 end
        if ft==0 then pz=2 end
        local sg=aux.SelectUnselectGroup(g,e,tp,1,pz,aux.dncheck,1,tp,HINTMSG_TOFIELD)
        Duel.DisableShuffleCheck()
        local pc1,pc2=sg:GetFirst(),sg:GetNext()
        if Duel.MoveToField(pc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and #sg>1 then
            Duel.MoveToField(pc2,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
        ct=1
    end
    local ac=5-ct
    if ac>0 then
        Duel.MoveToDeckBottom(ac,tp)
        Duel.SortDeckbottom(tp,tp,ac)
    end
end


--Banish PZ
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_PZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.dgfilter(c)
	return c:IsSetCard(0x719) and  c:IsSpellTrap() and not c:IsType(TYPE_FIELD)
end
function s.cfilter(c,e)
	return c:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_PZONE,0,nil)
    local dg=Duel.GetMatchingGroup(s.dgfilter,tp,LOCATION_DECK,0,nil,false)
    local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    local og=Duel.GetOperatedGroup()
    local cg=og:Filter(Card.IsLocation,nil,LOCATION_REMOVED) 
    if ct>0 and #dg>=ct and ct>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>-ct then
        if aux.SelectUnselectGroup(dg,e,tp,ct,ct,aux.dncheck,0) then
            local sg=aux.SelectUnselectGroup(dg,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SET)
            for tc in aux.Next(sg) do
                local pos = (1<<0|1<<4)
                if #sg==1 then
                    pos = 1<<og:GetFirst():GetPreviousSequence()
                end
                Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true,pos)
                tc:SetStatus(STATUS_ACTIVATE_DISABLED,false)
                tc:SetStatus(STATUS_SET_TURN,true)
                Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
                Duel.ConfirmCards(1-tp,tc)
            end
        end
    end
end


--Opponents Battling Monster
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToRemove(tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end