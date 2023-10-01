--Scripted by IanxWaifu
--Necroticrypt Ensnaring Grasp
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')

function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.attcost)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--Banish itself and attach from Rmz
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.xyzeffcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
end
s.listed_series={0x129f}
s.listed_names={id}

function s.attfilter(c)
	return c:IsSetCard(0x129f) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.checkfilter(c,e)
	return c:IsMonster() and not c:IsImmuneToEffect(e)
end
function s.attcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(s.attfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		g:Merge(tc:GetOverlayGroup())
	end
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_COST)
	Duel.RaiseSingleEvent(sg,EVENT_DETACH_MATERIAL,e,0,0,0,0)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.checkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local raceCount = 0
    local excludedRace = 0

    local mg = Duel.GetMatchingGroup(s.checkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil,e)
    for mrc in aux.Next(mg) do
        local race = mrc:GetRace()
        raceCount = raceCount + 1
        excludedRace = excludedRace | race -- Exclude the current race using bitwise OR
    end

    local race = 0

    if raceCount == 1 then
        -- If there's only one unique race, exclude it from the selection
        local allRaces = RACE_ALL
        excludedRace = ~excludedRace -- Get the complement of excludedRace
        allRaces = allRaces & excludedRace -- Exclude the race using bitwise AND
        race = Duel.AnnounceRace(tp, 1, allRaces)
    else
        race = Duel.AnnounceRace(tp, 1, RACE_ALL)
    end

    local tg = Duel.GetMatchingGroup(s.checkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil,e)
    for trc in aux.Next(tg) do
        Duel.BreakEffect()
        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_RACE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetValue(race)
        e2:SetReset(RESET_PHASE+PHASE_END)
        trc:RegisterEffect(e2)
    end
end



function s.xyzeffcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp
end
function s.xyzfilter(c,tp)
	return c:IsSetCard(0x129f) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayCount()==0
end
function s.attachfilter(c,tp)
	return c:IsMonster() and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp) end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,tp)
	if #g<=0 then return end
	local tg=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,tp)
	if #tg>0 and #g>0 then
		local mg=g:Select(tp,1,1,nil)
		local oc=mg:GetFirst():GetOverlayTarget()
		Duel.Overlay(tg:GetFirst(),mg)
	end
end









