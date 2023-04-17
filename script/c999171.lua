--Scripted by IanxWaifu
--Beasketeer-Crimiorè, Altruist of Haze
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	--[[Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false)--]]
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	--Immunity
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.indes)
	e1:SetValue(s.unval)
	c:RegisterEffect(e1)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--send up to 2 equips
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	--send 1 equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.dcon)
	e4:SetCost(s.dcost)
	e4:SetTarget(s.dtg)
	e4:SetOperation(s.dop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={0x12A8,0x12A9}
s.minxyzct=2
s.maxxyzct=2
s.maintain_overlay=true

--[[--XyzCon
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsRank(4) and c:IsSetCard(0x12A9,xyz,sumtype,tp)
end
--]]

function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(4) and c:IsSetCard(0x12A9)
end	
function s.xyzcon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,2,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g2=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,g1:GetFirst())
	og=Group.CreateGroup()
	og:Merge(g1)
	og:Merge(g2)
	if g1:GetCount()>0 then
		local mg1=g1:GetFirst():GetOverlayGroup()
		if mg1:GetCount()~=0 then
			og:Merge(mg1)
			Duel.Overlay(g2:GetFirst(),mg1)
		end
		Duel.Overlay(g2:GetFirst(),g1)
		local mg2=g2:GetFirst():GetOverlayGroup()
		if mg2:GetCount()~=0 then
			og:Merge(mg2)
			Duel.Overlay(c,mg2)
		end
		c:SetMaterial(og)
		Duel.Overlay(c,g2:GetFirst())	
	end
end

--Immunity
function s.indes(e,c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--Equip/Detach
function s.xyzcheck(c)
    return c:IsSetCard(0x12A8) and not c:IsType(TYPE_XYZ)
end
function s.eqfilter(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.xyzcheck,1,nil)
end
function s.eqcheck(c)
    return c:IsSetCard(0x12A9) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
        local srg=Duel.GetMatchingGroup(s.eqcheck,tp,LOCATION_MZONE,0,nil)
        return #srg>0 and srg:IsExists(s.eqfilter,1,nil) and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_MZONE)
end



function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<=0 then return end
    --get all mats
    ::loop::
    local matg=Duel.GetOverlayGroup(tp,LOCATION_MZONE,0)
    local tg=matg:FilterSelect(tp,s.xyzcheck,1,#matg,nil)
    --star relic group to equip to
    local src=Duel.SelectMatchingCard(tp,s.eqcheck,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    for tc in aux.Next(tg) do
        Duel.Equip(tp,tc,src)
        --Equip limit
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
    local fmats=Duel.GetOverlayGroup(tp,LOCATION_MZONE,0):Filter(s.xyzcheck,nil)
    if #fmats>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        goto loop
    end
    Duel.EquipComplete()
end


function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.sendfilter(c)
	return c:IsAbleToGrave() and (c:IsSetCard(0x12A8) or c:IsSetCard(0x12A9))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,0)
end
function s.cfilter(c)
	return (c:IsSetCard(0x12A8) or c:IsSetCard(0x12A9)) and c:IsLocation(LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_ONFIELD,0,1,2,nil)
	if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		local g=Duel.GetOperatedGroup()
		local ct=g:FilterCount(s.cfilter,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		if #g2>0 then
			Duel.Destroy(g2,REASON_EFFECT)
		end
	end
end




--Set to Field
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0 or (e:GetHandler():GetFlagEffect(999161)>0 or Duel.IsPlayerAffectedByEffect(tp,999173))
end
function s.tgfilter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsAbleToGraveAsCost() and c:GetEquipTarget()==tc and c:IsSetCard(0x12A8)
end
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_SZONE,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_SZONE,0,1,1,nil,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.setfilter(c)
	return c:IsSetCard(0x12A9) and c:IsSSetable() and c:IsSpellTrap()
end
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		g:GetFirst():RegisterEffect(e2)
	end
end
--Test Operation Saving for Future Use

--[[function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<=0 then return end
    local g=Duel.GetMatchingGroup(s.eqcheck,tp,LOCATION_MZONE,0,nil)
    local eq=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_MZONE,0,nil)
    if ft==0 then return end
    for i=2,ft do
          Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
        local ec=eq:GetFirst():GetOverlayGroup():FilterSelect(tp,s.xyzcheck,1,1,nil):GetFirst()
        local tc=g:FilterSelect(tp,s.eqcheck,1,1,nil,ec):GetFirst()
        Duel.Equip(tp,ec,tc)
        --Equip limit
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e1)
        local check=eq:GetFirst():GetOverlayGroup():IsExists(s.xyzcheck,1,nil)
          if ft<=0 or Duel.SelectYesNo(tp,aux.Stringid(id,3)) or not check then
            break
          end
         Duel.EquipComplete()
    end
end--]]