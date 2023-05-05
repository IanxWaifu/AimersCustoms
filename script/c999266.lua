--Scripted by IanxWaifu
--Daemon of Ruin, Kikimora
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	Pendulum.AddProcedure(c)
	local g=Group.CreateGroup()
	g:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetLabelObject(g)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetLabelObject(g)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Pendulum Place
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.pctg)
	e4:SetOperation(s.pcop)
	c:RegisterEffect(e4)
	--effect gain 
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetCondition(s.efcon)
	e5:SetOperation(s.efop)
	c:RegisterEffect(e5)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x718) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function s.regop(e)
	local c=e:GetHandler()
	local flageff={c:GetFlagEffectLabel(1)}
	if flageff[1]==nil or c:GetFlagEffect(2)>0 then return end
	c:RegisterFlagEffect(2,RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET|RESET_CHAIN,0,1)
	local g=e:GetLabelObject()
	g:Clear()
	for _,i in ipairs(flageff) do
		g:AddCard(Duel.GetCardFromCardID(i))
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
    if not (c:IsColumn(seq,p,LOCATION_ONFIELD) or c:IsColumn(seq+1,p,LOCATION_ONFIELD) or c:IsColumn(seq-1,p,LOCATION_ONFIELD)) then
        return false
    end
    local flageff=c:GetFlagEffectLabel(1)
    c:RegisterFlagEffect(1,RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET|RESET_CHAIN,0,1,re:GetHandler():GetCardID())
    if flageff==nil then e:GetLabelObject():Clear() end
    return flageff==nil
end
function s.thfilter(c,e,tp,...)
	return not c:IsCode(...) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,zone) and c:IsSetCard(0x718) and c:IsMonster()
end
function s.setfilter(c,e,tp,...)
	return not c:IsCode(...) and c:IsSetCard(0x719) and c:IsSSetable()
end
function s.chk(c,e,tp,zone)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,c,e,tp,c:GetCode(),zone)
end
function s.dblchk(c,e,tp,zone,stzone)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,c,e,tp,c:GetCode(),zone) or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,c,e,tp,c:GetCode(),stzone)
end
function s.schk(c,e,tp,stzone)
	return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,c,e,tp,c:GetCode(),stzone)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetLabelObject()
    local c=e:GetHandler()
    local zone=0
    local stzone=0
    local pz1=c==Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local pz2=c==Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    local seq1=Duel.GetFieldCard(tp,LOCATION_MZONE,0)
    local seq2=Duel.GetFieldCard(tp,LOCATION_MZONE,1)
    local seq3=Duel.GetFieldCard(tp,LOCATION_MZONE,3)
    local seq4=Duel.GetFieldCard(tp,LOCATION_MZONE,4) 
    local STZ2=Duel.GetFieldCard(tp,LOCATION_SZONE,1)
    local STZ4=Duel.GetFieldCard(tp,LOCATION_SZONE,3)
    --Check Left Pzone

		if pz1 and not STZ2 then stzone=1<<1 end
		if pz2 and not STZ4 then stzone=1<<3 end
		  -- Check Left Pzone
	    if pz1 and not seq1 and seq2 then zone=1 end
	    if pz1 and not seq1 and not seq2 then zone=1|2 end 
	    if pz1 and seq1 and not seq2 then zone=2 end 
	    -- Check Right Pzone
	    if pz2 and not seq4 and seq3 then zone=16 end   
	    if pz2 and not seq4 and not seq3 then zone=8|16 end   
	    if pz2 and seq4 and not seq3 then zone=8 end 
	
    if chk==0 then return 
    --Group Case
    (g:IsExists(s.dblchk,1,nil,e,tp,zone,stzone) and ((pz1 and not seq1 and seq2 and not STZ2) or (pz1 and not seq2 and seq1 and not STZ2)) or ((pz2 and not seq3 and seq4 and not STZ4) or (pz2 and not seq4 and seq3 and not STZ4)) or

    	((pz1 and not seq1 and not seq2 and not STZ2) or (pz2 and not seq3 and not seq4 and not STZ4))) 

    or
    --Spell/Trap Case
    (g:IsExists(s.schk,1,nil,e,tp,stzone) and (pz1 and seq1 and seq2 and not STZ2) or (pz2 and seq3 and seq4 and not STZ4)) 

    or 
    --Monster Case
    (g:IsExists(s.chk,1,nil,e,tp,zone) and (pz1 and seq1 and not seq2 and STZ2) or (pz1 and seq2 and not seq1 and STZ2) or (pz2 and seq3 and not seq4 and STZ4) or (pz2 and seq4 and not seq3 and STZ2) 
    	or ((pz1 and not seq1 and not seq2 and STZ2) or (pz2 and not seq1 and not seq2 and STZ4)))
	end


    if #g>1 then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
        e:SetLabel(g:Select(tp,1,1,nil):GetFirst():GetCardID())
    else
        e:SetLabel(g:GetFirst():GetCardID())
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end



--use this
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetCardFromCardID(e:GetLabel())
    if not tc then return end  
    local c=e:GetHandler()
    local zone=0
    local stzone=0
    local pz1=c==Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local pz2=c==Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    local seq1=Duel.GetFieldCard(tp,LOCATION_MZONE,0)
    local seq2=Duel.GetFieldCard(tp,LOCATION_MZONE,1)
    local seq3=Duel.GetFieldCard(tp,LOCATION_MZONE,3)
    local seq4=Duel.GetFieldCard(tp,LOCATION_MZONE,4) 
    local STZ2=Duel.GetFieldCard(tp,LOCATION_SZONE,1)
    local STZ4=Duel.GetFieldCard(tp,LOCATION_SZONE,3)
    local opt=0
    --Group Case
    if ((pz1 and not seq1 and seq2 and not STZ2) or (pz1 and not seq2 and seq1 and not STZ2)) or ((pz2 and not seq3 and seq4 and not STZ4) or (pz2 and not seq4 and seq3 and not STZ4)) or

    	((pz1 and not seq1 and not seq2 and not STZ2) or (pz2 and not seq3 and not seq4 and not STZ4)) then

    	opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,3))
		opt=opt+1

	--Spell/Trap Case
    elseif (pz1 and seq1 and seq2 and not STZ2) or (pz2 and seq3 and seq4 and not STZ4) then 
        opt=1

    --Monster Case
    elseif (pz1 and seq1 and not seq2 and STZ2) or (pz1 and seq2 and not seq1 and STZ2) or (pz2 and seq3 and not seq4 and STZ4) or (pz2 and seq4 and not seq3 and STZ2)

    	or ((pz1 and not seq1 and not seq2 and STZ2) or (pz2 and not seq1 and not seq2 and STZ4)) then

    	opt=2
    end
    if opt==1 then
    	 --Check Left Pzone
		if pz1 and not STZ2 then stzone=1<<1 end
		if pz2 and not STZ4 then stzone=1<<3 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	    local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetLabelObject(),e,tp,tc:GetCode()):GetFirst()
	    if tg then
	        Duel.MoveToField(tg,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true,stzone)
	        Duel.ConfirmCards(1-tp,tg)
	        Duel.RaiseEvent(tg,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
			-- Banish it if it leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tg:RegisterEffect(e1)
	    end
	    elseif opt==2 then
	    -- Check Left Pzone
	    if pz1 and not seq1 and seq2 then zone=1 end
	    if pz1 and not seq1 and not seq2 then zone=1|2 end 
	    if pz1 and seq1 and not seq2 then zone=2 end 
	    -- Check Right Pzone
	    if pz2 and not seq4 and seq3 then zone=16 end   
	    if pz2 and not seq4 and not seq3 then zone=8|16 end   
	    if pz2 and seq4 and not seq3 then zone=8 end 
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	    local tg = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetLabelObject(),e,tp,tc:GetCode()):GetFirst()  
		if tg and Duel.SpecialSummonStep(tg,0,tp,tp,false,false,POS_FACEUP,zone) then
			--Banish it if it leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tg:RegisterEffect(e1)
			Duel.SpecialSummonComplete()
		end
	end
end

function s.efilter(c,seq,tp)
	local cg=c:GetColumnGroup(1,1)
	return cg:IsExists(s.fgfilter,1,nil,seq,tp)
end
function s.fgfilter(c,seq,tp)
	return c:IsSetCard(0x718) and c:IsFaceup() and c:IsControler(tp)
end


--[[function s.cfilter(c,seq,tp)
	return c:IsFaceup() and c:IsSetCard(0x718) and c:IsControler(tp) and (c:IsColumn(seq,tp,LOCATION_ONFIELD) or c:IsColumn(seq+1,tp,LOCATION_ONFIELD) or c:IsColumn(seq-1,tp,LOCATION_ONFIELD))
end--]]

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return Duel.IsExistingMatchingCard(s.efilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,seq,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end



--Pendlulum Place
function s.pcfilter(c)
	return c:IsSetCard(0x718) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and not c:IsCode(id) and not c:IsLocation(LOCATION_PZONE)
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pcfilter),tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end



function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsSetCard(0x718)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,3})
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,1,REASON_EFFECT)~=0 then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
