--Scripted by IanxWaifu
--Shio to Suna ★ Water Wading!
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.pccon)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
	--Scale Change
	aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_ADJUST)
        ge1:SetOperation(s.check_scale_change)
        Duel.RegisterEffect(ge1,0)
    	--Clear the table after each chain
	    local ge2=Effect.CreateEffect(c)
	    ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    ge2:SetCode(EVENT_CHAIN_END)
	    ge2:SetOperation(function() s.prev_scales={} end)
	    Duel.RegisterEffect(ge2,0)
    end)
end

function s.flfilter(c)
    return c:IsFaceup() and c:GetLeftScale()>=0 and c:IsSetCard(0x12F0)
end

function s.spfilter(c,e,tp,max_lv)
    return c:IsSetCard(0x12F0) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) and c:GetLevel()<=max_lv and c:IsRitualMonster()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local rg=Duel.GetMatchingGroup(s.flfilter,tp,LOCATION_PZONE,0,nil)
        if #rg==0 then return false end
        local total_scale=rg:GetSum(Card.GetLeftScale)
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,total_scale)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local rg=Duel.GetMatchingGroup(s.flfilter,tp,LOCATION_PZONE,0,nil)
    local total_scale=rg:GetSum(Card.GetLeftScale)
    if total_scale==0 then return end
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,total_scale)
    if #g>0 then
        local tc=g:GetFirst()
        local lv=tc:GetLevel()
	    local total_reduction=lv
	    if #rg==1 then
	        local trc=rg:GetFirst()
	        local max_reduce=math.min(trc:GetLeftScale(),total_reduction)
	        local reduce=max_reduce
	        if reduce>0 then
	            local e1=Effect.CreateEffect(c)
	            e1:SetType(EFFECT_TYPE_SINGLE)
	            e1:SetCode(EFFECT_UPDATE_LSCALE)
	            e1:SetValue(-reduce)
	            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	            trc:RegisterEffect(e1)
	            local e2=e1:Clone()
	            e2:SetCode(EFFECT_UPDATE_RSCALE)
	            trc:RegisterEffect(e2)
	        end
	        tc:SetMaterial(trc)
	    else
	        local remaining_reduction=total_reduction
	        -- Filter the cards in g for the one in the left pendulum zone
	        local left_trc=rg:Filter(function(c) return c:IsLocation(LOCATION_PZONE) and c:GetSequence()==0 end,nil)
	        local right_trc=rg:Filter(function(c) return c:IsLocation(LOCATION_PZONE) and c:GetSequence()==4 end,nil)
	        left_trc=left_trc:GetFirst()
	        right_trc=right_trc:GetFirst()
	        -- Get the first card that matches
	        if left_trc then
	            local left_max_reduce=math.min(left_trc:GetLeftScale(),remaining_reduction)
	            local check_max_reduce=math.min(right_trc:GetLeftScale()+1,math.max(0,remaining_reduction-right_trc:GetLeftScale()))
	            local left_choices={}
	            for i=check_max_reduce,left_max_reduce do table.insert(left_choices,i) end
	            Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
	            local left_reduce=Duel.AnnounceNumber(tp,table.unpack(left_choices))
	            if left_reduce>0 then
	                local e1=Effect.CreateEffect(c)
	                e1:SetType(EFFECT_TYPE_SINGLE)
	                e1:SetCode(EFFECT_UPDATE_LSCALE)
	                e1:SetValue(-left_reduce)
	                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	                left_trc:RegisterEffect(e1)
	                local e2=e1:Clone()
	                e2:SetCode(EFFECT_UPDATE_RSCALE)
	                left_trc:RegisterEffect(e2)
	            end
	            remaining_reduction=remaining_reduction-left_reduce
	        end
	        if right_trc and remaining_reduction>0 then
	            local right_max_reduce=math.min(right_trc:GetLeftScale(),remaining_reduction)
	            if right_max_reduce>0 then
	                local e2=Effect.CreateEffect(c)
	                e2:SetType(EFFECT_TYPE_SINGLE)
	                e2:SetCode(EFFECT_UPDATE_LSCALE)
	                e2:SetValue(-right_max_reduce)
	                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	                right_trc:RegisterEffect(e2)
	                local e3=e2:Clone()
	                e3:SetCode(EFFECT_UPDATE_RSCALE)
	                right_trc:RegisterEffect(e3)
	            end
	        end
	        --Set materials for both left and right pendulum zones if applicable
            local mg=Group.CreateGroup()
            if left_trc then mg:AddCard(left_trc) end
            if right_trc then mg:AddCard(right_trc) end
            tc:SetMaterial(mg)
	    end
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
        tc:CompleteProcedure()
    end
end

-- Table to track previous Pendulum Scales
s.prev_scales={}

function s.pcfilter(c)
    return c:IsFaceup() and c:GetLeftScale()>=0 and c:IsSetCard(0x12F0)
end

-- Detects Scale Changes and Raises a Single Event for All Affected Cards
function s.check_scale_change(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_PZONE,0,nil)
    local sg=Group.CreateGroup()
    for tc in aux.Next(g) do
        local prev_scale=s.prev_scales[tc] or tc:GetLeftScale()
        local new_scale=tc:GetLeftScale()
        if prev_scale~=new_scale then
            sg:AddCard(tc)
        end
        s.prev_scales[tc]=new_scale
    end
    if #sg>0 then
        Duel.RaiseEvent(sg,EVENT_CUSTOM+id,e,0,tp,tp,0)
    end
end

-- Condition: Ensures the event was triggered by a Pendulum Scale change
function s.pccon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.pcfilter,1,nil)
end

-- Target: Stores the group of changed scale cards
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return #eg>0 end
    e:SetLabelObject(eg)
end

-- Operation: Selects 1 and sets its scale to 0
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g or #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=nil
    if #g==1 then tc=g:GetFirst()
	else tc=g:FilterSelect(tp,Card.IsFaceup,1,1,nil):GetFirst() end
    if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LSCALE)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_RSCALE)
        tc:RegisterEffect(e2)
    end
end
