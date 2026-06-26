--Scripted by Aimer
--Sylvestrie and the Eave of the Verdantrie
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Replace to field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.fhtg)
	e2:SetOperation(s.fhop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
	c:RegisterEffect(e4)
	local ritual_params={handler=c,lvtype=RITPROC_GREATER,filter=s.paramsfilter,location=LOCATION_HAND|LOCATION_GRAVE}
	--Ritual Summon 1 "Sylvestrie" Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed the Level of the Ritual Monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_BOTH_SIDE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.ritcon)
	e5:SetTarget(Ritual.Target(ritual_params))
	e5:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local owner=c:GetOwner()
		Ritual.Operation(ritual_params)(e,owner,eg,ep,ev,re,r,rp)
	end)
	c:RegisterEffect(e5)
end

s.listed_series={SET_SYLVESTRIE}

function s.paramsfilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsType(TYPE_RITUAL)
end

function s.ritcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsControler(ep)
end

function s.fhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.fhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local op
	op=Duel.SelectEffect(tp,{true,aux.Stringid(id,5)},{true,aux.Stringid(id,6)})
	local target_player=op==1 and tp or 1-tp
	-- Handle existing field spell replacement properly
	local fc=Duel.GetFieldCard(target_player,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
	end
	-- Move card to chosen field zone
	Duel.MoveToField(c,tp,target_player,LOCATION_FZONE,POS_FACEUP,true)
end

function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsOwner(tp)
end

function s.fspfilter(c)
	return c:IsSetCard(SET_SYLVESTRIE) and c:IsType(TYPE_FIELD)
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local owner=c:GetOwner()
	if chk==0 then return Duel.GetFlagEffect(owner,id)<=0 and Duel.IsExistingMatchingCard(s.fspfilter,owner,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetOwner()
	if not Duel.SelectYesNo(p,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_CARD,0,id)
	-- Register flag (prevents future targeting)
	Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
	if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(p,s.fspfilter,p,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	local op=Duel.SelectEffect(tp,{true,aux.Stringid(id,5)},{true,aux.Stringid(id,6)})
	local target_player=op==1 and tp or 1-tp
	local fc=Duel.GetFieldCard(target_player,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
	end
	Duel.MoveToField(tc,tp,target_player,LOCATION_FZONE,POS_FACEUP,true)
end
