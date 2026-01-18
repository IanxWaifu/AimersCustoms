--Scripted by Aimer
--Exosister Cyriel
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_EXOSISTER),4,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	c:EnableReviveLimit()
	-- (2) If Xyz Summoned: target 1 opponent’s monster, make it Level 4 and take control until End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.ctrlcon)
	e1:SetTarget(s.ctrltg)
	e1:SetOperation(s.ctrlop)
	c:RegisterEffect(e1)
	-- (3) Quick Effect: When opponent activates effect that moves card(s) from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end

function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(SET_EXOSISTER) and c:IsType(TYPE_XYZ)
		and c:IsRank(4)
		and c:IsSummonType(SUMMON_TYPE_XYZ)
		and c:IsStatus(STATUS_SPSUMMON_TURN)
		and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,SET_EXOSISTER) and not c:IsCode(id)
end

function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end

-- (2) If Xyz Summoned → Take control + make Level 4
function s.ctrlcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.ctrlfilter(c)
	return c:IsControlerCanBeChanged()
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and s.ctrlfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not Duel.GetControl(tc,tp) then return end
	-- make it Level 4
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- return control at End Phase
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabelObject(tc)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(s.retrop)
	Duel.RegisterEffect(e2,tp)
end
function s.retrop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and Duel.GetControl(tc,1-tp) then end
end

function s.check(ev,re)
	return function(category,checkloc)
		if not checkloc and re:IsHasCategory(category) then return true end
		local ex1,g1,gc1,dp1,dv1=Duel.GetOperationInfo(ev,category)
		local ex2,g2,gc2,dp2,dv2=Duel.GetPossibleOperationInfo(ev,category)
		if not (ex1 or ex2) then return false end
		local g=Group.CreateGroup()
		if g1 then g:Merge(g1) end
		if g2 then g:Merge(g2) end
		return (((dv1 or 0)|(dv2 or 0))&LOCATION_GRAVE)~=0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE))
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsDisabled() or not Duel.IsChainDisablable(ev) then return false end
	local checkfunc=s.check(ev,re)
	return  rp==1-tp and Duel.IsChainDisablable(ev) and (checkfunc(CATEGORY_TOHAND,true) or checkfunc(CATEGORY_SPECIAL_SUMMON,true)
		or checkfunc(CATEGORY_TOGRAVE,true) or checkfunc(CATEGORY_TODECK,true))
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local dc=re:GetHandler()
	if dc:IsRelateToEffect(re) then
		local cat=e:GetCategory()
		if dc:IsMonsterCard() then
			e:SetCategory(cat|CATEGORY_SPECIAL_SUMMON)
			Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dc,1,0,LOCATION_GRAVE)
		else
			e:SetCategory(cat&~CATEGORY_SPECIAL_SUMMON)
		end
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local opp=1-tp
	if not Duel.NegateEffect(ev) then return end
	if not rc:IsControler(opp) then return end
	if rc:IsLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED) and aux.nvfilter(rc) then
		if (rc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and rc:IsCanBeSpecialSummoned(e,0,opp,false,false,POS_FACEDOWN_DEFENSE) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(rc,0,opp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(tp,rc)
		elseif (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
			and rc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.MoveToField(rc,opp,tp,LOCATION_SZONE,POS_FACEDOWN,false)
		    rc:SetStatus(STATUS_SET_TURN,false) 
		end
	end
end
