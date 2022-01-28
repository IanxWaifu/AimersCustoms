--Scripted by IanxWaifu
--Girls’&’Artillery - StrikeZone
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e2:SetValue(s.tg)
	c:RegisterEffect(e2)
	--Co-Linked Group Keep Alive
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.colinkop)
	c:RegisterEffect(e3)
	--Special
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetLabelObject(e3)
	e4:SetCondition(s.secon)
	e4:SetOperation(s.seop)
	c:RegisterEffect(e4)
end
function s.tg(e,c)
	local lg=c:GetMutualLinkedGroupCount() 
	if lg>=1 then lg=lg+1 end
	return lg*200
end
function s.colinkop(e,tp,eg,ep,ev,re,r,rp)
	local clg=e:GetHandler():GetMutualLinkedGroup()
	e:SetLabelObject(clg)
	if #clg>0 then
		clg:KeepAlive()
	else
		clg:DeleteGroup()
	end
end
function s.sefilter(c,e,tp)
	return c:IsLinkMonster() and c:GetPreviousControler()==tp and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.secon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.sefilter,1,nil,e,tp) and g and #g>0
end



function s.seop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	local tg=eg:IsExists(s.sefilter,1,nil,e,tp) 
	local g2=tg:FilterSelect(tp,s.sefilter,1,1,nil,e,tp)
	local tc=g2:GetFirst()
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end