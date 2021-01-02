function countHate(ent, hate, damage, frenzy)
    return ent:IsClient()
end

function calcPveDmgMod(mob, player)
    local max = 5
    local count = mob:CountHateList(countHate)

    -- source:Message(15, "Hate count is: " .. count);
    -- source:Message(15, "IsClient? " .. tostring(source:IsClient()))

    local g = eq.get_entity_list():GetGroupByMob(player)

    local gclient = 0
    if g and g.valid then

        -- source:Message(15, "Group count is " .. g:GroupCount())

        for i = 0,g:GroupCount()-1,1
        do
            local m = g:GetMember(i)
            if not m:IsPet() then
                gclient = gclient + 1
            end

        end
    end

    -- source:Message(15, "Group count is: " .. gclient)
    if gclient > count then
        count = gclient
    end
    -- source:Message(15, "Total is: " .. count .. " mod: " .. (max - count) .. " base: " .. e.hit.damage_done)

    -- local hpR = source:GetHPRatio()/100.0

    if count < 1   then count = max; end
    if count > max then count = max; end

    -- source:Message(15, "HpRatio: " .. hpR)

    return max - count;
end

function ApplyAnyDamageTable(e)
    if e.hit.damage < 1 or e.attacker:IsBot() or e.self:IsBot() then
        return
    end

    local source = e.attacker;
    local targ = e.self;

    local playerSource = (source:IsClient() or (source:GetOwner() and source:GetOwner():IsClient()))
    local playerTarget = (targ:IsClient() or (targ:GetOwner() and targ:GetOwner():IsClient()))
    local mobTarget = not playerTarget

    --[[
    if playerTarget then
        targ:Message(15, "playerTarget " .. tostring(playerTarget) .. " playerSource? " .. tostring(playerSource))
    end
    if playerSource then
        source:Message(15, "playerTarget " .. tostring(playerTarget) .. " playerSource? " .. tostring(playerSource))
    end
    ]]--
    if playerTarget and not playerSource then
		-- targ:Message(15, "In taking")
		local dmgMod = calcPveDmgMod(source, targ)
		local base = e.hit.damage;
		if e.hit.damage > targ:GetMaxHP() then
			e.hit.damage = math.ceil(targ:GetMaxHP() * .1)
		else
			e.hit.damage = math.ceil(e.hit.damage/(1 + dmgMod));
		end
        -- e.hit.damage_done = e.hit.damage_done + (e.hit.damage_done * (max - count)) * hpR;
        -- targ:Message(15, "Taking: " .. base .. " .. Re-hit for: " .. e.hit.damage);
        return e;
    end

    if mobTarget and playerSource then
        local dmgMod = calcPveDmgMod(targ, source)
        local base = e.hit.damage;
        e.hit.damage = e.hit.damage + (e.hit.damage * dmgMod);
        -- e.hit.damage_done = e.hit.damage_done + (e.hit.damage_done * (max - count)) * hpR;
        -- source:Message(15, "Giving: " .. base .. " .. Re-hit for: " .. e.hit.damage);
        return e;
    end

    return e;
end

