local notifications = require("notifications");

local toggles = {};
toggles.enabled = ui.new_checkbox("AA", "Anti-aimbot angles", 
    "Change angle on hit");

local sliders = {};
sliders.reset_time = ui.new_slider("AA", "Anti-aimbot angles", "Reset time", 1,
    10, 1, true, "s");

-- set defaults
ui.set(toggles.enabled, false);
ui.set(sliders.reset_time, 1);

local antiaims = {
    {
        name: "Sideways"
    },
    {
        name: "180 Z"
    },
    {
        name: "180"
    }
};

local function get_local_player() then
    local local_player = entity.get_local_player();

    if (entity.get_player_weapon(local_player)) then
        return local_player
    else
        return nil;
    end
end

local function on_player_hurt(e)
    if (not ui.get(toggles.enabled)) then
        return;
    end

    if (not local_player) then
        return;
    end

    local victim_idx = client.userid_to_entindex(e.userid);
    if (victim_idx == local_player) then

    end
end

client.set_event_callback("player_hurt", on_player_hurt);