--Scripted by IanxWaifu
--Shio to Suna ★ Just Deserts!
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Pendulum Place bfgy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
end

function s.chkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x12F0) and c:GetLeftScale()>=4
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_PZONE,0,nil)
    local max_remove=math.min(100,g:GetSum(Card.GetLeftScale))
    local max_ct=math.floor(max_remove/4)
    local target_ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    local ct=math.min(max_ct,math.floor(target_ct))
    if chk==0 then return #g>0 and ct>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,0,0)
end


function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_PZONE,0,nil)
    local max_remove=math.min(100,g:GetSum(Card.GetLeftScale))
    local max_ct=math.floor(max_remove/4)
    local target_ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    local ct=math.min(max_ct,math.floor(target_ct))
    if ct<=0 then return end
    local removed=0
    for i=1,ct do
        local select_ct=4
        local ug=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_PZONE,0,nil)
        local sg=ug:FilterSelect(tp,s.chkfilter,1,1,nil,e,tp)
        if #sg==0 then break end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LSCALE)
        e1:SetValue(-select_ct)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sg:GetFirst():RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_RSCALE)
        sg:GetFirst():RegisterEffect(e2)
        Duel.AdjustInstantly(sg:GetFirst())
        removed=removed+select_ct
        -- Prompt the player to decide if they want to continue removing counters
        if removed<ct*4 and not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then break end
    end
    if removed>0 then
        local dcount=removed/4
        local target_tc=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=target_tc:Select(tp,1,dcount,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end


--Pendlulum Place
function s.pcfilter(c)
	if c:IsLocation(LOCATION_EXTRA) and not c:IsFaceup() then return false end
	return c:IsSetCard(0x12F0) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pcfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fc0000)
		e1:SetValue(8)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
end