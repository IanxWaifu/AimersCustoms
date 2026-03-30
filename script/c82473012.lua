--Scripted by Aimer
--Genosynx Malbriva
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
	--Main Phase (Quick): Tribute this; take 1 Spirit + 1 "Genosynx" Trap, add 1, Set the other
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.qcost)
	e1:SetTarget(s.qtg)
	e1:SetOperation(s.qop)
	c:RegisterEffect(e1)
	--(GY) End Phase: if a Spirit monster was returned from field to your hand this turn, add this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
	--Check for Fusion Monsters sent to the GY
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)

end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsControler(tp) and tc:IsPreviousLocation(LOCATION_ONFIELD) and tc:IsPreviousTypeOnField(TYPE_SPIRIT) then 
			Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end

function s.splimit(e,se,sp,st)
	--Allow only if the effect that Special Summons it is from a "Genosynx" card
	if not se then return false end
	local rc=se:GetHandler()
	return rc and rc:IsSetCard(SET_GENOSYNX)
end

--“flipped face-up this turn” helper (covers manual position changes too)
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.regturnop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.qcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

-- Spirit / Trap filters stay basically the same
function s.spiritfilter(c)
	return c:IsMonster() and c:IsType(TYPE_SPIRIT) and not c:IsCode(id) and c:IsLevelBelow(4)
end
function s.trapfilter(c)
	return c:IsSetCard(SET_GENOSYNX) and c:IsTrap() and not c:IsCode(id)
end

-- “actions” each card can do (we test these at selection-time)
function s.can_add(c) return c:IsAbleToHand() end
function s.can_set_trap(c) return c:IsSSetable() end
function s.can_set_spirit_fd(c,e,tp) return c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEDOWN_DEFENSE) end

-- For SelectUnselectGroup: validate the picked pair (1 Spirit + 1 Trap) has at least one viable routing
function s.selcheck_pair(sg,e,tp,mg)
	if #sg~=2 then return false end
	local sc=sg:Filter(s.spiritfilter,nil):GetFirst()
	local tc=sg:Filter(s.trapfilter,nil):GetFirst()
	if not sc or not tc then return false end
	local routeA = s.can_add(sc) and s.can_set_trap(tc) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local routeB = s.can_add(tc) and s.can_set_spirit_fd(sc,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
	return routeA or routeB
end

function s.qtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Group.CreateGroup()
		g:Merge(Duel.GetMatchingGroup(s.spiritfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil))
		g:Merge(Duel.GetMatchingGroup(s.trapfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil))
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.selcheck_pair,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.qop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	g:Merge(Duel.GetMatchingGroup(s.spiritfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil))
	g:Merge(Duel.GetMatchingGroup(s.trapfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.selcheck_pair,1,tp,HINTMSG_ATOHAND)
	if not sg or #sg~=2 then return end
	local sc=sg:Filter(s.spiritfilter,nil):GetFirst()
	local tc=sg:Filter(s.trapfilter,nil):GetFirst()
	if not sc or not tc then return end
	local canA = s.can_add(sc) and s.can_set_trap(tc) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local canB = s.can_add(tc) and s.can_set_spirit_fd(sc,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if not (canA or canB) then return end
	local addc,fieldc,field_is_trap
	if canA and canB then
		local choice=Group.FromCards(sc,tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		addc=choice:Select(tp,1,1,nil):GetFirst()
		fieldc=(addc==sc) and tc or sc
		field_is_trap=(addc==sc)
	elseif canA then
		addc=sc; fieldc=tc; field_is_trap=true
	else
		addc=tc; fieldc=sc; field_is_trap=false
	end

	if Duel.SendtoHand(addc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,addc)
	end
	if field_is_trap then
		if s.can_set_trap(fieldc) then
			Duel.SSet(tp,fieldc)
			Duel.ConfirmCards(1-tp,fieldc)
		elseif s.can_add(fieldc) and Duel.SendtoHand(fieldc,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,fieldc)
		end
	else
		if s.can_set_spirit_fd(fieldc,e,tp) then
			Duel.SpecialSummon(fieldc,0,tp,tp,true,true,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,fieldc)
		elseif s.can_add(fieldc) and Duel.SendtoHand(fieldc,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,fieldc)
		end
	end
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0 and tp~=Duel.GetTurnPlayer()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end