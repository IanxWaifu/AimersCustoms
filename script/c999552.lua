--Scripted by IanxWaifu
--Voltaic Dustdevil, Tristine
local s, id = GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	-- Search draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
   

s.listed_names = {id}
s.listed_series = {SET_VOLTAIC}


function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_MSET,e,REASON_COST,tp,tp,0)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsDisabled()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.eqfilter(c,ec,tp)
	return c:IsFaceup() and ec:CheckEquipTarget(c) and c:IsSetCard(SET_VOLTAIC)
end


function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local dr=Duel.GetOperatedGroup():GetFirst()
	local eqg=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_MZONE,0,nil,dr,tp)
	local dg=Duel.GetMatchingGroup(Aimer.CanMoveCardToAppropriateZone,tp,0,LOCATION_ONFIELD,nil,1-tp)
	Duel.ConfirmCards(1-tp,dr)
	Duel.BreakEffect()
	local opt=0
	if (dr:IsSetCard(SET_VOLTAIC) or dr:IsType(TYPE_EQUIP)) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then return end
	if (dr:IsSetCard(SET_VOLTAIC) and dr:IsAbleToGrave()) and (#eqg>0 and dr:CheckUniqueOnField(tp) and not dr:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and dr:IsType(TYPE_EQUIP)) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif (dr:IsSetCard(SET_VOLTAIC) and dr:IsAbleToGrave()) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif (#eqg>0 and dr:CheckUniqueOnField(tp) and not dr:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and dr:IsType(TYPE_EQUIP)) then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else opt=2 return end
	if opt==0 then
		if Duel.SendtoGrave(dr,REASON_EFFECT)~=0 and #dg>0 then 
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local tg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(tg)
            local tdg=tg:GetFirst()
            local p=tdg:GetControler()
            Aimer.MoveCardToAppropriateZone(tdg,p)
        end
    end
    elseif opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tcg=eqg:Select(tp,1,1,nil):GetFirst()
		if Duel.Equip(tp,dr,tcg,true) and #dg>0 then
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
				local tg=dg:Select(tp,1,1,nil)
				Duel.HintSelection(tg)
	            local tdg=tg:GetFirst()
	            local p=tdg:GetControler()
	            Aimer.MoveCardToAppropriateZone(tdg,p)
	        end
        end
	else return end
end




function s.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:IsSetCard(SET_VOLTAIC) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,0xD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,0xD)
	end
end