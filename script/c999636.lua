--Scripted by IanxWaifu
--Ledger of Perdigrim
local s,id=GetID()
function s.initial_effect(c)
	--Custom Fusion Activation
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=s.fusfilter,matfilter=aux.False,extrafil=s.extrafilter,stage2=s.stage2,extraop=s.extraop})
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

s.listed_names={id}
s.listed_series={SET_DEATHRALL,SET_LEGION_TOKEN}

function s.fusfilter(c,tp,race)
    return c:IsSetCard(SET_DEATHRALL) or Duel.IsExistingMatchingCard(s.racecheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetRace())
end



function s.racecheck(c,race)
	return c:IsRace(race) and c:IsType(TYPE_TOKEN) and c:IsFaceup()
end


--Send
function s.tgfilter(c)
	return (c:ListsArchetype(SET_LEGION_TOKEN) or c:IsSetCard(SET_DEATHRALL)) and c:IsAbleToGrave() and not c:IsCode(id)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end



--Material Check
function s.matfil(c,e,tp,chk)
	return c:IsLocation(LOCATION_HAND+LOCATION_MZONE) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()) and c:IsCanBeFusionMaterial()
end
function s.filter(c)
	return (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)) or (c:IsAbleToGrave() and c:IsLocation(LOCATION_DECK)) or (c:IsLocation(LOCATION_HAND+LOCATION_MZONE)) and c:IsCanBeFusionMaterial()
end

function s.fcheck(tp,sg,fc)
	return sg:CheckDifferentPropertyBinary(Card.GetRace,fc,tp)
end


function s.extrafilter(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	if #eg>0 then
		return eg,s.fcheck
	end
	return nil
end

--Remove Materials
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end






--Continuous Application
function s.stage2(e,tc,tp,sg,chk)
	if chk~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3003)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.efilter)
	tc:RegisterEffect(e1)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

