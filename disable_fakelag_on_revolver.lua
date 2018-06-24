local toggles = {};
toggles.enabled = ui.new_checkbox("AA", "Fake lag", "Disable on revolver");

local refs = {};
refs.fake_lag = ui.reference("AA", "Fake lag", "Enabled");

local function on_item_equip(e)
    if e.item == "revolver" and ui.get(refs.fake_lag) ~= false then
        ui.set(refs.fake_lag, false);
    else
        ui.set(refs.fake_lag, true);
    end
end

client.set_event_callback("item_equip", on_item_equip);