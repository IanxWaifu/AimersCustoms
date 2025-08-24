local s,id=GetID()
Duel.LoadScript('AimersAux.lua')

-- Global storage for multi-option labels per card
s._stored_label = {}

function s.initial_effect(c)
    -- Continuous chain reorder effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.chcon)
    e1:SetOperation(s.chainop)
    c:RegisterEffect(e1)

    -- Immunity
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)

    -- Cleanup storage at end of chain
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(function()
        s._chain_data = {}
    end)
    c:RegisterEffect(e3)

    s._chain_data = {}
end

-- Immunity
function s.immval(e,re)
    local c=e:GetHandler()
    if not (re:IsActivated() and c:IsFusionSummoned() and e:GetOwnerPlayer()==1-re:GetOwnerPlayer()) then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    return not g or not g:IsContains(c)
end

-- Condition: chain link ≥2 and OPT not set
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentChain()>=2 and Duel.GetFlagEffect(tp,id)==0
end

-- Helper: store the label and label object after a card's target/cost executes
function s.StoreLabel(e)
    local c = e:GetHandler()
    s._stored_label[c] = {label=e:GetLabel(), labelobj=e:GetLabelObject()}
end

-- Main chain swap operation
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id)~=0 then return end
    local chain_size = Duel.GetCurrentChain()
    if chain_size < 2 then return end

    -- Capture current chain data
    local chain_data = {}
    for i=1,chain_size do
        local te = Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
        local tg = Duel.GetChainInfo(i,CHAININFO_TARGET_CARDS)
        if te then
            table.insert(chain_data,{
                index=i,
                te=te,
                tg=tg,
                op=te:GetOperation(),
                chosen=false
            })
        end
    end
    s._chain_data = chain_data

    -- Prompt yes/no
    if not Duel.SelectYesNo(tp, aux.Stringid(id,0)) then return end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)

    -- Player selects new chain order
    local chosen = {}
    while #chosen < #chain_data do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
        local g = Group.CreateGroup()
        for _,info in pairs(chain_data) do
            if not info.chosen then g:AddCard(info.te:GetHandler()) end
        end
        local sc = g:Select(tp,1,1,nil):GetFirst()
        for _,info in pairs(chain_data) do
            if info.te:GetHandler()==sc and not info.chosen then
                table.insert(chosen,info)
                info.chosen=true
                break
            end
        end
    end

    -- Swap chain operations, restoring labels and targets
    for new_index,info in ipairs(chosen) do
        Duel.ChangeChainOperation(new_index,function(op_e,op_tp,op_eg,op_ep,op_ev,op_re,op_r,rp)
            -- Restore stored labels
            local stored = s._stored_label[info.te:GetHandler()]
            if stored then
                info.te:SetLabel(stored.label)
                info.te:SetLabelObject(stored.labelobj)
            end
            -- Restore targets
            if info.tg then Duel.SetTargetCard(info.tg) end
            -- Call original operation
            if info.op then info.op(op_e,op_tp,op_eg,op_ep,op_ev,op_re,op_r,rp) end
        end)
    end
end
