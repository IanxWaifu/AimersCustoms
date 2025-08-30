--Epithex Scriting
local s,id=GetID()
SET_EPITHEX = 0x91AC
function s.initial_effect(c)
	local params={s.fusfilter,aux.FALSE,s.extrafilter,nil,s.stage2}
	--Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsMainPhase() end)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
	-- Add this card back to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_EPITHEX,SET_IGNOMA}

--Material Check
function s.fusfilter(c,tp,race)
    return c:IsSetCard(SET_EPITHEX)
end

function s.matfil(c,e,tp,chk)
	return c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsCanBeFusionMaterial()
end

function s.filter(c,tp)
	return ((c:IsControler(tp) and c:IsLocation(LOCATION_HAND+LOCATION_MZONE)) or (c:IsControler(1-tp) and c:IsFaceup() and  c:IsLocation(LOCATION_MZONE))) and c:IsCanBeFusionMaterial()
end

function s.extrafilter(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,tp)
	if #eg>0 then
		return eg,nil
	end
	return nil
end

--Return to your hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:GetOriginalCode()~=c:GetCode() end,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end