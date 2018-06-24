local toggles = {};
toggles.enabled = ui.new_checkbox("AA", "Anti-aimbot angles", 
    "Change angle on hit");

local sliders = {};
sliders.reset_time = ui.new_slider("AA", "Anti-aimbot angles", "Reset time", 1,
    10, 1, true, "s");

local refs = {};
refs.yaw = ui.reference("AA", "Anti-aimbot angles", "Yaw");

-- set defaults
ui.set(toggles.enabled, false);
ui.set(sliders.reset_time, 1);

local antiaims = {
    "Sideways", "180 Z", "180"
};
-- used when all antiaims are blacklisted
-- set to nil if you want to reset the cycle
local fallback_antiaim = nil;

local cur_antiaim = antiaims[1];
local hit_antiaims = {};
local last_hit_time = 0;

local function get_local_player()
    local local_player = entity.get_local_player();

    if entity.get_player_weapon(local_player) then
        return local_player
    else
        return nil;
    end
end

local function is_blacklisted(antiaim)
    local is_blacklisted = false;
    for _, val in pairs(hit_antiaims) do
        if val == antiaim then
            is_blacklisted = true;
        end
    end
    return is_blacklisted;
end

local function reset_antiaim()
    if cur_antiaim ~= antiaims[1] then
        cur_antiaim = antiaims[1];
        ui.set(refs.yaw, cur_antiaim);
    end
    for idx, _ in pairs(hit_antiaims) do
        table.remove(hit_antiaims, idx);
    end
    last_hit_time = 0;
end

local function change_antiaim()
    for _, val in pairs(antiaims) do
        if not is_blacklisted(val) then
            cur_antiaim = val;
            ui.set(refs.yaw, cur_antiaim);
            return;
        end
    end
    
    if fallback_antiaim ~= nil then
        ui.set(refs.yaw, fallback_antiaim);
    else
        reset_antiaim();
    end
end

local function on_player_hurt(e)
    if not ui.get(toggles.enabled) then
        return;
    end

    local local_player = get_local_player();

    if not local_player then
        return;
    end

    local victim_idx = client.userid_to_entindex(e.userid);
    if victim_idx == local_player and e.health > 0 then
        local hit_antiaim = ui.get(refs.yaw);
        table.insert(hit_antiaims, hit_antiaim);
        last_hit_time = globals.curtime();
        change_antiaim();
    end
end

local function on_paint(ctx)
    if globals.curtime() - last_hit_time > ui.get(sliders.reset_time) then
        reset_antiaim();
    end
end

client.set_event_callback("player_hurt", on_player_hurt);
client.set_event_callback("paint", on_paint);