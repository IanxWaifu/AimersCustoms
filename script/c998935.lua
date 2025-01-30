--Scripted by Aimer
--Iron Saga - Andrometeor, Full Ordinal Link
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	--Special Summon Proc
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetHintTiming(0,TIMING_END_PHASE)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.xyztgEP)
	e0:SetCondition(s.xyzconEP)
	e0:SetOperation(s.xyzopEP)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	--Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--remove material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.matcon)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--To Extra
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tdcon)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--Banish
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	--Remove Attacking
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetTarget(s.rmtg2)
	e5:SetOperation(s.rmop2)
	c:RegisterEffect(e5)
	--Search
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCountLimit(1,{id,2})
	e6:SetRange(LOCATION_MZONE)
	e6:SetCost(s.thcost)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6,false,REGISTER_FLAG_DETACH_XMAT)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

s.listed_series={0x12EC}
s.listed_names={id}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	local p3=false
	local p4=false
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) then
			if tc:IsCode(998920) then p1=true end
			if tc:IsCode(998921) then p2=true end
			if tc:IsCode(998922) then p3=true end
			if tc:IsCode(998923) then p4=true end
		end
	end
	if p1 then Duel.RegisterFlagEffect(tp,998970,RESET_PHASE+PHASE_END,0,1) end
	if p2 then Duel.RegisterFlagEffect(tp,998971,RESET_PHASE+PHASE_END,0,1) end
	if p3 then Duel.RegisterFlagEffect(tp,998972,RESET_PHASE+PHASE_END,0,1) end
	if p4 then Duel.RegisterFlagEffect(tp,998973,RESET_PHASE+PHASE_END,0,1) end
end
--Property Checks
function s.xyzfilter(c,e,tp)
    return (c:IsCode(998920) or c:IsCode(998921) or c:IsCode(998922) or c:IsCode(998923)) and c:IsMonster() and c:IsCanBeXyzMaterial(c,tp) and ((c:IsFaceup() and c:IsLocation(LOCATION_REMOVED+LOCATION_MZONE)) or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE))
end
function s.rescon(checkfunc)
    return function(sg,e,tp,mg)
        return sg:CheckDifferentProperty(checkfunc)
    end
end


function s.xyztgEP(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--Xyz Conditions
function s.xyzconEP(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,998970)>0 and Duel.GetFlagEffect(tp,998971)>0 and Duel.GetFlagEffect(tp,998972)>0 and Duel.GetFlagEffect(tp,998973)>0
end


--Xyz Summon EP
function s.xyzopEP(e,tp,eg,ep,ev,re,r,rp,c,og)
    local c=e:GetHandler()
    local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.xyzfilter),tp,LOCATION_HAND+LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e,tp)
   	local checkfunc=aux.PropertyTableFilter(Card.GetCode,998920,998921,998922,998923)
    local og=aux.SelectUnselectGroup(sg,e,tp,1,4,s.rescon(checkfunc),1,tp,HINTMSG_CONFIRM,s.rescon(checkfunc))
    c:SetMaterial(og)
    Duel.RegisterFlagEffect(0,id+1,RESET_CHAIN,0,1)
    Duel.Overlay(c,og)
    Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,true,false,POS_FACEUP)
    c:CompleteProcedure()
    Duel.ShuffleHand(tp)
end

--Immune Eff
function s.imcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
function s.efilter(e,re,rp)
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return (not g:IsContains(e:GetHandler()))
end

--Remove Mat
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end

--To Extra
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():GetOverlayCount()==0 then return end 
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end

--Banish
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,2,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
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

--Search
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x12EC) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
