--Vylon's Wrath
--Scripted by Aimer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--Filters
function s.eqfilter(c)
	return c:IsSetCard(SET_VYLON) and (c:IsMonster() or c:IsEquipSpell()) and not c:IsForbidden()
end
function s.synfilter(c,tp)
	return c:IsSetCard(SET_VYLON) and c:IsSynchroMonster() and c:IsSynchroSummonable(nil)
end
function s.vylonfield(c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsSynchroMonster()
end

--Target function: check valid options and zone space
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local hasopt={}
		--Option 1: Equip from GY
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			ct=ct-1
		end
		if Duel.GetFlagEffect(tp,id+1)==0 and ct>0
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.vylonfield,tp,LOCATION_MZONE,0,1,nil) then
			table.insert(hasopt,1)
		end
		--Option 2: Destroy 1 Vylon + 1 opponent card
		if Duel.GetFlagEffect(tp,id+2)==0 
			and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_ONFIELD,0,1,nil,SET_VYLON)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then
			table.insert(hasopt,2)
		end
		--Option 3: Synchro Summon
		if Duel.GetFlagEffect(tp,id+3)==0 and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,tp) then
			table.insert(hasopt,3)
		end
		if #hasopt==0 then return false end
		e:SetLabel(table.unpack(hasopt))
		return true
	end
	--Select which option to use
	local opts={}
	local vals={}
	for _,v in ipairs({e:GetLabel()}) do
		if v==1 then table.insert(opts,aux.Stringid(id,0)) table.insert(vals,1) end
		if v==2 then table.insert(opts,aux.Stringid(id,1)) table.insert(vals,2) end
		if v==3 then table.insert(opts,aux.Stringid(id,2)) table.insert(vals,3) end
	end
	local sel=Duel.SelectOption(tp,table.unpack(opts))
	e:SetLabel(vals[sel+1])
	--Register once-per-turn flag
	Duel.RegisterFlagEffect(tp,id+vals[sel+1],RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end

--Activation: execute selected option
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==1 then
		--Equip any number of Vylon monsters/equips from GY to Vylon Synchros
		local eqt=Duel.GetMatchingGroup(s.vylonfield,tp,LOCATION_MZONE,0,nil)
		local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_GRAVE,0,nil)
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			ct=ct-1
		end
		if #g==0 or #eqt==0 or ct<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local tg=g:Select(tp,1,math.min(#g,ct),nil)
		for ec in aux.Next(tg) do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local target=eqt:Select(tp,1,1,nil):GetFirst()
			if target then
				Duel.Equip(tp,ec,target)
				-- Equip limit on the EQUIP CARD (tc)
		        local e1=Effect.CreateEffect(ec)
		        e1:SetType(EFFECT_TYPE_SINGLE)
		        e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		        ec:RegisterEffect(e1)
			end
		end
	elseif opt==2 then
	    local c=e:GetHandler()
	    local g=Group.CreateGroup()
	    g:Merge(Duel.GetMatchingGroup(function(tc) return tc:IsSetCard(SET_VYLON) and tc~=c end,tp,LOCATION_ONFIELD,0,nil))
	    g:Merge(Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil))
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	    if #sg==2 then Duel.Destroy(sg,REASON_EFFECT) end
	end
end

--outside of your main function
function s.rescon(sg,e,tp,mg)
    return sg:FilterCount(function(tc) return tc:IsControler(tp) and tc:IsSetCard(SET_VYLON) end,nil)==1
       and sg:FilterCount(function(tc) return tc:IsControler(1-tp) end,nil)==1
end

function s.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
