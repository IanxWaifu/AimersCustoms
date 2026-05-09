--Scripted by Aimer
--Genosynx Ubellsi
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--spirit return
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot be Special Summoned except by a "Genosynx" card effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetValue(SUMMON_TYPE_SPECIAL)
    c:RegisterEffect(e1)
    -- On Summon / Flip
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.lvcon)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e4=e2:Clone()
    e4:SetCode(EVENT_FLIP)
    c:RegisterEffect(e3)
    -- Track opponent activations this turn
	if not s.global_check then
	    s.global_check=true
	    s.opp_activated={[0]=false,[1]=false}
	    local ge1=Effect.CreateEffect(c)
	    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    ge1:SetCode(EVENT_CHAINING)
	    ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
	        s.opp_activated[rp]=true
	    end)
	    Duel.RegisterEffect(ge1,0)
	    local ge2=Effect.CreateEffect(c)
	    ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	    ge2:SetOperation(function()
	        s.opp_activated[0]=false
	        s.opp_activated[1]=false
	    end)
	    Duel.RegisterEffect(ge2,0)
	end
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}


function s.splimit(e,se,sp,st)
	--Allow only if the effect that Special Summons it is from a "Genosynx" card
	if not se then return false end
	local rc=se:GetHandler()
	return rc and rc:IsSetCard(SET_GENOSYNX)
end

--Special Proc
function s.spcfilter(c)
	return (c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_TRAP) or (c:IsType(TYPE_SPIRIT) and c:IsMonster())) and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost() and aux.SpElimFilter(c,true,true)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,e:GetHandler())
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end




function s.spfilter(c,tp)
	if not (c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_TRAP)) then return false end
	if c:IsForbidden() then return false end
	return Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK)
end

-- Change Level to 8
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:GetLevel()~=8
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    -- Apply level change
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetValue(8)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
    -- Check if opponent activated a card/effect this turn
    if not s.opp_activated[1-tp] then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,tp)
    if #g==0 then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc then
			tc:AddMonsterAttribute(TYPE_EFFECT|TYPE_SPIRIT|TYPE_TRAP)
			tc:AddMonsterAttributeComplete()
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_BEAST)
			e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
			tc:RegisterEffect(e1,true)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e3:SetValue(ATTRIBUTE_DARK)
			tc:RegisterEffect(e3,true)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CHANGE_LEVEL)
			e4:SetValue(4)
			tc:RegisterEffect(e4,true)
			local e5=e1:Clone()
			e5:SetCode(EFFECT_SET_BASE_ATTACK)
			e5:SetValue(1000)
			tc:RegisterEffect(e5,true)
			local e6=e1:Clone()
			e6:SetCode(EFFECT_SET_BASE_DEFENSE)
			e6:SetValue(1000)
			tc:RegisterEffect(e6,true)
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		end
	end
end