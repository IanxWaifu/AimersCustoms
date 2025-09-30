--Scripted by Aimer
--Exosister Zefrakalis
local s,id=GetID()
function s.initial_effect(c)
	s.selfattached_flaggedmonsters={} 
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Pendulum Summon restriction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	--Special Summon self from Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_GRAVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--On Summon: Special Summon Exosister Xyz + attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Effect
	local ge=Effect.CreateEffect(c)
	ge:SetDescription(aux.Stringid(id,4))
	ge:SetCategory(CATEGORY_REMOVE)
	ge:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	ge:SetCode(EVENT_LEAVE_GRAVE)
	ge:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	ge:SetRange(LOCATION_MZONE)
	ge:SetCountLimit(1,{id,2})
	ge:SetCondition(s.grantcon)
	ge:SetTarget(s.granttg)
	ge:SetOperation(s.grantop)
	c:RegisterEffect(ge)
	if not s.global_check then
	    s.global_check=true
	    local ge1=Effect.GlobalEffect()
	    ge1:SetType(EFFECT_TYPE_FIELD)
	    ge1:SetCode(EFFECT_UPDATE_ATTACK)
	    ge1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	    ge1:SetTarget(aux.TargetBoolFunction(s.effcon))
	    ge1:SetValue(s.apply_hint)
	    Duel.RegisterEffect(ge1,0)
	    -- Global effect 2: watch for detachment
	    local ge2=Effect.GlobalEffect()
	    ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    ge2:SetCode(EVENT_ADJUST)
	    ge2:SetOperation(s.detached_check)
	    Duel.RegisterEffect(ge2,0)
    end
end

s.listed_names={8958656}
s.listed_series={SET_EXOSISTER,SET_ZEFRA}

--Summon Limi
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_EXOSISTER) or c:IsSetCard(SET_ZEFRA) then return false end
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM 
end

-- Apply hint to monsters that have at least one overlay of this card
function s.apply_hint(e,c)
    local mg=c:GetOverlayGroup()
    local attached_count = mg:FilterCount(Card.IsCode,nil,id)
    if attached_count>0 and c:GetFlagEffect(id)==0 then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1,true)
        s.selfattached_flaggedmonsters[c]=e1
    end
    return 0
end

function s.effcon(c)
    return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,id)
end

-- Check flagged monsters for detachment
function s.detached_check(e,tp,eg,ep,ev,re,r,rp)
    for c,effect_ref in pairs(s.selfattached_flaggedmonsters) do
        if c:IsFaceup() then
            local mg=c:GetOverlayGroup()
            if mg:FilterCount(Card.IsCode,nil,id)==0 then
                -- Remove flag
                c:ResetFlagEffect(id)
                -- Remove client hint effect
                if effect_ref then
                    effect_ref:Reset()
                end
                s.selfattached_flaggedmonsters[c]=nil
            end
        else
            s.selfattached_flaggedmonsters[c]=nil
        end
    end
end

--Special Summon self from PZone
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,8958656),tp,LOCATION_ONFIELD,0,1,nil) then
			Duel.BreakEffect()
			Duel.Recover(tp,800,REASON_EFFECT)
		end
	end
end

--Summon Exosister Xyz
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(SET_EXOSISTER) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.matfilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_EXOSISTER) or c:IsSetCard(SET_ZEFRA)) and c:IsMonster()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		-- Optionally attach Exosister/Zefra from field or face-up EXTRA|LOCATION_MZONE
		local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE|LOCATION_EXTRA,0,sc)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local mg=g:Select(tp,1,#g,sc)
			sc:SetMaterial(mg)
			Duel.Overlay(sc,mg)
			sc:CompleteProcedure()
		end
	end
end


function s.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard({SET_EXOSISTER,ZET_ZEFRA}) and c:IsType(TYPE_XYZ) and e:GetHandler():GetOverlayGroup():IsContains(c)
end

function s.sefilter(c,tp)
	return c:IsAbleToRemove() and c:IsPreviousLocation(LOCATION_GRAVE) and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_ONFIELD)) and c:IsControler(1-tp)
end

function s.grantcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sefilter,1,nil,tp)
end

function s.granttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.sefilter,1,nil,tp) end
	local g=eg:Filter(s.sefilter,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

function s.grantop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.sefilter,nil,tp)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
