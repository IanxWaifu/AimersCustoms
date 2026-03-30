--Scripted by Aimer
--Genosynx Genomorphosis
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Activate 1 of these effects
	local fustg,fusop=s.getFusionFuncs()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.effcost(fustg))
	e1:SetTarget(s.efftg(fustg,fusop))
	e1:SetOperation(s.effop(fustg,fusop))
	c:RegisterEffect(e1)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}
--Material Check
function s.getFusionFuncs()
	local fusfilter=aux.FilterBoolFunction(Card.IsType,TYPE_SPIRIT)
	local matfilter=s.matfilter
	local extrafil=s.fextra
	local extraop=s.fusextraop
	local extratg=s.fusextratg
	local nosummoncheck=true
	local location=LOCATION_EXTRA
	local value=0
	-- everything else you’re not using can stay nil
	return
		s.fustg(fusfilter,matfilter,extrafil,extraop,nil,nil,nil,value,location,nil,nil,extratg,nosummoncheck,nil,nil,nil),
		s.fusop(fusfilter,matfilter,extrafil,extraop,nil,nil,nil,value,location,nil,nil,nosummoncheck,nil,nil,nil)
end

function s.matfilter(c)
	if c:IsMonster() then return c:IsCanBeFusionMaterial() end
	return ((c:IsLocation(LOCATION_HAND|LOCATION_ONFIELD)) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()))
end

function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE,0,nil)
	if #eg>0 then
		return eg,nil
	end
	return nil
end
function s.fusextratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end 
--Remove Materials
function s.fusextraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end

function s.sstrapfilter(c,tp)
	if not (c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_TRAP)) then return false end
	if c:IsForbidden() then return false end
	return Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK)
end

function s.synfilter(c,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil)
end

function s.effcost(fustg)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		e:SetLabel(-100)

		--Effect 1
		local b1=not Duel.HasFlagEffect(tp,id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sstrapfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,tp)
		--Effect 2
		local b2=not Duel.HasFlagEffect(tp,id+1) and fustg(e,tp,eg,ep,ev,re,r,rp,0)
		--Effect 3
		local b3=not Duel.HasFlagEffect(tp,id+2) and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,tp)

		if chk==0 then return b1 or b2 or b3 end
	end
end


function s.efftg(fustg,fusop)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return false end
		local cost_skip=e:GetLabel()~=-100

		--Effect 1
		local b1=not Duel.HasFlagEffect(tp,id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.sstrapfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,tp)
		--Effect 2
		local b2=not Duel.HasFlagEffect(tp,id+1) and fustg(e,tp,eg,ep,ev,re,r,rp,0)
		--Effect 3
		local b3=not Duel.HasFlagEffect(tp,id+2) and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,tp)

		if chk==0 then e:SetLabel(0) return b1 or b2 or b3 end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)},
			{b3,aux.Stringid(id,2)})
		e:SetLabel(op)
		if op==1 then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
		elseif op==2 then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
			Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
		elseif op==3 then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			if not cost_skip then Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1) end
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		end
	end
end


function s.effop(fustg,fusop)
    return function(e,tp,eg,ep,ev,re,r,rp)
		local op=e:GetLabel()
		if op==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sstrapfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
			if sc then
				sc:AddMonsterAttribute(TYPE_EFFECT|TYPE_SPIRIT|TYPE_TRAP)
				sc:AddMonsterAttributeComplete()
				local e1=Effect.CreateEffect(sc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_RACE)
				e1:SetValue(RACE_BEAST)
				e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
				sc:RegisterEffect(e1,true)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e3:SetValue(ATTRIBUTE_DARK)
				sc:RegisterEffect(e3,true)
				local e4=e1:Clone()
				e4:SetCode(EFFECT_CHANGE_LEVEL)
				e4:SetValue(4)
				sc:RegisterEffect(e4,true)
				local e5=e1:Clone()
				e5:SetCode(EFFECT_SET_BASE_ATTACK)
				e5:SetValue(1000)
				sc:RegisterEffect(e5,true)
				local e6=e1:Clone()
				e6:SetCode(EFFECT_SET_BASE_DEFENSE)
				e6:SetValue(1000)
				sc:RegisterEffect(e6,true)
				Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)
			end
		elseif op==2 then
			    if fustg(e,tp,eg,ep,ev,re,r,rp,0) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                fusop(e,tp,eg,ep,ev,re,r,rp)
            end
		elseif op==3 then
			local g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,tp)
			if #g==0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			if not sc then return end
			Duel.SynchroSummon(tp,sc,nil)
		end
	end
end











----------Fusion for Traps-----------------
function s.SummonEffFilter(c,fusfilter,e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos,efmg)
	if efmg and #efmg>0 then
		if #(efmg:Match(s.GetExtraMatEff,nil,c))>0 then
			mg:Merge(efmg)
		end
	end
	return c:IsType(TYPE_FUSION) and (not fusfilter or fusfilter(c,tp)) and (nosummoncheck or c:IsCanBeSpecialSummoned(e,value,tp,sumlimit,false,sumpos))
			and c:CheckFusionMaterial(mg,gc,chkf)
end


function s.GetExtraMatEff(c,summon_card)
	local effs={c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL)}
	for _,eff in ipairs(effs) do
		if eff~=geff then
			if not summon_card then
				return eff
			end
			local val=eff:GetValue()
			if (type(val)=="function" and val(eff,summon_card)) or val==1 then
				return eff
			end
		end
	end
end

function s.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
	local extra_feff_mg=mg1:Filter(s.GetExtraMatEff,nil)
	if #extra_feff_mg>0 then
		local extra_feff=s.GetExtraMatEff(extra_feff_mg:GetFirst())
		--Check if you need to remove materials from the pool if count limit has been used
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			local extra_feff_loc=extra_feff:GetTargetRange()
			if extrafil then
				local extrafil_g=extrafil(e,tp,mg1)
				if extrafil_g and #extrafil_g>0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff_loc) then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				elseif not extrafil_g then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				end
			else
				mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
				efmg:Clear()
			end
		end
	elseif #efmg>0 then
		local extra_feff=s.GetExtraMatEff(efmg:GetFirst())
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			efmg:Clear()
		end
	end
	return mg1,efmg
end




function s.spelltrapfilter(c)
    return c:IsCanBeFusionMaterial() or c:IsSpellTrap()
end

function s.fustg(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,extratg,nosummoncheck,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				location=location or LOCATION_EXTRA
				if not chkf or ((chkf&PLAYER_NONE)~=PLAYER_NONE) then
					chkf=chkf and chkf|tp or tp
				end
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				if not value then value=0 end
				value = value|MATERIAL_FUSION
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION
				end
				local gc=gc2
				gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
				gc=type(gc)=="Card" and Group.FromCards(gc) or gc
				matfilter=matfilter or Card.IsAbleToGrave
				stage2 = stage2 or aux.TRUE
				if chk==0 then
					--Separate the Fusion Materials filtered by matfilter
					--and the ones with an EFFECT_EXTRA_FUSION_MATERIAL effect.
					--Both will be passed to s.SummonEffFilter later.
					local fmg_all=Duel.GetFusionMaterial(tp)
					local mg1=fmg_all:Filter(matfilter,nil,e,tp,0)
					local efmg=fmg_all:Filter(s.GetExtraMatEff,nil)
					local checkAddition=nil
					local repl_flag=false
					if #efmg>0 then
						local extra_feff=s.GetExtraMatEff(efmg:GetFirst())
						if extra_feff and extra_feff:GetLabelObject() then
							local repl_function=extra_feff:GetLabelObject()
							repl_flag=true
							-- no extrafil (Poly):
							if not extrafil then
								local ret = {repl_function[1](e,tp,mg1)}
								if ret[1] then
									ret[1]:Match(matfilter,nil,e,tp,0)
									Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
									mg1:Merge(ret[1])
								end
								checkAddition=ret[2]
							-- extrafil but no fcheck (Shaddoll Fusion):
							elseif extrafil then
								local ret = {extrafil(e,tp,mg1)}
								local repl={repl_function[1](e,tp,mg1)}
								if ret[1] then
									repl[1]:Match(matfilter,nil,e,tp,0)
									ret[1]:Merge(repl[1])
									Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
									mg1:Merge(ret[1])
								end
								if ret[2] then
									-- extrafil and fcheck (Cynet Fusion):
									checkAddition=aux.AND(ret[2],repl[2])
								else
									checkAddition=repl[2]
								end
							end
						end
					end
					if not repl_flag and extrafil then
						local ret = {extrafil(e,tp,mg1)}
						if ret[1] then
							Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=ret[2]
					end
					if gc and not mg1:Includes(gc) then
						Fusion.ExtraGroup=nil
						return false
					end
					Fusion.CheckAdditional=checkAddition
					mg1:Match(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
					Fusion.CheckExact=exactcount
					Fusion.CheckMin=mincount
					Fusion.CheckMax=maxcount
					mg1,efmg=s.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
					local res=Duel.IsExistingMatchingCard(s.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
					Fusion.CheckAdditional=nil
					Fusion.ExtraGroup=nil
					if not res and not notfusion then
						for _,ce in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}) do
							local fgroup=ce:GetTarget()
							local mg=fgroup(ce,e,tp,value)
							if #mg>0 and (not Fusion.CheckExact or #mg==Fusion.CheckExact) and (not Fusion.CheckMin or #mg>=Fusion.CheckMin) then
								local mf=ce:GetValue()
								local fcheck=nil
								if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
								Fusion.CheckAdditional=checkAddition
								if fcheck then
									if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
								end
								Fusion.ExtraGroup=mg
								if Duel.IsExistingMatchingCard(s.SummonEffFilter,tp,location,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos) then
									res=true
									Fusion.CheckAdditional=nil
									Fusion.ExtraGroup=nil
									break
								end
								Fusion.CheckAdditional=nil
								Fusion.ExtraGroup=nil
							end
						end
					end
					Fusion.CheckExact=nil
					Fusion.CheckMin=nil
					Fusion.CheckMax=nil
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
			end
end











function s.fusop(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				location=location or LOCATION_EXTRA
				chkf = chkf and chkf|tp or tp
				if not preselect then chkf=chkf|FUSPROC_CANCELABLE end
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				if not value then value=0 end
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION|MATERIAL_FUSION
				end
				local gc=gc2
				gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
				gc=type(gc)=="Card" and Group.FromCards(gc) or gc
				matfilter=matfilter or Card.IsAbleToGrave
				stage2 = stage2 or aux.TRUE
				local checkAddition
				--Same as line 167 above
				local fmg_all=Duel.GetFusionMaterial(tp)
				local mg1=fmg_all:Filter(matfilter,nil,e,tp,1)
				local efmg=fmg_all:Filter(s.GetExtraMatEff,nil)
				local extragroup=nil
				local repl_flag=false
				if #efmg>0 then
					local extra_feff=s.GetExtraMatEff(efmg:GetFirst())
					if extra_feff and extra_feff:GetLabelObject() then
						local repl_function=extra_feff:GetLabelObject()
						repl_flag=true
						-- no extrafil (Poly):
						if not extrafil then
							local ret = {repl_function[1](e,tp,mg1)}
							if ret[1] then
								ret[1]:Match(matfilter,nil,e,tp,1)
								Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
								mg1:Merge(ret[1])
							end
							checkAddition=ret[2]
						-- extrafil but no fcheck (Shaddoll Fusion):
						elseif extrafil then
							local ret = {extrafil(e,tp,mg1)}
							local repl={repl_function[1](e,tp,mg1)}
							if ret[1] then
								repl[1]:Match(matfilter,nil,e,tp,1)
								ret[1]:Merge(repl[1])
								Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
								mg1:Merge(ret[1])
							end
							if ret[2] then
								-- extrafil and fcheck (Cynet Fusion):
								checkAddition=aux.AND(ret[2],repl[2])
							else
								checkAddition=repl[2]
							end
						end
					end
				end
				if not repl_flag and extrafil then
					local ret = {extrafil(e,tp,mg1)}
					if ret[1] then
						Fusion.ExtraGroup=ret[1]:Filter(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
						extragroup=ret[1]
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1:Match(s.spelltrapfilter,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
				if gc and (not mg1:Includes(gc) or gc:IsExists(Fusion.ForcedMatValidity,1,nil,e)) then
					Fusion.ExtraGroup=nil
					return false
				end
				Fusion.CheckExact=exactcount
				Fusion.CheckMin=mincount
				Fusion.CheckMax=maxcount
				Fusion.CheckAdditional=checkAddition
				local effswithgroup={}
				--Same as line 191 above
				mg1,efmg=s.ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
				local sg1=Duel.GetMatchingGroup(s.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
				if #sg1>0 then
					table.insert(effswithgroup,{e,aux.GrouptoCardid(sg1)})
				end
				Fusion.ExtraGroup=nil
				Fusion.CheckAdditional=nil
				if not notfusion then
					local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
					for _,ce in ipairs(extraeffs) do
						local fgroup=ce:GetTarget()
						local mg2=fgroup(ce,e,tp,value)
						if #mg2>0 and (not Fusion.CheckExact or #mg2==Fusion.CheckExact) and (not Fusion.CheckMin or #mg2>=Fusion.CheckMin) then
							local mf=ce:GetValue()
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=mg2
							local sg2=Duel.GetMatchingGroup(s.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck,sumpos)
							if #sg2 > 0 then
								table.insert(effswithgroup,{ce,aux.GrouptoCardid(sg2)})
								sg1:Merge(sg2)
							end
							Fusion.CheckAdditional=nil
							Fusion.ExtraGroup=nil
						end
					end
				end
				if #sg1>0 then
					local sg=sg1:Clone()
					local mat1=Group.CreateGroup()
					local sel=nil
					local backupmat=nil
					local tc=nil
					local ce=nil
					while #mat1==0 do
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
						tc=sg:Select(tp,1,1,nil):GetFirst()
						if preselect and preselect(e,tc)==false then
							return
						end
						sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
						if sel[1]==e then
							Fusion.CheckAdditional=checkAddition
							Fusion.ExtraGroup=extragroup
							mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						else
							ce=sel[1]
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=ce:GetTarget()(ce,e,tp,value)
							mat1=Duel.SelectFusionMaterial(tp,tc,Fusion.ExtraGroup,gc,chkf)
						end
					end
					if sel[1]==e then
						Fusion.ExtraGroup=nil
						backupmat=mat1:Clone()
						if not notfusion then
							tc:SetMaterial(mat1)
						end
						--Checks for the case that the Fusion Summoning effect has an "extraop"
						local extra_feff_mg=mat1:Filter(s.GetExtraMatEff,nil,tc)
						if #extra_feff_mg>0 and extraop then
							local extra_feff=s.GetExtraMatEff(extra_feff_mg:GetFirst(),tc)
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								--If the operation of the EFFECT_EXTRA_FUSION_MATERIAL effect is different than "extraop",
								--it's not OPT or it hasn't been used yet, and the player
								--chooses to apply the effect, then select which cards
								--the effect will be applied to and execute its operation.
								if extra_feff_op and extraop~=extra_feff_op and extra_feff:CheckCountLimit(tp) then
									local flag=nil
									if extrafil then
										local extrafil_g=extrafil(e,tp,mg1)
										if #extrafil_g>=0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff:GetTargetRange()) then
											--The Fusion effect by default does not use the GY
											--so the player is forced to apply this effect.
											mat1:Sub(extra_feff_mg)
											extra_feff_op(e,tc,tp,extra_feff_mg)
											flag=true
										elseif #extrafil_g>=0 and Duel.SelectEffectYesNo(tp,extra_feff:GetHandler()) then
											--Select which cards you'll apply the
											--EFFECT_EXTRA_FUSION_MATERIAL effect to
											--and execute its operation.
											Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)
											local g=extra_feff_mg:Select(tp,1,#extra_feff_mg,nil)
											if #g>0 then
												mat1:Sub(g)
												extra_feff_op(e,tc,tp,g)
												flag=true
											end
										end
									else
										--The Fusion effect by default does not use the GY
										--so the player is forced to apply this effect.
										mat1:Sub(extra_feff_mg)
										extra_feff_op(e,tc,tp,extra_feff_mg)
										flag=true
									end
									--If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
									--then "use" its count limit.
									if flag and extra_feff:CheckCountLimit(tp) then
										extra_feff:UseCountLimit(tp,1)
									end
								end
							end
						end
						if extraop then
							if extraop(e,tc,tp,mat1)==false then return end
						end
						if #mat1>0 then
							--Split the group of selected materials to
							--"extra_feff_mg" and "normal_mg", send "normal_mg"
							--to the GY, and execute the operation of the
							--EFFECT_EXTRA_FUSION_MATERIAL effect, if it exists.
							--If it doesn't exist then send the extra materials to the GY.
							local extra_feff_mg,normal_mg=mat1:Split(s.GetExtraMatEff,nil,tc)
							local extra_feff
							if #extra_feff_mg>0 then extra_feff=s.GetExtraMatEff(extra_feff_mg:GetFirst(),tc) end
							if #normal_mg>0 then
								normal_mg=normal_mg:AddMaximumCheck()
								Duel.SendtoGrave(normal_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								if extra_feff_op then
									extra_feff_op(e,tc,tp,extra_feff_mg)
								else
									extra_feff_mg=extra_feff_mg:AddMaximumCheck()
									Duel.SendtoGrave(extra_feff_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
								end
								--If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
								--then "use" its count limit.
								if extra_feff:CheckCountLimit(tp) then
									extra_feff:UseCountLimit(tp,1)
								end
							end
						end
						Duel.BreakEffect()
						Duel.SpecialSummonStep(tc,value,tp,tp,true,true,sumpos)
					else
						Fusion.CheckAdditional=nil
						Fusion.ExtraGroup=nil
						ce:GetOperation()(sel[1],e,tp,tc,mat1,value,nil,sumpos)
						backupmat=tc:GetMaterial():Clone()
					end
					stage2(e,tc,tp,backupmat,0)
					Duel.SpecialSummonComplete()
					stage2(e,tc,tp,backupmat,3)
					if (chkf&FUSPROC_NOTFUSION)==0 then
						tc:CompleteProcedure()
					end
					stage2(e,tc,tp,backupmat,1)
				end
				stage2(e,nil,tp,nil,2)
				Fusion.CheckMin=nil
				Fusion.CheckMax=nil
				Fusion.CheckExact=nil
				Fusion.CheckAdditional=nil
			end
end