--Scripted by IanxWaifu
--Necroticrypt Warden
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
	function s.initial_effect(c)
	--detach and change race
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.rcost)
	e1:SetTarget(s.rctg)
	e1:SetOperation(s.rcop)
	c:RegisterEffect(e1)
	--Special summon itself from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={0x129f}

function s.xyzfilter(c,tp)
    local mg = c:GetOverlayGroup()
    return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsSetCard(0x129f) and mg:IsExists(s.rfilter,1,nil,tp)
end

function s.rfilter(c,tp,rc)
    local rc = c:GetRace()
    return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.tfilter,tp,0,LOCATION_MZONE,1,c,rc)
end

function s.tfilter(c,rcv)
    local rc = rcv
    return c:GetRace() ~= rc and c:IsFaceup()
end


function s.rcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local dg = Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,tp)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp,1) and c:IsAbleToGraveAsCost() and #dg > 0 and Duel.CheckRemoveOverlayCard(tp,0,0,1,REASON_COST,dg) end
    Duel.SendtoGrave(c,REASON_COST)
    Duel.BreakEffect()
    local matg=Duel.GetOverlayGroup(tp,LOCATION_MZONE,0)
	local tg=matg:FilterSelect(tp,s.rfilter,1,1,nil,tp,rc)
    e:SetLabel(tg:GetFirst():GetRace())
    Duel.SendtoGrave(tg:GetFirst(),REASON_COST)
    Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
end



function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 and #g>0 then
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(e:GetLabel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

function s.cfilter(c)
	return c:IsSetCard(0x29f) and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end