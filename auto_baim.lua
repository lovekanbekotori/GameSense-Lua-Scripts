local toggles = {};
toggles.auto_baim = ui.new_checkbox("RAGE", "Other", "Auto prefer body aim");

local sliders = {};
sliders.under_health = ui.new_slider("RAGE", "Other", "Body aim if under HP", 0,
    100, 0, true, "HP");
sliders.under_speed = ui.new_slider("RAGE", "Other", "Body aim if under speed",
    0, 320, 0);
sliders.after_shots = ui.new_slider("RAGE", "Other", "Body aim after shots",
    0, 10, 0);
sliders.after_misses = ui.new_slider("RAGE", "Other", "Body aim after misses",
    0, 10, 0);

local combos = {};
combos.target_selection = ui.new_combobox("RAGE", "Other", "Target selection", 
    {"Distance", "Near crosshair"});

ui.set(toggles.auto_baim, false);
ui.set(sliders.under_health, 0);
ui.set(sliders.under_speed, 0);
ui.set(sliders.after_shots, 0);
ui.set(sliders.after_misses, 0);
ui.set(combos.target_selection, "Near crosshair");

local refs = {};
refs.body_aim = ui.reference("RAGE", "Other", "Prefer body aim");

local old_body_aim = ui.get(refs.body_aim);
local body_aim = false;
local aim_shots = 0;
local aim_misses = 0;
local stored_target = nil;

local function distance_3d(x, y, z, x2, y2, z2)
    return math.sqrt(math.pow(x - x2, 2) + math.pow(y - y2, 2)
        + math.pow(z - z2, 2));
end

local function distance_2d(x, y, x2, y2)
    return math.sqrt(math.pow(x - x2, 2) + math.pow(y - y2, 2));
end

local function get_local_player()
    local local_player = entity.get_local_player();

    if entity.get_player_weapon(local_player) then
        return local_player
    else
        return nil;
    end
end

local function get_enemy_positions(ctx, screen_positions)
    local player_positions = {};

    local players = entity.get_players(true);
    
    for _, ent_idx in pairs(players) do
        local origin_x, origin_y, origin_z = entity.get_prop(ent_idx,
            "m_vecOrigin");

        if origin_x == nil or origin_y == nil or origin_z == nil then
            break;
        end;

        if screen_positions then
            local x, y = client.world_to_screen(ctx, origin_x, origin_y,
                origin_z);
            
            -- check if player is on screen
            if x == nil or y == nil then
                break;
            end

            local tbl = {};
            tbl.idx = ent_idx;
            tbl.x = x;
            tbl.y = y;
            table.insert(player_positions, tbl);
        else
            local tbl = {};
            tbl.idx = ent_idx;
            tbl.x = origin_x;
            tbl.y = origin_y;
            tbl.z = origin_z;
            table.insert(player_positions, tbl);            
        end
    end

    return player_positions;
end

local function get_target_enemy(ctx)
    local local_player = get_local_player();

    if local_player == nil then
        return;
    end

    local target_method = ui.get(combos.target_selection);

    if target_method == "Distance" then
        local origin_x, origin_y, origin_z = entity.get_prop(local_player,
            "m_vecOrigin");

        local positions_3d = get_enemy_positions(ctx, false);

        if #positions_3d == 0 then
            return nil;
        end

        local best_distance = 9999999999;
        local best_idx = nil;
        
        for _, pos in pairs(positions_3d) do
            local distance = distance_3d(origin_x, origin_y, origin_z,
                pos.x, pos.y, pos.z);
            if distance < best_distance then
                best_distance = distance;
                best_idx = pos.idx;
            end
        end

        return best_idx;
    elseif target_method == "Near crosshair" then
        local w, h = client.screen_size();

        local positions_2d = get_enemy_positions(ctx, true);

        if #positions_2d == 0 then
            return nil;
        end

        local best_fov = 9999999999;
        local best_idx = nil;
        
        for _, pos in pairs(positions_2d) do
            local distance = distance_2d(w / 2, h / 2, pos.x, pos.y);
            if distance < best_fov then
                best_fov = distance;
                best_idx = pos.idx;
            end
        end

        return best_idx;
    end
end

local function on_paint(ctx)
    if not ui.get(toggles.auto_baim) then
        return;
    end

    if stored_target == nil then
        stored_target = get_target_enemy(ctx);
    end

    local enemy = stored_target;

    if enemy == nil then
        return;
    end

    local health = entity.get_prop(enemy, "m_iHealth");
    local vel_x = entity.get_prop(enemy, "m_vecVelocity[0]");
    local vel_y = entity.get_prop(enemy, "m_vecVelocity[1]");
    local vel_z = entity.get_prop(enemy, "m_vecVelocity[2]");
    local speed = math.sqrt(vel_x * vel_x + vel_y * vel_y + vel_z * vel_z);

    if body_aim and ui.get(refs.body_aim) ~= "Always on" then
        old_body_aim = ui.get(refs.body_aim);
        ui.set(refs.body_aim, "Always on");
    end

    if not body_aim and ui.get(refs.body_aim) ~= old_body_aim then
        ui.set(refs.body_aim, old_body_aim);
    end

    body_aim = false;

    if health == nil or vel_x == nil or vel_y == nil or vel_z == nil then
        return;
    end
     
    if ui.get(sliders.under_health) > 0
        and health <= ui.get(sliders.under_health) then
        body_aim = true;
    end

    if ui.get(sliders.under_speed) > 0 
        and speed <= ui.get(sliders.under_speed) then
        body_aim = true;
    end
    
    if ui.get(sliders.after_shots) > 0 
        and aim_shots >= ui.get(sliders.after_shots) then
        body_aim = true;
    end

    if ui.get(sliders.after_misses) > 0
        and aim_misses >= ui.get(sliders.after_misses) then
        body_aim = true;
    end
end

local function on_aim_fire(e)
    stored_target = e.target;
    aim_shots = aim_shots + 1;
end

local function on_aim_miss(e)
    stored_target = e.target;
    aim_misses = aim_misses + 1;
end

local function on_player_death(e)
    if stored_target == nil then
        return;
    end

    local dead_idx = client.userid_to_entindex(e.userid);

    if dead_idx == stored_target then
        ui.set(refs.body_aim, old_body_aim);
        aim_shots = 0;
        aim_misses = 0;
        stored_target = nil;
    end
end

local function on_toggle()
    old_body_aim = ui.get(refs.body_aim);
end

client.set_event_callback("paint", on_paint);
client.set_event_callback("aim_fire", on_aim_fire);
client.set_event_callback("aim_miss", on_aim_miss);
client.set_event_callback("player_death", on_player_death);
ui.set_callback(toggles.auto_baim, on_toggle);