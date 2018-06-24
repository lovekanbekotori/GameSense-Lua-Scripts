local toggles = {};
toggles.enabled = ui.new_checkbox("AA", "Fake lag", "Disable on revolver");

local refs = {};
refs.fake_lag = ui.reference("AA", "Fake lag", "Enabled");

local function get_local_player()
    local local_player = entity.get_local_player();

    if entity.get_player_weapon(local_player) then
        return local_player
    else
        return nil;
    end
end

local function on_paint(ctx)
    local local_player = get_local_player();

    if local_player == nil then
        return;
    end

    local weapon_idx = entity.get_player_weapon(local_player);
    local definition_idx = entity.get_prop(weapon_idx,
        "m_iItemDefinitionIndex");
    
    if definition_idx == 64 and ui.get(refs.fake_lag) then
        client.log("f");
        ui.set(refs.fake_lag, false);
    elseif definition_idx ~= 64 and not ui.get(refs.fake_lag) then
        client.log("t");
        ui.set(refs.fake_lag, true);
    end
end

client.set_event_callback("paint", on_paint);