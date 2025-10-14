require 'cfg/keybinds'

local lang = require 'gui.guilang'

local bindings = {}

bindings.readable_txt = {
	["mouse1"] = "Left click",
	["mouse2"] = "Right click",
	["mouse3"] = "Middle click",
	["mouse4"] = "Mouse button 4",
	["mouse5"] = "Mouse button 5",
	["wheelup"]   = "Mousewheel up",
	["wheeldown"] = "Mousewheel down",
	["tab"] = "Tab",
	["return"] = "Return",
	["space"] = "Space",
	["backspace"] = "Backspace",
	["lshift"] = "Left shift",
	["lctrl"] = "Left control",
	["lalt"] = "Left alt",
	["rshift"] = "Right shift",
	["rctrl"] = "Right control",
	["ralt"] = "Right alt",
	["up"] = "Up arrow",
	["down"] = "Down arrow",
	["left"] = "Left arrow",
	["right"] = "Right arrow",
}

function bindings.getReadableTxt(b)
	if not b then return nil end
	b = bindings.readable_txt[b] or b
	b = string.upper(b:sub(1,1)) .. b:sub(2,-1)
	return b
end

function bindings.getReadableTxt2(a,b)
	a = bindings.getReadableTxt(a)
	b = bindings.getReadableTxt(b)

	if a and b then
		return "~b".. a .. "/" .. b.."~r"
	elseif a then
		return "~b"..a.."~r"
	elseif b then
		return "~b"..b.."~r"
	else
		return "N/A"
	end
end

function bindings.controlTooltip()
	local function t(b)
		return bindings.getReadableTxt2(EDIT_KEY_SETTINGS[b][1], EDIT_KEY_SETTINGS[b][2])
	end
	local function t1(b)
		return bindings.getReadableTxt(EDIT_KEY_SETTINGS[b][1], EDIT_KEY_SETTINGS[b][2])
	end

	local string = ""
	string = string .. lang["Erase Pixel: "] .. t("edit_erase") .. "~n"
	string = string .. lang["Fill Face: "] .. t("edit_colour_fill") .. "~n"
	string = string .. lang["Pick Pixel Colour: "] .. t("edit_colour_pick") .. "~n ~n"
	string = string .. lang["Toggle Mirror: "] .. t("edit_mirror") .. "~n"
	string = string .. lang["Toggle Grid: "] .. t("edit_grid") .. "~n"
	string = string .. lang["Ignore Alpha Lock: "] .. t("edit_alpha_override") .. "~n"
	string = string .. lang["Hide/Show Overlay: "] .. t("edit_hide_overlay") .. "~n ~n"
	string = string .. lang["Hide/Show: "] .. "~n"
	string = string .. lang["Head: "] .. "~b".. t1("edit_hide_head") .. "~r~n"
	string = string .. lang["L Arm: "] .."~b".. t1("edit_hide_arm_l") .. "~r~n"
	string = string .. lang["R Arm: "] .."~b".. t1("edit_hide_arm_r") .. "~r~n"
	string = string .. lang["L Leg: "] .."~b".. t1("edit_hide_leg_l") .. "~r~n"
	string = string .. lang["R Leg: "] .."~b".. t1("edit_hide_leg_r") .. "~r~n"
	string = string .. lang["Torso: "] .."~b".. t1("edit_hide_torso") .. "~r~n"

	return string
end

return bindings
