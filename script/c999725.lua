--Dragocyene Crystallagmite
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,nil,3,nil,s.matcheck)
	--indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Counter Place
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,{id,1})
	e4:SetOperation(s.pcop)
	c:RegisterEffect(e4)
	--Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1,{id,2})
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk,counter_amount) return Aimer.FrostrineCounterCost(e,tp,eg,ep,ev,re,r,rp,chk,3) end )
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	
end

s.listed_series={SET_ICYENE,SET_DRAGOCYENE}
s.counter_list={COUNTER_ICE}

--indes
function s.indtg(e,c)
	return c:IsSetCard(SET_CYENE) and e:GetHandler():GetLinkedGroup():IsContains(c)
end

--Material Check
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,SET_DRAGOCYENE) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_LINK and e:GetLabel()==1
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end


function s.pcfilter(c)
	return c:IsFaceup()
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do 
		tc:AddCounter(COUNTER_ICE,1)
	end
end


--Special Summon
--Tribute + Special Summon
function s.cfilter(c,e,tp,ft,lg)
	return (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_RITUAL)) and c:IsSetCard(SET_DRAGOCYENE) and c:HasLevel() and lg:IsContains(c)
		and (ft>0 or c:IsInMainMZone(tp)) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetType())
end

function s.spfilter(c,e,tp,lv,type)
    return c:IsSetCard(SET_DRAGOCYENE) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
        and math.abs(c:GetLevel()-lv)<=2 and math.abs(c:GetLevel()-lv)>0 and c:GetType()~=type and (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_RITUAL))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp,ft,lg) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE) <=-1 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local lg=e:GetHandler():GetLinkedGroup()
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp,ft,lg)
	local tc=g:GetFirst()
	local lv=tc:GetLevel()
	local type=tc:GetType()
	local dg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,lv,type)
	if Duel.Release(g,REASON_EFFECT)~=0 and #dg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local dg2=dg:Select(tp,1,1,nil)
		Duel.SpecialSummon(dg2,0,tp,tp,false,true,POS_FACEUP)
	end
end
