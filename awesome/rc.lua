-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Widgets
local vicious = require("vicious")
local net_widgets = require("widgets/net_widgets")
require("volume")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/klacointe/.config/awesome/themes/default/theme.lua")
beautiful.blingbling = {
	font = "Droid Sans Mono for Powerline",
	font_size = 12,
	text_color = "#aaaaaa"
}
local blingbling = require("blingbling")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[2])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Memory usage graph
memgraph = awful.widget.graph()
memgraph:set_width(50)
memgraph:set_background_color("#494B4F")
memgraph:set_border_color(nil)
memgraph:set_color(
	{ type = "linear", from = { 1, 0 }, to = { 0, 10 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96"}}}
)
vicious.register(memgraph, vicious.widgets.mem, "$1")
local memwidget = wibox.layout.margin(memgraph,1,1,0,0)

mem_graph = blingbling.line_graph({
	height = 20,
	width = 100,
	show_text = true,
	label = "$percent %",
})
vicious.register(mem_graph, vicious.widgets.mem,'$1',2)
-- }}}

-- {{{ CPU usage graph
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color(
	{ type = "linear", from = { 0, 0 }, to = { 10, 0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96" }}}
)
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
local cpuwidget = wibox.layout.margin(cpuwidget,1,1,0,0)

cores_graph_conf = {height = 20, width = 8, rounded_size = 0}
cores_graphs = {}
cores_text = {}
for i=1,4 do
	cores_graphs[i] = blingbling.progress_graph(cores_graph_conf)
	vicious.register(cores_graphs[i], vicious.widgets.cpu, "$"..(i+1).."",1)

	cores_text[i] = blingbling.value_text_box({height = 20, width = 10, v_margin = 4})
	vicious.register(cores_text[i], vicious.widgets.cpu, "$"..(i+1).."",1)
end

cpu_graph = blingbling.line_graph({
	height = 20,
	width = 100,
	show_text = true,
	label = "$percent %",
})
vicious.register(cpu_graph, vicious.widgets.cpu, '$1' ,2)
-- }}}

-- {{{ Thermal widget
temp = wibox.widget.textbox()
vicious.register(temp, vicious.widgets.thermal, "$1°",37,"thermal_zone0")
local tempwidget = wibox.layout.margin(temp,1,1,0,0)
-- }}}

-- {{{ HDD Thermal widget
--hddtemp = wibox.widget.textbox()
--vicious.register(hddtemp, vicious.widgets.hddtemp, "$1°",37,"thermal_zone0")
--local hddtempwidget = wibox.layout.margin(hddtemp,1,1,0,0)
-- }}}

-- {{{ Eth
net_wired = net_widgets.indicator({
	interfaces  = {"eth0"},
	timeout     = 5
})

ethdown = wibox.widget.textbox()
vicious.register(ethdown, vicious.widgets.net, "▼${eth0 down_kb}", 1)
local ethdownwidget = wibox.layout.margin(ethdown,1,1,0,0)

ethup = wibox.widget.textbox()
vicious.register(ethup, vicious.widgets.net, "▲${eth0 up_kb}", 1)
local ethupwidget = wibox.layout.margin(ethup,1,10,0,0)

-- }}}

-- {{{ wlan
wlandown = wibox.widget.textbox()
vicious.register(wlandown, vicious.widgets.net, "▼${wlan0 down_kb}", 1)
local wlandownwidget = wibox.layout.margin(wlandown,1,1,0,0)

wlanup = wibox.widget.textbox()
vicious.register(wlanup, vicious.widgets.net, "▲${wlan0 up_kb}", 1)
local wlanupwidget = wibox.layout.margin(wlanup,1,10,0,0)

net_wireless = net_widgets.wireless({interface="wlan0"})
-- }}}

-- {{{ Date widget
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, " %d%b %R", 60)
-- }}}

-- {{{ Battery
bat_graph_0 = blingbling.progress_graph.new({height = 20, width = 10})
vicious.register(bat_graph_0, vicious.widgets.bat, "$2", 61, "BAT0")

bat_graph_1 = blingbling.progress_graph.new({height = 20, width = 10})
vicious.register(bat_graph_1, vicious.widgets.bat, "$2", 61, "BAT1")

batpercent_0 = wibox.widget.textbox()
vicious.register(batpercent_0, vicious.widgets.bat, "BAT0 $2%", 61, "BAT0")
local batpercentwidget_0 = wibox.layout.margin(batpercent_0,1,1,0,0)

batpercent_1 = wibox.widget.textbox()
vicious.register(batpercent_1, vicious.widgets.bat, "BAT1 $2%", 61, "BAT1")
local batpercentwidget_1 = wibox.layout.margin(batpercent_1,1,1,0,0)
-- }}}
--
-- {{{ Volume
--volumewidget = blingbling.volume.new()
--volumewidget:set_height(18)
--volumewidget:set_width(30)
--volumewidget:update_master()
--volumewidget:set_master_control()
--volumewidget:set_bar(true)
--volumewidget = blingbling.volume({height = 18, width = 40, bar =true, show_text = true, label =""})
--volumewidget:update_master()
--volumewidget:set_master_control()
-- }}}
--
-- {{{ Volume pulseausio
volume_widget = create_volume_widget()
-- }}}

-- {{{ Wibox
-- Create a textclock widget
--mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
	if (screen.count() == 2) and (s == 2) then right_layout:add(wibox.widget.systray()) end
	if (screen.count() == 1) and (s == 1) then right_layout:add(wibox.widget.systray()) end
    right_layout:add(net_wired)
    --right_layout:add(ethdownwidget)
    --right_layout:add(ethupwidget)
    right_layout:add(net_wireless)
    --right_layout:add(wlandownwidget)
    --right_layout:add(wlanupwidget)
	--for i=1,4 do
		--right_layout:add(cores_graphs[i])
	--end
	--for i=1,4 do
		--right_layout:add(cores_text[i])
	--end
    right_layout:add(cpu_graph)
    right_layout:add(mem_graph)
	--right_layout:add(cpuwidget)
	--right_layout:add(memwidget)
    right_layout:add(tempwidget)
    --right_layout:add(hddtempwidget)
	right_layout:add(batpercentwidget_0)
	right_layout:add(bat_graph_0)
	right_layout:add(batpercentwidget_1)
	right_layout:add(bat_graph_1)
	--right_layout:add(volumewidget)
	right_layout:add(volume_widget)
	right_layout:add(datewidget)
	--right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Screens

-- Get active outputs
local function outputs()
	local outputs = {}
	local xrandr = io.popen("xrandr -q")
	if xrandr then
		for line in xrandr:lines() do
			output = line:match("^([%w-]+) connected ")
			if output then
				outputs[#outputs + 1] = output
			end
		end
		xrandr:close()
	end

	return outputs
end

local function arrange(out)
	-- We need to enumerate all the way to combinate output. We assume
	-- we want only an horizontal layout.
	local choices  = {}
	local previous = { {} }
	for i = 1, #out do
		-- Find all permutation of length `i`: we take the permutation
		-- of length `i-1` and for each of them, we create new
		-- permutations by adding each output at the end of it if it is
		-- not already present.
		local new = {}
		for _, p in pairs(previous) do
			for _, o in pairs(out) do
				if not awful.util.table.hasitem(p, o) then
					new[#new + 1] = awful.util.table.join(p, {o})
				end
			end
		end
		choices = awful.util.table.join(choices, new)
		previous = new
	end

	return choices
end

-- Build available choices
local function menu()
	local menu = {}
	local out = outputs()
	local choices = arrange(out)

	for _, choice in pairs(choices) do
		local cmd = "xrandr"
		-- Enabled outputs
		for i, o in pairs(choice) do
			cmd = cmd .. " --output " .. o .. " --auto"
			if i > 1 then
				cmd = cmd .. " --right-of " .. choice[i-1]
			end
		end
		-- Disabled outputs
		for _, o in pairs(out) do
			if not awful.util.table.hasitem(choice, o) then
				cmd = cmd .. " --output " .. o .. " --off"
			end
		end

		local label = ""
		if #choice == 1 then
			label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
		else
			for i, o in pairs(choice) do
				if i > 1 then label = label .. " + " end
				label = label .. '<span weight="bold">' .. o .. '</span>'
			end
		end

		menu[#menu + 1] = { label, cmd, "/usr/share/icons/Tango/32x32/devices/display.png"}
	end

	return menu
end

-- Display xrandr notifications from choices
local state = { iterator = nil,
timer = nil,
cid = nil }
local function xrandr()
	-- Stop any previous timer
	if state.timer then
		state.timer:stop()
		state.timer = nil
	end

	-- Build the list of choices
	if not state.iterator then
		state.iterator = awful.util.table.iterate(menu(),	function() return true end)
	end

	-- Select one and display the appropriate notification
	local next  = state.iterator()
	local label, action, icon
	if not next then
		label, icon = "Keep the current configuration", "/usr/share/icons/Tango/32x32/devices/display.png"
		state.iterator = nil
	else
		label, action, icon = unpack(next)
	end
	state.cid = naughty.notify({ text = label,
	icon = icon,
	timeout = 4,
	screen = mouse.screen, -- Important, not all screens may be visible
	font = "Free Sans 18",
	replaces_id = state.cid }).id

	-- Setup the timer
	state.timer = timer { timeout = 4 }
	state.timer:connect_signal("timeout",
	function()
		state.timer:stop()
		state.timer = nil
		state.iterator = nil
		if action then
			awful.util.spawn(action, false)
		end
	end)
	state.timer:start()
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
	-- Volume
	--awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q sset Master 10%-") end),
	--awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q sset Master 10%+") end),
	--awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer -q -D default sset Master toggle") end),
	awful.key({ }, "XF86AudioRaiseVolume", function () inc_volume(volume_widget) end),
	awful.key({ }, "XF86AudioLowerVolume", function () dec_volume(volume_widget) end),
	awful.key({ }, "XF86AudioMute", function() mute_volume(volume_widget) end),
	-- Screens
	awful.key({}, "XF86Display", xrandr)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    elseif not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count change
        awful.placement.no_offscreen(c)
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

function run_once(prg,arg_string,pname,screen)
	if not prg then
		do return nil end
	end

	if not pname then
		pname = prg
	end

	if not arg_string then
		awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
	else
		awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
	end
end

-- {{{ Autostart
awful.util.spawn_with_shell("source ~/.Xsession")
awful.util.spawn_with_shell("eval `gnome-keyring-daemon`")
run_once("gnome-settings-daemon")
run_once("clipit")
run_once("nm-applet")
run_once("blueman-applet")
run_once("xflux -l 47.2494910 -q -1.4873310")
--xflux -l 47.2494910 -q -1.4873310 &
-- }}}
