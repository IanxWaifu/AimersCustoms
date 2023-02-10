--Scripted by IanxWaifu
--Haze in Leiu of Light
local s,id=GetID()
function s.initial_effect(c)
	--rearrange
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={0x12A8,0x12A9}

function s.filter(c,e,tp)
	return ((c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or (c:IsSpellTrap() and c:IsSSetable())) and c:ListsArchetype(0x12A8) and not c:IsCode(id) and c:IsAbleToGrave()
end


--Choose 2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end



function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,5)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local g=Duel.GetDecktopGroup(tp,5):Filter(s.filter,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,filter,1,tp,HINTMSG_SELECT)
	if #sg>0 then
--[[	local p
		if e:GetLabel()==0 then
			p=1-tp
		elseif e:GetLabel()==1 then
			p=tp
		end--]]
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SELECT)
		local tg=sg:RandomSelect(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		while tc do
			if tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
				if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then tc=tg:GetNext() end
			elseif tc:IsSpellTrap() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				if Duel.SSet(tp,tc)~=0 then tc=tg:GetNext() end
	end
		sg:RemoveCard(tg:GetFirst())
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.MoveToDeckBottom(5-#sg,tp)
		Duel.SortDeckbottom(tp,tp,5-#sg)
		end
	else 
		Duel.BreakEffect()
		Duel.MoveToDeckBottom(5,tp)
		Duel.SortDeckbottom(tp,tp,5)
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	Duel.RegisterEffect(e2,tp)
end
function s.efilter(e,c)
	return c:IsSetCard(0x12A9) and c:GetActivateEffect():IsHasType(EFFECT_TYPE_ACTIVATE)
end