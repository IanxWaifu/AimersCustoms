--Scripted by IanxWaifu
--Daedric Relic - The Outer Realm
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Excavate and either add to hand or banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.exctg)
	e2:SetOperation(s.excop)
	c:RegisterEffect(e2)
	--Ritual Proc
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
s.listed_names={id}


function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.excfilter(c)
	return (c:IsSetCard(0x718) or c:IsSetCard(0x719)) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	Duel.ConfirmDecktop(tp,3)
	local opt=0
	local ct=0
	local g=Duel.GetDecktopGroup(tp,3):Filter(s.excfilter,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		Duel.DisableShuffleCheck()
		aux.ToHandOrElse(tc,tp,function(c)
				return tc:IsAbleToRemove() end,
				function(c)
				Duel.DisableShuffleCheck()
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end,
				aux.Stringid(id,2)) 
				Duel.ShuffleHand(tp)
				ct=1
				local ac=3-ct
    			if ac>0 then
    			opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
				opt=opt+1
				if opt==1 then
					Duel.SortDecktop(tp,tp,ac)
			elseif opt==2 then 
				  	Duel.MoveToDeckBottom(ac,tp)
					Duel.SortDeckbottom(tp,tp,ac)
				end
			end
		else
			local ac=3-ct
	    	if ac>0 then
			opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
			opt=opt+1
			if opt==1 then
				Duel.SortDecktop(tp,tp,ac)
		elseif opt==2 then 
			  	Duel.MoveToDeckBottom(ac,tp)
				Duel.SortDeckbottom(tp,tp,ac)
			end
		end
	end
end

--Ritual Proc
function s.exfilter(c,e,tp,code)
	return ((c:IsCode(999259) and code==999250) or (c:IsCode(999265) and code==999270)) and c:IsAbleToGrave() 
end
function s.rfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsRitualMonster() and c:IsSetCard(0x718) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
	and Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_HAND,0,1,c,e,tp)
end
function s.fcfilter(c)
	return c:IsSetCard(0x718) and c:IsOriginalType(TYPE_MONSTER) and c:IsAbleToRemove() and (c:IsLocation(LOCATION_HAND) or ((c:IsLocation(LOCATION_ONFIELD) or c:IsLocation(LOCATION_EXTRA)) and c:IsFaceup()))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_RITUAL)
	if #pg>0 then return end
	local rg=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local code=rg:GetFirst():GetCode()
	local tc=rg:GetFirst()
	if tc then
		local fc=Duel.SelectMatchingCard(tp,s.fcfilter,tp,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_HAND,0,1,1,tc)
		local tg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code)
		local sg=tg:GetFirst()
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.Remove(fc,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		tc:SetMaterial(rg+fc)  
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end