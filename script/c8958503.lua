--Scripted by Aimer
--Vylon Zeta
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself (hand or GY) if you control a "Vylon" Equip Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--If Special Summoned this way: destroy 1 Vylon card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Add 1 Vylon Spell and equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VYLON}

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c:IsType(TYPE_EQUIP)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil)
end


--Destruction on Special Summon
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_ONFIELD,0,1,1,nil,SET_VYLON)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end


-- Add + Equip (equip card first, then monster; prevents equipping the only monster to itself)
function s.thfilter(c) return c:IsSetCard(SET_VYLON) and c:IsSpell() and c:IsAbleToHand() end
function s.eqfilter(c,tp,mc)
	if not c:IsSetCard(SET_VYLON) or c:IsForbidden() or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
	if c:IsMonster() then
		local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_VYLON)
		if ct==1 and c:IsLocation(LOCATION_MZONE) then return false end -- can't equip to the only monster on field
	end
	return true
end
function s.monfilter(c,ec) return c:IsFaceup() and c:IsSetCard(SET_VYLON) and c~=ec end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_MZONE,0,1,nil,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #tg>0 then
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
	end
end
--[[	if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local egc=Duel.SelectMatchingCard(tp,function(c) return s.eqfilter(c,tp,nil) end,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not egc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local mc=Duel.SelectMatchingCard(tp,function(c) return s.monfilter(c,egc) end,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not mc then return end
	if Duel.Equip(tp,egc,mc) then
		local e1=Effect.CreateEffect(egc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==mc end)
		egc:RegisterEffect(e1)
	end--]]



