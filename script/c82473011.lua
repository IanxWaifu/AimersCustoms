--Scripted by Aimer
--Genosynx Amalgamation
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Unaffected by your own cards/effects, and effects that target it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--Target any number; SS them, then mandatory Link/Synchro/Xyz Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.extg_any())
	e4:SetOperation(s.exop_any())
	c:RegisterEffect(e4)
	-- If an Xyz Monster is Special Summoned to your field:
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,5))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.attcon)
	e5:SetTarget(s.atttg)
	e5:SetOperation(s.attop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_GENOSYNX}
s.listed_names={id}

----------Immunities--------------
function s.immval(e,te)
	local c=e:GetHandler()
	local tp=c:GetControler()
	if not te then return false end
	--unaffected by your own cards/effects
	if te:GetOwnerPlayer()==tp then return true end
	--unaffected by effects that target it (either player)
	if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		return g and g:IsContains(c)
	end
	return false
end
function s.statstg(e,c)
	return c:IsType(TYPE_SPIRIT)
end


---------Specialed Xyz Attach---------------
function s.xyzfilter(c,tp)
    return c:IsType(TYPE_XYZ) and c:IsControler(tp)
end

function s.attcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.xyzfilter,1,nil,tp)
end

function s.attachfilter(c)
    return c:IsSetCard(SET_GENOSYNX)
end

function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsType(TYPE_XYZ) end
    if chk==0 then return eg:IsExists(s.xyzfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=eg:Filter(s.xyzfilter,nil,tp)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    Duel.SetTargetCard(tc)
end

function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local mat=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if not mat then return end
    Duel.Overlay(tc,mat)
end


---------Mass Spirit/Trap SS -> mandatory ED summon---------------

function s.ssmonfilter(c,e,tp)
	if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
	return c:IsSetCard(SET_GENOSYNX) and c:IsType(TYPE_SPIRIT) and c:IsMonster() and c:IsCanBeEffectTarget(e) 
end

function s.sstrapfilter(c,e,tp)
	if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
	if not c:IsTrap() then return false end
	c:AssumeProperty(ASSUME_TYPE,TYPE_MONSTER|TYPE_SPIRIT)
	c:AssumeProperty(ASSUME_RACE,RACE_BEAST)
	c:AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_DARK)
	c:AssumeProperty(ASSUME_LEVEL,4)
	c:AssumeProperty(ASSUME_DEFENSE,1000)
	c:AssumeProperty(ASSUME_ATTACK,1000)
	return c:IsSetCard(SET_GENOSYNX) and c:IsCanBeEffectTarget(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK) and not c:IsForbidden()
end

function s.matfilter(c,e,tp)
	if c:IsMonster() then
		return s.ssmonfilter(c,e,tp)
	else
		return s.sstrapfilter(c,e,tp)
	end
end
function s.relfilter(c,e,tp)
	if c:IsMonster() then
		return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else 
		return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
	end
end
function s.chkfilter(c,e,tp)
	if c:IsMonster() then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else 
		return c:IsCanBeSpecialSummoned(e,0,tp,true,false)
	end
end
-- “any of Link/Synchro/Xyz” extra filter (pool-based check)
function s.exfilter_any()
	return function(c,mg,tp,chk)
		if not (c:IsType(TYPE_LINK) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ)) or not c:IsSetCard(SET_GENOSYNX) then return false end
		if chk and Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
		if not mg then return true end
		if c:IsType(TYPE_LINK) then
			return c:IsLinkSummonable(nil,mg)
		elseif c:IsType(TYPE_SYNCHRO) then
			return c:IsSynchroSummonable(nil,mg)
		else
			return c:IsXyzSummonable(nil,mg)
		end
	end
end

-- cancel/selection constraint: sg is a POOL, not “must use all”
function s.rescon_any(exg)
	return function(sg,e,tp,mg)
		local _1,_2=aux.dncheck(sg,e,tp,mg)
		if not _1 then return false,_2 end
		return exg:IsExists(s.exfilter_any(),1,nil,sg,tp,true),_2
	end
end

-- NEW: combined target (SelectUnselectGroup still drives it)
function s.extg_any()
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local exg=Duel.GetMatchingGroup(s.exfilter_any(),tp,LOCATION_EXTRA,0,nil,nil,tp)
		local cancelcon=s.rescon_any(exg)
		if chkc then
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsSetCard(SET_GENOSYNX) and cancelcon(Group.FromCards(chkc)) and s.chkfilter(chkc,e,tp)
		end
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
		local min=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or #mg,1)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if chk==0 then
			return min>0 and Duel.IsPlayerCanSpecialSummonCount(tp,2)
				and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
				and aux.SelectUnselectGroup(mg,e,tp,min,ft,cancelcon,0)
		end
		local sg=aux.SelectUnselectGroup(mg,e,tp,min,ft,cancelcon,chk,tp,HINTMSG_SPSUMMON,cancelcon)
		Duel.SetTargetCard(sg)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
	end
end

-- NEW: combined operation (summon chosen ED monster directly)
function s.exop_any()
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetTargetCards(e):Filter(s.relfilter,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or #g==0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
		for tc in aux.Next(g) do
			if tc:IsMonster() then
				Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				tc:RegisterEffect(e2)
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e3:SetValue(LOCATION_DECK)
				tc:RegisterEffect(e3,true)
				tc:RegisterFlagEffect(id,RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
			elseif tc:IsTrap() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_GENOSYNX,TYPE_EFFECT|TYPE_MONSTER|TYPE_SPIRIT,1000,1000,4,RACE_BEAST,ATTRIBUTE_DARK) then
				tc:AddMonsterAttribute(TYPE_EFFECT|TYPE_SPIRIT|TYPE_TRAP)
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_RACE)
				e1:SetValue(RACE_BEAST)
				e1:SetReset(RESET_EVENT|RESET_TOGRAVE|RESET_REMOVE|RESET_TEMP_REMOVE|RESET_TOHAND|RESET_TODECK|RESET_OVERLAY)
				tc:RegisterEffect(e1,true)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e3:SetValue(ATTRIBUTE_DARK)
				tc:RegisterEffect(e3,true)
				local e4=e1:Clone()
				e4:SetCode(EFFECT_CHANGE_LEVEL)
				e4:SetValue(4)
				tc:RegisterEffect(e4,true)
				local e5=e1:Clone()
				e5:SetCode(EFFECT_SET_BASE_ATTACK)
				e5:SetValue(1000)
				tc:RegisterEffect(e5,true)
				local e6=e1:Clone()
				e6:SetCode(EFFECT_SET_BASE_DEFENSE)
				e6:SetValue(1000)
				tc:RegisterEffect(e6,true)
				Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
				tc:AddMonsterAttributeComplete()
				local e7=Effect.CreateEffect(e:GetHandler())
				e7:SetType(EFFECT_TYPE_SINGLE)
				e7:SetCode(EFFECT_DISABLE)
				e7:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e7)
				local e8=e7:Clone()
				e8:SetCode(EFFECT_DISABLE_EFFECT)
				tc:RegisterEffect(e8)
				local e9=Effect.CreateEffect(e:GetHandler())
				e9:SetType(EFFECT_TYPE_SINGLE)
				e9:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e9:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e9:SetValue(LOCATION_DECK)
				tc:RegisterEffect(e9,true)
				tc:RegisterFlagEffect(id,RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
			end
		end
		Duel.SpecialSummonComplete()
		Duel.BreakEffect()
		-- pick any valid Link/Synchro/Xyz from Extra using this exact group
		local exg=Duel.GetMatchingGroup(s.exfilter_any(),tp,LOCATION_EXTRA,0,nil,g,tp,true)
		if #exg==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=exg:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
		if sc:IsType(TYPE_LINK) then
			Duel.LinkSummon(tp,sc,nil,g)
		elseif sc:IsType(TYPE_SYNCHRO) then
			Synchro.Send=5
			Duel.SynchroSummon(tp,sc,nil,g)
		else
			Duel.XyzSummon(tp,sc,nil,g)
		end
	end
end