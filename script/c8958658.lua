--Scripted by Aimer
--Evilswarm Zefraboros
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Material Check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	--Special from returned card list
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.rspcon)
	e2:SetTarget(s.rsptg)
	e2:SetOperation(s.rspop)
	c:RegisterEffect(e2)
	-- main card
	local e_override=Effect.CreateEffect(c)
	e_override:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e_override:SetCode(EVENT_ADJUST)
	e_override:SetRange(LOCATION_MZONE)
	e_override:SetOperation(function(e,tp) s.override_pzone_splimit(Duel.GetFieldCard(tp,LOCATION_PZONE,0),id) s.override_pzone_splimit(Duel.GetFieldCard(tp,LOCATION_PZONE,1),id) end)
	c:RegisterEffect(e_override)
	local e_splimit=Effect.CreateEffect(c)
	e_splimit:SetType(EFFECT_TYPE_FIELD)
	e_splimit:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e_splimit:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e_splimit:SetRange(LOCATION_MZONE)
	e_splimit:SetTargetRange(1,0)
	e_splimit:SetTarget(s.pzone_splimit_target)
	c:RegisterEffect(e_splimit)
end

s.listed_series={SET_ZEFRA}

--Link Procedure with listed series
function s.is_zefra(c,lc,sumtype,tp)
	return c:IsSetCard(SET_ZEFRA,lc,sumtype,tp)
end

function s.matcheck(g,lc,sumtype,tp)
	for zefra in aux.Next(g) do
		if s.is_zefra(zefra,lc,sumtype,tp) then
			local series=zefra.listed_series
			if series and type(series)=="table" and #series>0 then
				local setcodes={}
				for _,code in ipairs(series) do
					if type(code)=="number" then table.insert(setcodes,code) end
				end
				if #setcodes>0 then
					if g:IsExists(function(c) if c==zefra or not c:IsMonster() then return false end
						for _,sc in ipairs(setcodes) do
							if c:IsSetCard(sc) then return true end
						end
					return false end,1,nil) then return true end
				end
			end
		end
	end
	return false
end

-- Material Check
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local all_series={}
	for tc in aux.Next(g) do
		if tc.listed_series and type(tc.listed_series)=="table" then
			for _,setcode in ipairs(tc.listed_series) do
				table.insert(all_series,setcode)
			end
		end
	end
	e:SetLabelObject(all_series)
end

--Special from Deck To Zone
function s.spfilter(c,e,tp,hc)
	local series=e:GetLabelObject():GetLabelObject()
	if not (series and type(series)=="table") then return false end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local zone=hc:GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return false end
	for _,setcode in ipairs(series) do
		if c:IsSetCard(setcode) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,zone) then return true end
	end
	return false
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hc=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(function(c) return s.spfilter(c,e,tp,hc) end,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetHandler()
	local zone=hc:GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,function(c) return s.spfilter(c,e,tp,hc) end,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end



--Special from Returned Card List
function s.rspcon(e,tp,eg,ep,ev,re,r,rp)
	for c in aux.Next(eg) do
		local valid = c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(SET_ZEFRA) and c:ListsArchetype(SET_ZEFRA)
		if valid then return true end
	end
	return false
end


function s.rspfilter(c,series,e,tp,hc)
	if not series or #series==0 then return false end
	local zone=hc:GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		if not c:IsFaceup() or Duel.GetLocationCountFromEx(tp,tp,nil,c,zone)==0 then return false end
	end
	for _,sc in ipairs(series) do
		if c:IsSetCard(sc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,zone) then
			return true
		end
	end
	return false
end

function s.rsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local series_list={}
		local seen_series={}
		local loc=LOCATION_EXTRA
		local hc=e:GetHandler()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_GRAVE|LOCATION_HAND end
		for tc in aux.Next(eg) do
			if tc:IsSetCard(SET_ZEFRA) and tc.listed_series then
				for _,sc in ipairs(tc.listed_series) do
					if not seen_series[sc] then
						table.insert(series_list, sc)
						seen_series[sc]=true
					end
				end
			end
		end
		e:SetLabelObject(series_list)
		if #series_list==0 then return false end
		return loc~=0 and Duel.IsExistingMatchingCard(function(c) return s.rspfilter(c,series_list,e,tp,hc) end,tp,loc,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE|LOCATION_HAND)
end



function s.rspop(e,tp,eg,ep,ev,re,r,rp)
	local series=e:GetLabelObject()
	if not series or #series==0 then return end
	local hc=e:GetHandler()
	local zone=e:GetHandler():GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_GRAVE|LOCATION_HAND end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(c) return s.rspfilter(c,series,e,tp,hc) end),tp,loc,0,1,1,nil)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end

--Override Pendulum Scales

-- override function moved outside
function s.override_pzone_splimit(pz,id)
    if not pz or not pz:IsLocation(LOCATION_PZONE) or pz:GetFlagEffect(id)>0 then return end
    pz:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    local effs={pz:GetCardEffect(EFFECT_CANNOT_SPECIAL_SUMMON)}
    for _,ce in ipairs(effs) do
        if ce:GetHandler()==pz then
            ce:Reset()
            local e_new=Effect.CreateEffect(pz)
            e_new:SetType(EFFECT_TYPE_FIELD)
            e_new:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e_new:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
            e_new:SetTargetRange(1,0)
            e_new:SetTarget(s.pzone_splimit_target)
            pz:RegisterEffect(e_new)
        end
    end
end

-- splimit target function moved outside
function s.pzone_splimit_target(e,c,sump,sumtype,sumpos,targetp)
    if (sumtype&SUMMON_TYPE_PENDULUM)~=SUMMON_TYPE_PENDULUM then return false end
    local tp=e:GetHandlerPlayer()
    local all_series={}
    for seq=0,1 do
        local tc=Duel.GetFieldCard(tp,LOCATION_PZONE,seq)
        if tc and tc.listed_series and type(tc.listed_series)=="table" then
            for _,setcode in ipairs(tc.listed_series) do
                table.insert(all_series,setcode)
            end
        end
    end
    for _,setcode in ipairs(all_series) do
        if c:IsSetCard(setcode) then return false end
    end
    return true
end