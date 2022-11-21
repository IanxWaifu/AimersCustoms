--Scripted by IanxWaifu
--Girls'&'Arms - Voidalia
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x12EE),2,2,s.lcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.eftg)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.addcon)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end

--Direct Attack
function s.eftg(e,c)
	return e:GetHandler():GetMutalLinkedGroup():IsContains(c) and c:IsSetCard(0x12EE) and c:IsLinkMonster()
end

function s.spcfilter(c,lg)
    return lg:IsExists(s.cgfilter,1,nil)
end
function s.Faceupfilter(c)
	return c:IsSetCard(0x12EF) and c:IsFaceup() and c:IsType(TYPE_CONTINUOUS)
end
function s.cgfilter(c)
    local cg=c:GetColumnGroup()
    return cg:IsExists(s.Faceupfilter,1,nil)
end

--[[function s.addcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local lg=e:GetHandler():GetLinkedGroup()
    if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,lg) end
    local scg=Group.CreateGroup()
    for tc in aux.Next(lg) do
        local tcg=tc:GetColumnGroup()
        local ftcg=tcg:Filter(s.Faceupfilter,nil)
        scg=scg+ftcg
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=scg:Select(tp,1,1,true,nil)
    Duel.SendtoGrave(g,REASON_COST)
end--]]

function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp 
end
function s.addfilter(c)
	return c:IsSetCard(0x12EE) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.addfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


--Sp send banish
function s.cfilter(c)
	return c:IsSetCard(0x12EE) and c:IsAbleToGrave() and c:IsLinkMonster()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToGrave() end
	if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end


function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_LINK) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and c:IsSetCard(0x12EE)
end
function s.chkfilter(c,lv,ft)
	return c:IsFaceup() and c:IsAbleToGrave() and c:GetLink()>=lv and (ft>-1 or c:IsInMainMZone(tp))  and  c:IsSetCard(0x12EE) and c:IsLinkMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if chkc then return sg:IsContains(chkc) and chkc:IsLinkBelow(e:GetLabel()) end
	if #sg==0 then return false end
	local mg,mlv=sg:GetMinGroup(Card.GetLink)
	local elv=e:GetHandler():GetLink()
	local lv=(elv>=mlv) and 1 or (mlv-elv)
	if chk==0 then return ft>-1 and e:GetHandler():IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),lv,ft) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if chkc then return sg:IsContains(chkc) and chkc:IsLinkBelow(e:GetLabel()) end
	if #sg==0 then return false end
	local mg,mlv=sg:GetMinGroup(Card.GetLink)
	local elv=e:GetHandler():GetLink()
	local lv=(elv>=mlv) and 1 or (mlv-elv)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.chkfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),lv,ft)
	local slv=elv+g:GetFirst():GetLink()
	Duel.SendtoGrave(g,REASON_EFFECT)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	e:SetLabel(slv)
	local g=sg:FilterSelect(tp,Card.IsLinkBelow,1,1,nil,slv)
	e:SetLabelObject(g)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
