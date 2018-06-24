local sliders = {};
sliders.ground_limit = ui.new_slider("AA", "Fake lag", "Ground limit", 2, 14);
sliders.air_limit = ui.new_slider("AA", "Fake lag", "Air limit", 2, 14);
sliders.slow_motion_limit = ui.new_slider("AA", "Fake lag", "Slow motion limit",
    2, 14);

local keys = {};
keys.slow_motion = ui.new_hotkey("AA", "Fake lag", "Slow motion key");

local refs = {};
refs.limit = ui.reference("AA", "Fake lag", "Limit");
ui.set_visible(refs.limit, false);

local function get_local_player()
    local local_player = entity.get_local_player();

    if entity.get_player_weapon(local_player) then
        return local_player
    else
        return nil;
    end
end

local function on_paint(ctx)
    local limit = ui.get(refs.limit);

    local local_player = get_local_player();

    if local_player == nil then
        return;
    end

    local flags = entity.get_prop(local_player, "m_fFlags");
    local onground = bit.band(flags, bit.lshift(1, 0));

    if onground == 1 then
        if ui.get(keys.slow_motion) then
            if limit ~= slow_motion_limit then
                ui.set(refs.limit, ui.get(sliders.slow_motion_limit));
            end
        else
            if limit ~= ground_limit then
                ui.set(refs.limit, ui.get(sliders.ground_limit));
            end
        end
    else
        if limit ~= air_limit then
            ui.set(refs.limit, ui.get(sliders.air_limit));
        end
    end
end

client.set_event_callback("paint", on_paint);