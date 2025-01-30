--Novalxon Epochira
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Apply Astral Shift
	Aimer.AddAstralShift(c)
	--Set this card from your banishment
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NOVALXON),tp,LOCATION_ONFIELD,0,1,nil) end)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==0 end)
    e2:SetCost(s.applycost)
    e2:SetTarget(s.applytg)
    e2:SetOperation(s.applyop)
    c:RegisterEffect(e2)
    --battle target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)
	--Place 1 "Novalxon" Continuous Spell/Trap on the field
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,5))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCondition(s.tfcon)
    e5:SetTarget(s.tftg)
    e5:SetOperation(s.tfop)
    c:RegisterEffect(e5)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

--self summon
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
	end
end

--cannot battle target
function s.atlimit(e,c)
	return c:IsFaceup() and c:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)>0
end

function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local left=s.lefttg(e,tp,eg,ep,ev,re,r,rp,0) and c:GetSequence()==0
    local center=s.centertg(e,tp,eg,ep,ev,re,r,rp,0) and c:GetSequence()==2
    local right=s.righttg(e,tp,eg,ep,ev,re,r,rp,0) and c:GetSequence()==4
    if chk==0 then return left or center or right end
    if left then s.lefttg(e,tp,eg,ep,ev,re,r,rp) end
    if center then s.centertg(e,tp,eg,ep,ev,re,r,rp) end
    if right then s.righttg(e,tp,eg,ep,ev,re,r,rp) end
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local left=s.lefttg(e,tp,eg,ep,ev,re,r,rp,0) and c:GetPreviousSequence()==0
    local center=s.centertg(e,tp,eg,ep,ev,re,r,rp,0) and c:GetPreviousSequence()==2
    local right=s.righttg(e,tp,eg,ep,ev,re,r,rp,0) and c:GetPreviousSequence()==4
    if left then s.lefttop(e,tp,eg,ep,ev,re,r,rp) end
    if center then s.centerop(e,tp,eg,ep,ev,re,r,rp) end
    if right then s.rightop(e,tp,eg,ep,ev,re,r,rp) end
end

--leftfilter
function s.lefttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.leftfilter(c)
	return c:IsSetCard(SET_NOVALXON) and c:IsAbleToHand() 
end
function s.lefttop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local g=Duel.GetDecktopGroup(tp,3)
	Duel.ConfirmCards(tp,g)
	if g:IsExists(s.leftfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,s.leftfilter,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.SortDeckbottom(tp,tp,2)
	else Duel.SortDeckbottom(tp,tp,3) end
end


--centerfilter
function s.tgrmcheck(sg,e,tp,mg)
    return sg:GetClassCount(Card.GetLocation)==#sg 
        and sg:GetClassCount(Card.GetCode)==#sg 
        and sg:FilterCount(Card.IsAbleToGrave,nil)>=1 
        and sg:FilterCount(Card.IsAbleToRemove,nil)>=1 
        and sg:IsExists(function(c) return c:IsAbleToGrave() end,1,nil) 
        and sg:IsExists(function(c) return c:IsAbleToRemove() end,1,nil) 
end

function s.tgrmfilter(c)
	return c:IsSetCard(SET_NOVALXON) and not c:IsCode(id)
end
function s.centertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		local g=Duel.GetMatchingGroup(s.tgrmfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.tgrmcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.centerop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tgrmfilter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.tgrmcheck,1,tp,HINTMSG_SELECT)
	if #sg~=2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local hg=sg:FilterSelect(tp,function(c) return c:IsAbleToGrave() and c:GetLocation()~=LOCATION_GRAVE end,1,1,nil)
	if #hg>0 and Duel.SendtoGrave(hg,REASON_EFFECT)>0 then
		sg=sg-hg
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end

--rightfilter
function s.rightfilter(c)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)) or (c:IsLocation(LOCATION_GRAVE))) and c:IsSetCard(SET_NOVALXON) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.righttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED+LOCATION_GRAVE) and s.rightfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rightfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.rightfilter),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.rightop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end


--Astral Effect
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==1
end
function s.ttfilter(c,tp)
    return c:IsSpellTrap() and (c:IsType(TYPE_CONTINUOUS) or c:IsType(TYPE_FIELD)) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsSetCard(SET_NOVALXON)
end

function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.ttfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end

function s.tfop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.ttfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if not tc then return end
        local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
        if tc:IsType(TYPE_FIELD) then
        if fc then
            Duel.SendtoGrave(fc,REASON_RULE)
            Duel.BreakEffect()
        end
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    else
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
    Duel.RaiseSingleEvent(e:GetHandler(),EVENT_ASTRAL_EFFECT_PROC,e,0,0,0,0)
	e:GetHandler():RegisterFlagEffect(REGISTER_FLAG_ASTRAL_STATE,RESET_EVENT+RESET_TODECK|RESET_TOHAND|RESET_TEMP_REMOVE|RESET_REMOVE|RESET_TOGRAVE|RESET_TURN_SET,0,0)
end

