-- Hyprland configuration.
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS -----
------------------

hl.monitor({
  output = "DP-1",
  mode = "3440x1440@99.98",
  position = "auto",
  scale = "auto",
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@74.97",
  position = "auto",
  scale = "auto",
  transform = 1,
})

for workspace = 1, 10 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = workspace % 2 == 1 and "DP-1" or "HDMI-A-1",
  })
end

---------------------
---- MY PROGRAMS -----
---------------------

local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "walker"
local browser = "google-chrome-stable --disable-features=WaylandWpColorManagerV1"
local music = "spotify"
local osdclient = [[swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"]]

-------------------
---- AUTOSTART -----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("mako")
  hl.exec_cmd("fcitx5")
  hl.exec_cmd("swayosd-server")
  hl.exec_cmd("elephant")
  hl.exec_cmd("walker --gapplication-service &")

  -- Requires asbplayer-server to be installed in /usr/local/bin.
  hl.exec_cmd("asbplayer-server")
  hl.exec_cmd("f1_layout_script.sh daemon")
end)

-------------------------------
---- ENVIRONMENT VARIABLES -----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/screenshots/")

-----------------------
---- PERMISSIONS -------
-----------------------

-- Permission changes require a Hyprland restart and are not applied on reload.
--
-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })
--
-- hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

-----------------------
---- LOOK AND FEEL -----
-----------------------

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 0,
    border_size = 1,
    col = {
      active_border = {
        colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
        angle = 45,
      },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 5,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
  },
})

--------------------
---- ANIMATIONS -----
--------------------

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

---------------
---- INPUT -----
---------------

hl.config({
  input = {
    kb_layout = "pl",
    kb_variant = "",
    kb_model = "",
    kb_options = "grp:alt_shift_toggle",
    kb_rules = "",
    repeat_rate = 40,
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
    },
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS -----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd([[notify-send "Active Window" "$(hyprctl activewindow -j | jq -r .title)"]]))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next({}))
hl.bind(mainMod .. " + bracketleft", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(music))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("anki"))

hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd("fcitx5-remote -s keyboard-pl"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd("fcitx5-remote -s keyboard-es_based"))
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd("fcitx5-remote -s hangul"))
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("fcitx5-remote -s pinyin"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))

for _, direction in ipairs({ "l", "r", "u", "d" }) do
  local key = ({ l = "left", r = "right", u = "up", d = "down" })[direction]
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = direction }))
end

hl.bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

-- This keyboard reports different multimedia key names than evtest.
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(osdclient .. " --playerctl previous"), {
  locked = true,
  description = "Previous track",
})
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(osdclient .. " --playerctl next"), {
  locked = true,
  description = "Next track",
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(osdclient .. " --playerctl play-pause"), {
  locked = true,
  description = "Pause",
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(osdclient .. " --output-volume mute-toggle"), {
  locked = true,
  repeating = true,
  description = "Mute",
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osdclient .. " --output-volume lower"), {
  locked = true,
  repeating = true,
  description = "Volume down",
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osdclient .. " --output-volume raise"), {
  locked = true,
  repeating = true,
  description = "Volume up",
})
hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd(osdclient .. " --output-volume -1"), {
  locked = true,
  repeating = true,
  description = "Volume down precise",
})
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd(osdclient .. " --output-volume +1"), {
  locked = true,
  repeating = true,
  description = "Volume up precise",
})

-- Switch workspaces and move the active window with SUPER + [0-9].
for workspace = 1, 10 do
  local key = workspace % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------
---- WINDOWS AND WORKSPACES -----
--------------------------------

hl.window_rule({
  name = "windowrule-1",
  match = { class = "Screensaver" },
  fullscreen = true,
})

hl.window_rule({
  name = "windowrule-2",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "windowrule-3",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})
