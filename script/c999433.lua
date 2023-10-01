--Scripted by IanxWaifu
--Necroticrypt Archdaemon, Tecuhtli
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Zombie monsters with different 
	--2 monsters
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,2,2))
	e0:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,2,2))
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetDescription(aux.Stringid(id,4))
	e0a:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,3,3))
	e0a:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,3,3))
	c:RegisterEffect(e0a)
	local e0b=e0:Clone()
	e0b:SetDescription(aux.Stringid(id,5))
	e0b:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,4,4))
	e0b:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,4,4))
	c:RegisterEffect(e0b)
	local e0c=e0:Clone()
	e0c:SetDescription(aux.Stringid(id,6))
	e0c:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,5,5))
	e0c:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,5,5))
	c:RegisterEffect(e0c)
	local e0d=e0:Clone()
	e0d:SetDescription(aux.Stringid(id,7))
	e0d:SetCondition(Fusion.ConditionMixRep(true,true,s.ffilter1,6,6))
	e0d:SetOperation(Fusion.OperationMixRep(true,true,s.ffilter1,6,6))
	c:RegisterEffect(e0d)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.statval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e3)
	-- Gain Attribute
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.spcon)
    e4:SetOperation(s.attrOperation)
    c:RegisterEffect(e4)
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_MATERIAL_CHECK)
    e5:SetValue(s.valcheck)
    e5:SetLabelObject(e4)
    c:RegisterEffect(e5)
    --Remove Attributes+Send
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id)
	e6:SetTarget(s.atttg)
	e6:SetOperation(s.attop)
	c:RegisterEffect(e6)
	--extra summon
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(s.sumcon)
	e7:SetOperation(s.sumop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCondition(s.tgcon)
	c:RegisterEffect(e8)
end
s.listed_series={0x129f,0x718}
s.listed_names={id,CARD_ZORGA}




function s.ffilter1(c,fc,sumtype,sub,mg,sg)
    return c:IsRace(RACE_ZOMBIE,fc,sumtype,fc:GetControler()) and c:GetAttribute(fc,sumtype,fc:GetControler())>0 and (not sg or #sg>0 and not sg:IsExists(s.fusfilter,1,c,c:GetAttribute(fc,sumtype,fc:GetControler()),fc,sumtype,fc:GetControler()))
end
function s.fusfilter(c,attr,fc,sumtype,sub1,sub2)
    return c:IsAttribute(attr,fc,sumtype,fc:GetControler()) 
end

--[[local ATTRIBUTES=ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND|ATTRIBUTE_DARK|ATTRIBUTE_LIGHT


function s.ffilter(c,fc,sumtype,sp,sub,mg,sg,tp)
	local g=Duel.GetMatchingGroup(s.spfilter,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return true,not g:CheckDifferentPropertyBinary(function(c)return c:GetAttribute()&(ATTRIBUTES)end)
end--]]

function s.statval(e,c)
	local attCount = Aimer.GetAttributeCount(e:GetHandler())
	return attCount*1000
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.attrOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local att = e:GetLabel()
    if att > 0 then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_ADD_ATTRIBUTE)
        e1:SetValue(att)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

function s.valcheck(e, c)
    local att = 0
    local g = c:GetMaterial()
    for tc in aux.Next(g) do
        att = bit.bor(att, tc:GetAttribute())
    end
    e:GetLabelObject():SetLabel(att)
end

function s.attcountfilter(c)
    return c:IsAbleToGrave() and c:ListsCode(999415)
end
function s.atttg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local c=e:GetHandler()
	local attCount = Aimer.GetAttributeCount(c)
	local g = Duel.GetMatchingGroup(s.attcountfilter, tp, LOCATION_EXTRA+LOCATION_DECK, 0, nil)
    if chk == 0 then
        return aux.SelectUnselectGroup(g,e,tp,1,attCount-1,aux.dncheck,0) and attCount > 1
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
end

function s.attop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local removedCount = 0
    local attCount = Aimer.GetAttributeCount(c)
    local g = Duel.GetMatchingGroup(s.attcountfilter, tp, LOCATION_EXTRA+LOCATION_DECK, 0, nil)
    if #g>0 and attCount>1 then      
	    while attCount > 1 do
	        local quickatt = c:GetAttribute()
	        -- Set the Divine attribute bit to 0
	        quickatt = quickatt & ~ATTRIBUTE_DIVINE
	        local att_to_lose = Duel.AnnounceAttribute(tp, 1, quickatt)
	        local e1 = Effect.CreateEffect(c)
	        e1:SetType(EFFECT_TYPE_SINGLE)
	        e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
	        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
	        e1:SetValue(att_to_lose)
	        c:RegisterEffect(e1)
	        Duel.AdjustInstantly(c)
	        attCount = attCount - 1
	        removedCount = removedCount + 1
	        if (attCount > 1 and not Duel.SelectYesNo(tp, aux.Stringid(id, 1))) or removedCount==#g then
	            break  -- Exit the loop if the player chooses to stop
	        end
	    end
	    local sg=aux.SelectUnselectGroup(g,e,tp,removedCount,removedCount,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	    if #sg==removedCount then
	    	Duel.SendtoGrave(sg,REASON_EFFECT)
	    end
	 end
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x29f)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCountLimit(1,{id,1})
	e1:SetOperation(s.setop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.setfilter(c)
	return c:IsSetCard(0x29f) and c:IsSpellTrap() and c:IsSSetable() and not c:IsForbidden() and not c:IsCode(id)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
	local dg=Duel.GetMatchingGroup(s.setfilter, tp, 0, LOCATION_DECK, nil)
	if #dg==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
