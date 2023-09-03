--Aimers Auxillary Functions

if not aux.AimersAux then
    aux.AimersAux = {}
    Aimer = aux.AimersAux
end

if not Aimer then
    Aimer = aux.AimersAux
end

--Common used cards
CARD_ZORGA = 999415



-- Gets cards Attribute countFunction to get the count of set bits (1s) in a card's attribute
function Aimer.GetAttributeCount(card)
    local att = card:GetAttribute()
    local count = 0
    while att > 0 do
        if att & 0x1 ~= 0 then
            count = count + 1
        end
        att = att >> 1
    end
    return count
end

