--Novalxon Sojourn
--Scripted by Aimer
local s,id=GetID()
Duel.LoadScript('AimersAux.lua')
function s.initial_effect(c)
	--Banish and Return/ Battle Positions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
	--Set this card from your banishment
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NOVALXON),tp,LOCATION_ONFIELD,0,1,nil) end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Can be activated from the hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
end

s.listed_series={SET_NOVALXON}
s.listed_names={id}

--set fromm banished
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end
--from hand
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_NOVALXON) and c:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)>0
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

--banish your cards
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end

function s.bpfilter(c,seqs)
    if type(seqs)=="table" then
        for _,seq in ipairs(seqs) do
            local oppseq=4-seq
            if oppseq==c:GetSequence() then
                return c:IsFaceup() and c:IsCanChangePosition()
            end
        end
    end
    return false
end

function s.rmfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_NOVALXON) and c:GetFlagEffect(REGISTER_FLAG_ASTRAL_STATE)==0
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,99,nil)
    if #g>0 then
        Duel.HintSelection(g)
        if Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 then
        	local rmg=Duel.GetOperatedGroup()
        	g=g:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
            g:KeepAlive()
            for tc in aux.Next(g) do
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
            end
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetLabelObject(g)
            e1:SetCountLimit(1)
            e1:SetLabel(Duel.GetTurnCount())
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetCondition(s.retcon)
            e1:SetOperation(s.retop)
      		Duel.RegisterEffect(e1,tp)
            local seqs={}
            for stc in aux.Next(rmg) do
                local seq=stc:GetPreviousSequence()
                table.insert(seqs,seq)
            end
            local bpg=Duel.GetMatchingGroup(s.bpfilter,tp,0,LOCATION_MZONE,nil,seqs) 
            Duel.ChangePosition(bpg,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
            --Negate the effects of bpg
			for negtc in bpg:Iter() do
				negtc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
			end
        end
    end
end

--Return next turn
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    	local g=e:GetLabelObject()
    	for tc in aux.Next(g) do
	        if tc:GetFlagEffect(id)~=0 then
	            return Duel.GetTurnCount()==e:GetLabel()
	        else
	        e:Reset()
	        return false
	    end
    end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local emzft=Duel.GetLocationCount(tp,LOCATION_EMZONE)
    -- Add EMZ space if needed
    if emzft>0 then
        ft=ft+emzft
    end
    for tc in aux.Next(g) do
        local seq=tc:GetPreviousSequence()
        local zone=Duel.GetFieldCard(tp,LOCATION_ONFIELD,seq)
        tc:ResetFlagEffect(id)
        if zone~=nil then g:RemoveCard(tc) end
        if seq>6 then
            Duel.SendtoGrave(tc,REASON_RULE+REASON_RETURN)
        end
    end
    -- Select up to the available zones (ft)
    local tg=g:Select(tp,1,ft,nil)
    for tcg in aux.Next(tg) do
        local seq=tcg:GetPreviousSequence()
        local zone=0x1<<seq
        if seq>6 then
            Duel.SendtoGrave(tcg,REASON_RULE+REASON_RETURN)
        else
            Duel.ReturnToField(tcg,tcg:GetPreviousPosition(),zone,tp)
        end
    end
end

