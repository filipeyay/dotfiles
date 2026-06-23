-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end

-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Appearance (gaps, bordas, cores)
beautiful.useless_gap = 1
beautiful.border_width = 2
beautiful.border_color_normal = "#000000"
beautiful.border_color_focus = "#ffffff"
beautiful.gap_single_client = true
-- Notification theme
beautiful.notification_bg = "#101010"
beautiful.notification_fg = "#ffffff"
beautiful.notification_border_width = 1
beautiful.notification_border_color = "#ffffff"
beautiful.notification_opacity = 1
beautiful.notification_font = "Terminess Nerd Font 13"
beautiful.notification_position = "top_right"
beautiful.notification_spacing = 8
beautiful.notification_padding = 16
beautiful.notification_icon_size = 32
beautiful.notification_timeout = 8

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile, -- layout master/stack (padrão)
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal },
	},
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Screenshot
local function screenshot_region()
	local timestamp = os.date("%Y%m%d_%H%M%S")
	local dir = os.getenv("HOME") .. "/Imagens/Capturas/"
	os.execute("mkdir -p " .. dir)
	local filename = dir .. "captura_" .. timestamp .. ".png"
	awful.spawn("maim -s -u " .. filename)
	naughty.notify({ title = "Screenshot", text = "Salvo: " .. filename, timeout = 2 })
end

-- Screen Tearing
awful.spawn.with_shell("picom --backend glx --vsync &")

-- Force keyboard layout
awful.spawn.with_shell("setxkbmap -layout us -variant intl")

-- Autolock
awful.spawn.with_shell(
	"xset s 300 && xss-lock -- i3lock -i /home/filipemsandrade/Imagens/Wallpaper/world-map-black-and-3840x2160-16671.png &"
)

-- Monitors
awful.spawn.with_shell("xrandr --output HDMI-A-0 --right-of eDP --auto")
-- Auto-setup primary monitor
local function setup_monitors()
	awful.spawn.easy_async("xrandr --query", function(stdout)
		if stdout:match("HDMI%-A%-0 connected") and not stdout:match("disconnected") then
			awful.spawn("xrandr --output HDMI-A-0 --primary --right-of eDP --auto")
		else
			awful.spawn("xrandr --output eDP --primary --auto --output HDMI-A-0 --off")
		end
	end)
end

setup_monitors()
screen.connect_signal("property::geometry", setup_monitors)

-- Touchpad
awful.spawn.with_shell("xinput set-prop 'ELAN071A:00 04F3:30FD Touchpad' 'libinput Tapping Enabled' 1")
awful.spawn.with_shell("xinput set-prop 'ELAN071A:00 04F3:30FD Touchpad' 'libinput Natural Scrolling Enabled' 1")

-- Systray
awful.spawn.with_shell("blueman-applet &")
awful.spawn.with_shell("nm-applet &")

-- Keyboard map indicator and switcher
kb_layout = wibox.widget.textbox()
kb_layout.font = "Terminess Nerd Font 12"

local function update_kb_layout()
	local f = io.popen("setxkbmap -query | grep layout | awk '{print $2}'")
	local layout = f:read("*line")
	f:close()
	if layout == "us" then
		kb_layout:set_text("US")
	elseif layout == "pt" then
		kb_layout:set_text("PT")
	else
		kb_layout:set_text("??")
	end
end
update_kb_layout()

kb_layout:buttons(gears.table.join(awful.button({}, 1, function()
	local f = io.popen("setxkbmap -query | grep layout | awk '{print $2}'")
	local current = f:read("*line"):gsub("%s+", "")
	f:close()

	if current == "us" then
		awful.spawn("setxkbmap pt")
	else
		awful.spawn("setxkbmap us -variant intl")
	end

	gears.timer.start_new(0.1, function()
		update_kb_layout()
	end)
end)))

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%H:%M - %a, %d %b %Y")
mytextclock.font = "Terminess Nerd Font 14"

-- Systray Icon
local mysystray = wibox.widget.systray()
mysystray:set_base_size(26)

-- Power Buttons
local lock_button = wibox.widget.textbox(" ")
lock_button:buttons(gears.table.join(awful.button({}, 1, function()
	awful.spawn("i3lock -i /home/filipemsandrade/Imagens/Wallpaper/world-map-black-and-3840x2160-16671.png")
end)))
lock_button.font = "Terminess Nerd Font 10"

local logout_button = wibox.widget.textbox("  ")
logout_button:buttons(gears.table.join(awful.button({}, 1, function()
	awesome.quit()
end)))
logout_button.font = "Terminess Nerd Font 10"

local reboot_button = wibox.widget.textbox("  ")
reboot_button:buttons(gears.table.join(awful.button({}, 1, function()
	awful.spawn("reboot")
end)))
reboot_button.font = "Terminess Nerd Font 10"

local shutdown_button = wibox.widget.textbox("  ")
shutdown_button:buttons(gears.table.join(awful.button({}, 1, function()
	awful.spawn("poweroff")
end)))
shutdown_button.font = "Terminess Nerd Font 10"

-- Volume Widget
local volume_widget = wibox.widget.textbox()
volume_widget.font = "Terminess Nerd Font 12"

local function update_volume()
	local f = io.popen("pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1")
	local volume = f:read("*line")
	f:close()
	local muted_f = io.popen("pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes'")
	local muted = muted_f:read("*line")
	muted_f:close()

	if muted == "yes" then
		volume_widget:set_text("󰝟 ")
	else
		volume_widget:set_text("󰕾 " .. (volume or "0") .. "%")
	end
end
update_volume()

-- Battery
-- Battery Widget
local battery_widget = wibox.widget.textbox()
battery_widget.font = "Terminess Nerd Font 12"

local function update_battery()
	local f = io.popen("cat /sys/class/power_supply/BAT0/capacity 2>/dev/null")
	local capacity = f:read("*line")
	f:close()

	local status_f = io.popen("cat /sys/class/power_supply/BAT0/status 2>/dev/null")
	local status = status_f:read("*line")
	status_f:close()

	if not capacity then
		battery_widget:set_text("")
		return
	end

	local icon = ""
	if status == "Charging" then
		icon = "󱐌"
	elseif status == "Discharging" then
		local cap_num = tonumber(capacity) or 0
		if cap_num > 80 then
			icon = "󰁹"
		elseif cap_num > 60 then
			icon = "󰁿"
		elseif cap_num > 40 then
			icon = "󰁽"
		elseif cap_num > 20 then
			icon = "󰁻"
		else
			icon = "󰂎"
		end
	else
		icon = "󰂄"
	end

	battery_widget:set_text(icon .. " " .. capacity .. "%")
end
update_battery()

-- Update every 30 seconds
local battery_timer = gears.timer({ timeout = 30 })
battery_timer:connect_signal("timeout", update_battery)
battery_timer:start()

-- Update every 2 seconds
local volume_timer = gears.timer({ timeout = 2 })
volume_timer:connect_signal("timeout", update_volume)
volume_timer:start()

-- Spacing
local separator = wibox.widget.textbox(" | ")
separator.font = "Terminess Nerd Font 10"

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function set_wallpaper(s)
	-- Wallpaper
	gears.wallpaper.maximized(
		"/home/filipemsandrade/Imagens/Wallpaper/world-map-black-and-3840x2160-16671.png",
		s,
		true
	)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		widget_template = {
			{
				{
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.align.horizontal,
				},
				widget = wibox.container.background,
			},
			layout = wibox.layout.align.horizontal,
		},
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s, height = 30 })

	-- Font
	beautiful.font = "Terminess Nerd Font 12"

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			mylauncher,
			separator,
			s.mytaglist,
			separator,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			separator,
			kb_layout,
			separator,
			volume_widget,
			separator,
			wibox.widget.systray(),
			separator,
			mytextclock,
			separator,
			battery_widget,
			separator,
			lock_button,
			logout_button,
			reboot_button,
			shutdown_button,
			separator,
			s.mylayoutbox,
		},
	})
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	-- Window navigation (h/j/k/l)
	awful.key({ modkey }, "h", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus left", group = "client" }),
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus down", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus up", group = "client" }),
	awful.key({ modkey }, "l", function()
		awful.client.focus.byidx(1)
	end, { description = "focus right", group = "client" }),

	-- Move Windows (Shift + h/j/k/l)
	awful.key({ modkey, "Shift" }, "h", function()
		awful.client.swap.byidx(-1)
	end, { description = "move left", group = "client" }),
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "move down", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "move up", group = "client" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.client.swap.byidx(1)
	end, { description = "move right", group = "client" }),

	-- Move windows between monitores (Ctrl+Right/Ctrl+Left)
	awful.key({ modkey, "Control" }, "Right", function()
		local c = client.focus
		if c then
			c:move_to_screen()
		end
		awful.screen.focus_relative(1)
	end, { description = "move to right monitor", group = "screen" }),
	awful.key({ modkey, "Control" }, "Left", function()
		local c = client.focus
		if c then
			c:move_to_screen()
		end
		awful.screen.focus_relative(-1)
	end, { description = "move to left monitor", group = "screen" }),

	-- Monitor focus (Ctrl+1, Ctrl+2)
	awful.key({ modkey, "Control" }, "1", function()
		for s in screen do
			if s.index == 1 then
				awful.screen.focus(s)
				break
			end
		end
	end, { description = "focus monitor 1 (eDP-1)", group = "screen" }),
	awful.key({ modkey, "Control" }, "2", function()
		for s in screen do
			if s.index == 2 then
				awful.screen.focus(s)
				break
			end
		end
	end, { description = "focus monitor 2 (HDMI-A-1)", group = "screen" }),

	-- Splith / Splitv
	awful.key({ modkey }, "b", function()
		awful.layout.set(awful.layout.suit.tile)
	end, { description = "splith", group = "layout" }),
	awful.key({ modkey }, "v", function()
		awful.layout.set(awful.layout.suit.tile.bottom)
	end, { description = "splitv", group = "layout" }),
	awful.key({ modkey }, "e", function()
		awful.layout.inc(1)
	end, { description = "toggle layout", group = "layout" }),

	-- Fullscreen
	awful.key({ modkey }, "f", function()
		local c = client.focus
		if c then
			c.fullscreen = not c.fullscreen
		end
	end, { description = "fullscreen", group = "client" }),

	-- Screenshot Keybinding
	awful.key({}, "Print", function()
		screenshot_region()
	end),

	-- Floating Window
	awful.key({ modkey, "Shift" }, "space", function()
		local c = client.focus
		if c then
			c.floating = not c.floating
		end
	end, { description = "toggle floating", group = "client" }),

	-- Terminal
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open terminal", group = "launcher" }),

	-- Close Window
	awful.key({ modkey }, "q", function()
		local c = client.focus
		if c then
			c:kill()
		end
	end, { description = "kill client", group = "client" }),

	-- Menu (rofi)
	awful.key({ modkey }, "d", function()
		awful.spawn("rofi -show drun -theme ~/.config/rofi/themes/custom.rasi")
	end, { description = "show menu", group = "launcher" }),

	-- Reload awesome
	awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),

	-- Exit
	awful.key({ modkey, "Shift" }, "e", awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- Volume
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
	end),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
	end),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
	end),

	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("brightnessctl set +5%")
	end),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("brightnessctl set 5%-")
	end),

	-- Back
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Focus
	awful.key({ modkey }, "a", function()
		local c = client.focus
		if c then
			local parent = c:parent()
			if parent then
				parent:emit_signal("request::activate")
			end
		end
	end, { description = "focus parent", group = "client" }),

	-- Risize Mode
	awful.key({ modkey }, "r", function()
		awful.spawn("xterm -e 'echo \"Use h/j/k/l to resize\"; read'")
	end, { description = "resize mode", group = "client" }),

	-- Prompt
	awful.key({ modkey }, "r", function()
		awful.screen.focused().mypromptbox:run()
	end, { description = "run prompt", group = "launcher" })
)

-- Workspaces 1-10
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "workspace " .. i, group = "tag" }),
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			local c = client.focus
			if c then
				local tag = c.screen.tags[i]
				if tag then
					c:move_to_tag(tag)
					tag:view_only()
				end
			end
		end, { description = "move to workspace " .. i, group = "tag" })
	)
end

-- Workspace 10
globalkeys = gears.table.join(
	globalkeys,
	awful.key({ modkey }, "#" .. 10 + 9, function()
		local screen = awful.screen.focused()
		local tag = screen.tags[10]
		if tag then
			tag:view_only()
		end
	end, { description = "workspace 10", group = "tag" }),
	awful.key({ modkey, "Shift" }, "#" .. 10 + 9, function()
		local c = client.focus
		if c then
			local tag = c.screen.tags[10]
			if tag then
				c:move_to_tag(tag)
				tag:view_only()
			end
		end
	end, { description = "move to workspace 10", group = "tag" })
)

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.

	{
		rule = { class = "firefox" },
		properties = { floating = false, maximized = false, fullscreen = false, placement = nil },
	},
	{
		rule = { class = "Firefox" },
		properties = { floating = false, maximized = false, fullscreen = false, placement = nil },
	},
	{
		rule = { class = "bitwarden" },
		properties = { floating = false, maximized = false, fullscreen = false, placement = nil },
	},
	{
		rule = { class = "Bitwarden" },
		properties = { floating = false, maximized = false, fullscreen = false, placement = nil },
	},
	{
		rule = { class = "discord" },
		properties = { floating = false, maximized = false, fullscreen = false, placement = nil },
	},
	{
		rule = { class = "Discord" },
		properties = { floating = false, maximized = false, fullscreen = false, placement = nil },
	},

	{

		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	-- New windows stack
	if not awesome.startup then
		awful.client.setslave(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}
