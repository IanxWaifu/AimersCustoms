--Scripted by IanxWaifu
--Iron Saga - Ruins of Reconception
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
end

s.listed_series={0x1A0}
s.listed_names={id}

function s.spfilter(c)
	return (c:IsCode(998920) or c:IsCode(998921) or c:IsCode(998922) or c:IsCode(998923)) and (c:IsAbleToDeckAsCost() and ((c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) or (c:IsFaceup() and c:IsAbleToHandAsCost())))
end
function s.rescon(checkfunc)
    return function(sg,e,tp,mg)
        return sg:CheckDifferentProperty(checkfunc) and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)~=#sg
	end
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED|LOCATION_MZONE,0,nil)
	local checkfunc=aux.PropertyTableFilter(Card.GetCode,998920,998921,998922,998923)
	if #g==g:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED) then return false end
	return aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon(checkfunc),0)
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED|LOCATION_MZONE,0,nil)
	local checkfunc=aux.PropertyTableFilter(Card.GetCode,998920,998921,998922,998923)
	local sg=aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon(checkfunc),1,tp,HINTMSG_CONFIRM,s.rescon(checkfunc),nil,true)
	if #sg > 0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if #rg>0 then
		Duel.SendtoHand(rg,nil,REASON_COST+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg) 
	end
	Duel.SendtoDeck(sg,nil,2,REASON_COST+REASON_MATERIAL+REASON_FUSION) 
	c:SetMaterial(sg)
	sg:DeleteGroup()
end