--Scripted by IanxWaifu
--Daemon of Ruin, Alukrësia
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--Remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.gspcon)
	e3:SetTarget(s.gsptg)
	e3:SetOperation(s.gspop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(s.chaincon)
	e4:SetCountLimit(1,{id,2})
	e4:SetLabelObject(g)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	--Checks to see if non-"Daemon" monsters were Summoned from the Extra Deck
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x718) end)
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
	--Custom Quick
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetTargetRange(1,0)
	e1:SetCost(s.addcost)
	e1:SetTarget(s.addtg)
	e1:SetOperation(s.addop)
	e1:SetCountLimit(1,{id,1})
	e1:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,e:GetHandlerPlayer())
end
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local te,p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
    local tc=te:GetHandler()
    local cg=tc:GetColumnGroup(1,1)
    if not cg:IsContains(c) then
        return false
	end
    local flageff=c:GetFlagEffectLabel(1)
    c:RegisterFlagEffect(1,RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET|RESET_CHAIN,0,1,re:GetHandler():GetCardID())
    if flageff==nil then e:GetLabelObject():Clear() end
    return flageff==nil
end

function s.addcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	--SPSummon Lock
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,8))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x718) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end


function s.setfilter(c)
	return c:IsSetCard(0x719) and c:IsSSetable() and (c:IsNormalTrap() or c:IsType(TYPE_QUICKPLAY))
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.GetFlagEffect(tp,id)==0 and Duel.SSet(tp,g:GetFirst())~=0 then 
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESET_PHASE+PHASE_END,0,1)
	end
end







function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x718) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and (rc:IsSetCard(0x718) or rc:IsSetCard(0x719)) or (e:GetHandler():GetSummonType()==SUMMON_TYPE_PENDULUM)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

function s.gspconfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gspconfilter,1,nil,tp)
end
function s.disfilter(c,tp)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)and not c:IsDisabled()
end
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
	local g=eg:Filter(s.disfilter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end

function s.excfilter(c)
	return (c:IsSetCard(0x718) or c:IsSetCard(0x719)) and (c:IsAbleToGrave() and (c:IsSpellTrap()) or (c:IsAbleToRemove() and c:IsMonster()))
end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--SPSummon Lock
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTarget(s.splimit2)
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)<=0 or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local gpt=Duel.GetTargetCards(e)
	Duel.ConfirmDecktop(tp,3)
	local opt=0
	local ct=0
	local g=Duel.GetDecktopGroup(tp,3):Filter(s.excfilter,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		Duel.DisableShuffleCheck()
		if tc:IsSpellTrap() and tc:IsAbleToGrave() then
			Duel.DisableShuffleCheck()
			if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
				for neg in aux.Next(gpt) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				neg:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				neg:RegisterEffect(e2,true) 
				end
			end
			elseif tc:IsMonster() and tc:IsAbleToRemove() then 
				Duel.DisableShuffleCheck() 
				if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
					for neg in aux.Next(gpt) do
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					neg:RegisterEffect(e1,true)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					neg:RegisterEffect(e2,true) end
					end
				end
				ct=1
				local ac=3-ct
    			if ac>0 then
    			opt=Duel.SelectOption(tp,aux.Stringid(id,6),aux.Stringid(id,7))
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
			opt=Duel.SelectOption(tp,aux.Stringid(id,6),aux.Stringid(id,7))
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

function s.splimit2(e,c)
	return not c:IsSetCard(0x718)
end
