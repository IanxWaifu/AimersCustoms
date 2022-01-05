--Scripted by IanxWaifu
--Shio to Suna ★ Sunbathing!
local s,id=GetID()
function s.initial_effect(c,reg,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1074)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(Pendulum.Condition())
	e1:SetOperation(Pendulum.Operation())
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e1)
	--register by default
	if reg==nil or reg then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(1160)
		e2:SetCategory(CATEGORY_TOHAND)
		e2:SetType(EFFECT_TYPE_ACTIVATE)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetOperation(s.activate)
		c:RegisterEffect(e2)
	end
end


function Pendulum.Filter(c,e,tp,lscale,rscale,lvchk)
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	return (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and (lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
		and not c:IsForbidden()
end
function Pendulum.Condition()
	return	function(e,c,og)
				if c==nil then return true end
				local tp=c:GetControler()
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,10000000)>0 then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local loc=0
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
				if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
				if loc==0 then return false end
				local g=nil
				if og then
					g=og:Filter(Card.IsLocation,nil,loc)
				else
					g=Duel.GetFieldGroup(tp,loc,0)
				end
				return g:IsExists(Pendulum.Filter,1,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
			end
end
function Pendulum.Operation()
	return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
				local ft=Duel.GetUsableMZoneCount(tp)
				if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
					if ft1>0 then ft1=1 end
					if ft2>0 then ft2=1 end
					ft=1
				end
				local loc=0
				if ft1>0 then loc=loc+LOCATION_HAND end
				if ft2>0 then loc=loc+LOCATION_EXTRA end
				local tg=nil
				if og then
					tg=og:Filter(Card.IsLocation,nil,loc):Filter(Pendulum.Filter,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				else
					tg=Duel.GetMatchingGroup(Pendulum.Filter,tp,loc,0,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				end
				ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
				ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
				local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and c29724053[tp]
				if ect and ect<ft2 then ft2=ect end
				while true do
					local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
					local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
					local ct=ft
					if ct1>ft1 then ct=math.min(ct,ft1) end
					if ct2>ft2 then ct=math.min(ct,ft2) end
					local loc=0
					if ft1>0 then loc=loc+LOCATION_HAND end
					if ft2>0 then loc=loc+LOCATION_EXTRA end
					local g=tg:Filter(Card.IsLocation,sg,loc)
					if #g==0 or ft==0 then break end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tc=Group.SelectUnselect(g,sg,tp,#sg>0,#sg==0)
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
						if tc:IsLocation(LOCATION_HAND) then
							ft1=ft1+1
						else
							ft2=ft2+1
						end
						ft=ft+1
					else
						sg:AddCard(tc)
						if c:IsHasEffect(511007000)~=nil or rpz:IsHasEffect(511007000)~=nil then
							if not Pendulum.Filter(tc,e,tp,lscale,rscale) then
								local pg=sg:Filter(aux.TRUE,tc)
								local ct0,ct3,ct4=#pg,pg:FilterCount(Card.IsLocation,nil,LOCATION_HAND),pg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
								sg:Sub(pg)
								ft1=ft1+ct3
								ft2=ft2+ct4
								ft=ft+ct0
							else
								local pg=sg:Filter(aux.NOT(Pendulum.Filter),nil,e,tp,lscale,rscale)
								sg:Sub(pg)
								if #pg>0 then
									if pg:GetFirst():IsLocation(LOCATION_HAND) then
										ft1=ft1+1
									else
										ft2=ft2+1
									end
									ft=ft+1
								end
							end
						end
						if tc:IsLocation(LOCATION_HAND) then
							ft1=ft1-1
						else
							ft2=ft2-1
						end
						ft=ft-1
					end
				end
				if #sg>0 then
					Duel.RegisterFlagEffect(tp,10000000,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
					Duel.HintSelection(Group.FromCards(c))
					Duel.HintSelection(Group.FromCards(rpz))
					 if sg:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) then
						local g2=sg:Clone()
						g2:KeepAlive()
						aux.SummoningGroup=g2
						aux.SummoningCard=nil
					end
				end
			end
end










function s.thfilter(c)
	return (c:IsSetCard(0x12F0) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	if c:IsOnField() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(c)
			e1:SetOperation(s.rpop)
			e1:SetReset(RESET_EVENT+0x1000000)
			c:RegisterEffect(e1)
		end
	if not c:GetSequence()==0 or not c:GetSequence()==4 then
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
end




function s.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fc0000)
	e1:SetValue(TYPE_SPELL+TYPE_PENDULUM)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+0x1fc0000)
	e2:SetValue(TYPE_CONTINUOUS)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_LSCALE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetReset(RESET_EVENT+0x1fc0000)
	e4:SetValue(7)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e5)

end