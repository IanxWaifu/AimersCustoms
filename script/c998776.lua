--Scripted by IanxWaifu
--Girls'&'Arms - Miria
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x12EE),2,2,s.lcheck)
	c:EnableReviveLimit()
	--cannot activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.actcon)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--Gain ATK
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.tg)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	--Lose ATK
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.tg)
	e4:SetValue(-300)
	c:RegisterEffect(e4)
	--Move to 1 of your unused MMZ
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.seqtg)
	e5:SetOperation(s.seqop)
	c:RegisterEffect(e5)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.efilter(e,c)
	local cg=c:GetColumnGroup()
	return c:IsSetCard(0x12EF) and c:GetActivateEffect():IsHasType(EFFECT_TYPE_ACTIVATE) and cg:IsExists(s.fgfilter,1,nil)
end
function s.fgfilter(c)
	return c:IsSetCard(0x12EE) and c:IsType(TYPE_LINK)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	Duel.RegisterEffect(e2,tp)
end

function s.spcfilter(c,lg)
    return lg:IsExists(s.cgfilter2,1,nil)
end
function s.Faceupfilter(c)
	return c:IsSetCard(0x12EE) and c:IsFaceup() 
end
function s.cgfilter2(c)
    local cg=c:GetColumnGroup()
    return cg:IsExists(s.Faceupfilter,1,nil)
end
function s.tg(e,c)
	local g=e:GetHandler():GetColumnGroup(1,1)
	local cg=e:GetHandler():GetColumnGroup()
	return #g>0 and c~=e:GetHandler() and g:IsContains(c) and not cg:IsContains(c)
end

--[[function s.cgfilter(c)
	return not c:IsImmuneToEffect()
end--]]
	--Activation legality
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil) end
end
	--Move to Unoccupied
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,seq)
	e:SetLabel(math.log(seq,2))
	local seq2=e:GetLabel()
	if not Duel.CheckLocation(tp,LOCATION_MZONE,seq2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,seq2)
end



