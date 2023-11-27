--Scripted by IanxWaifu
--Daemon Lamashira, Nephilim’s Sow
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x718),2,2,s.lcheck)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Excavate and either add to hand or banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.exctg)
	e2:SetOperation(s.excop)
	c:RegisterEffect(e2)
	--Place Scale upon an activation
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,6))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.pccon)
	e3:SetTarget(s.pctg)
	e3:SetOperation(s.pcop)
	c:RegisterEffect(e3)
end

s.listed_series={0x718,0x719}

--Monsters with different names
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end

function s.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:IsSetCard(0x718) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if chk==0 then return zone~=0 and loc~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_EXTRA
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if not c:IsRelateToEffect(e) or c:GetLinkedZone(tp)&0x1f==0 then return end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp,zone)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,c:GetLinkedZone(tp)&0x1f)
	end
end


--Excavate Ignition
function s.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x718) and ((c:IsType(TYPE_RITUAL+TYPE_XYZ+TYPE_LINK+TYPE_FUSION) and c:IsLocation(LOCATION_MZONE)) or c:IsLocation(LOCATION_PZONE))
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sct=Duel.GetMatchingGroupCount(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=sct end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.excfilter(c)
	return (c:IsSetCard(0x718) or c:IsSetCard(0x719)) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local sct=Duel.GetMatchingGroupCount(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<sct then return end
	Duel.ConfirmDecktop(tp,sct)
	local opt=0
	local ct=0
	local g=Duel.GetDecktopGroup(tp,sct):Filter(s.excfilter,nil)
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
				aux.Stringid(id,3)) 
				Duel.ShuffleHand(tp)
				ct=1
				local ac=sct-ct
    			if ac>0 then
    			opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
				opt=opt+1
				if opt==1 then
					Duel.SortDecktop(tp,tp,ac)
			elseif opt==2 then 
				  	Duel.MoveToDeckBottom(ac,tp)
					Duel.SortDeckbottom(tp,tp,ac)
				end
			end
		else
			local ac=sct-ct
	    	if ac>0 then
			opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
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

--Place Scale
function s.fgfilter(c,tp)
	return c:IsSetCard(0x718) and c:IsFaceup() and c:IsControler(tp)
end
function s.pccon(e,tp,eg,ep,ev,re,r,rp)
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
    local tc=re:GetHandler()
    local cg=tc:GetColumnGroup(1,1)
	return cg:IsExists(s.fgfilter,1,nil,tp) and (Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN))
end
function s.pcfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x718) and not c:IsForbidden() and c:IsFaceup() and (c:IsLocation(LOCATION_EXTRA) or c:IsLocation(LOCATION_REMOVED))
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA+LOCATION_REMOVED,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end