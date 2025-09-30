--Scripted by Aimer
--Exosister Zefravieve
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	--Ignition effect in P-Zone (destroy + shuffle + summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
	--Set 1 Exosister Spell/Trap on Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sttg)
	e3:SetOperation(s.stop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--Special Summon Xyz
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_GRAVE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(function(_,tp,_,_,_,_,_,rp)return rp==1-tp end)
	e5:SetTarget(s.xyztg)
	e5:SetOperation(s.xyzop)
	c:RegisterEffect(e5)
end
s.listed_names={8958659}
s.listed_series={SET_EXOSISTER,SET_ZEFRA}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_EXOSISTER) or c:IsSetCard(SET_ZEFRA) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM 
end


--Pendulum Ignition (destroy + shuffle + summon)
function s.tdfilter(c)
	return (c:IsFaceup() and (c:IsSetCard(SET_ZEFRA) or c:IsSetCard(SET_EXOSISTER))) and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_EXOSISTER) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable(e)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil)
		if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then
				if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,8958659),tp,LOCATION_ONFIELD,0,1,nil) then
					Duel.BreakEffect()
					Duel.Recover(tp,800,REASON_EFFECT)
				end
			end
		end
	end
end

--Set Exosister S/T
function s.stfilter(c)
	return c:IsSetCard(SET_EXOSISTER) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	Duel.SSet(tp,tc)
	local orig=tc:GetActivateEffect()
	if not orig then return end
	-- create new immediate-use effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetCategory(orig:GetCategory() or CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	if orig:GetTarget() then e1:SetTarget(orig:GetTarget()) end
	if orig:GetOperation() then e1:SetOperation(orig:GetOperation()) end
	-- copy count limit
	local cl,flag=orig:GetCountLimit()
	if cl>0 then
		e1:SetCountLimit(cl, flag)
	end
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	tc:RegisterEffect(e3)
end


--Exosister Xyz Summon
function s.xyzfilter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(SET_EXOSISTER) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local c=e:GetHandler()
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if #pg>1 or (#pg==1 and not pg:IsContains(c)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
	if sc then
		local mg=Group.FromCards(c)
		sc:SetMaterial(mg)
		Duel.Overlay(sc,mg)
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end