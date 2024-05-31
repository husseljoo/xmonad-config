--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
import XMonad
import XMonad.Layout.Fullscreen
    ( fullscreenEventHook, fullscreenManageHook, fullscreenSupport, fullscreenFull )
import Data.Monoid ()
import System.Exit ()
import XMonad.Util.SpawnOnce ( spawnOnce )
import XMonad.Actions.SpawnOn
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume, xF86XK_AudioMute, xF86XK_MonBrightnessDown, xF86XK_MonBrightnessUp, xF86XK_AudioPlay, xF86XK_AudioPrev, xF86XK_AudioNext)
import XMonad.Hooks.EwmhDesktops ( ewmh, ewmhFullscreen )
import Control.Monad ( join, when )
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks
    (ToggleStruts (..), avoidStruts, docks, manageDocks, Direction2D(D, L, R, U) )
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Spacing ( spacingRaw, Border(Border) )
import XMonad.Layout.Gaps
    ( Direction2D(D, L, R, U),
      gaps,
      setGaps,
      GapMessage(DecGap, ToggleGaps, IncGap) )

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Maybe (maybeToList)
import XMonad.Layout.MultiToggle (EOT (EOT), mkToggle, single, (??))
import qualified XMonad.Layout.MultiToggle as MT (Toggle (..))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts
import qualified XMonad.Layout.ToggleLayouts as T (ToggleLayout (Toggle), toggleLayouts)
import XMonad.Layout.WindowArranger (WindowArrangerMsg (..), windowArrange)
import XMonad.Layout.Renamed
import XMonad.Layout.WindowNavigation
import XMonad.Actions.MouseResize
import XMonad.Layout.LimitWindows (decreaseLimit, increaseLimit, limitWindows)
import XMonad.Layout.SubLayouts
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Spacing
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Hooks.SetWMName
import XMonad.Util.NamedScratchpad
import XMonad.ManageHook

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.Loggers
import XMonad.Util.ClickableWorkspaces
import XMonad.Layout.PerWorkspace

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

myBrowser :: String
myBrowser = "firefox-developer-edition"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- window key as ModMask
myModMask       = mod4Mask

-- names and number of workspaces is determined by the length of the list
-- myWorkspaces = ["dev", "web", "\63083"] ++ map show [4..9]
-- myWorkspaces = map show [1..9] ++ ["NSP"]
myWorkspaces :: [String]
myWorkspaces = map show [1..8] ++ ["notes"]

-- Border colors for unfocused and focused windows (alternatives #282c34,#46d9ff)
myNormalBorderColor  = "#3b4252"
myFocusedBorderColor = "#bc96da"

addNETSupported :: Atom -> X ()
addNETSupported x   = withDisplay $ \dpy -> do
    r               <- asks theRoot
    a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
    a               <- getAtom "ATOM"
    liftIO $ do
       sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
       when (fromIntegral x `notElem` sup) $
         changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
    wms <- getAtom "_NET_WM_STATE"
    wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
    mapM_ addNETSupported [wms, wfs]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
clipboardy :: MonadIO m => m () -- Don't question it 
clipboardy = spawn "rofi -modi \"\63053 :greenclip print\" -show \"\63053 \" -run-command '{cmd}' -theme ~/.config/rofi/launcher/style.rasi -m -1"


-- centerlaunch = spawn "exec ~/bin/eww open-many blur_full weather profile quote search_full disturb-icon vpn-icon home_dir screenshot power_full reboot_full lock_full logout_full suspend_full"
-- sidebarlaunch = spawn "exec ~/bin/eww open-many weather_side time_side smol_calendar player_side sys_side sliders_side"
-- ewwclose = spawn "exec ~/bin/eww close-all"
maimcopy = spawn "maim -s | xclip -selection clipboard -t image/png && notify-send 'Screenshot' 'Copied to Clipboard' -i flameshot"
maimsave = spawn "maim -s ~/Pictures/screen_shots/$(date +%Y-%m-%d_%H-%M-%S).png && notify-send 'Screenshot' 'Saved to screen_shots' -i flameshot"
rofi_launcher = spawn "rofi -no-lazy-grab -show drun -modi run,drun,window -theme $HOME/.config/rofi/launcher/style -drun-icon-theme \"candy-icons\" -m -1"
-- testbar = spawn "exec ~/.config/eww/launch_bar"


myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    , ((modm,               xK_space    ), sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)
    , ((modm,               xK_BackSpace ), sendMessage NextLayout)
    , ((modm,               xK_b    ), spawn (myBrowser))

    -- lock screen
    , ((modm,               xK_F1    ), spawn "betterlockscreen -l")

    --toggle terminal opacity
    , ((modm,               xK_F2    ), spawn "~/scripts/toggle_alacritty_opacity")

    -- scratchpads
    , ((modm,               xK_o     ), namedScratchpadAction myScratchPads "terminal")

    -- launch rofi and dashboard
    , ((modm,               xK_p     ), rofi_launcher)
    -- , ((modm,               xK_p     ), centerlaunch)
    -- , ((modm .|. shiftMask, xK_p     ), ewwclose)

    -- launch eww sidebar
    -- , ((modm,               xK_s     ), sidebarlaunch)
    -- , ((modm .|. shiftMask, xK_s     ), ewwclose)
    -- , ((modm,               xK_a     ), testbar)

    -- Audio keys
    , ((0,                    xF86XK_AudioPlay), spawn "playerctl play-pause")
    , ((0,                    xF86XK_AudioPrev), spawn "playerctl previous")
    , ((0,                    xF86XK_AudioNext), spawn "playerctl next")

    , ((0,                    xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +5%")
    , ((0,                    xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -5%")
    , ((0,                    xF86XK_AudioMute), spawn "pactl set-sink-mute 0 toggle")
    , ((modm,                    xK_KP_Add), spawn "pactl set-sink-volume 0 +5%")
    , ((modm,                    xK_KP_Subtract), spawn "pactl set-sink-volume 0 -5%")
    , ((modm,                    xK_KP_Multiply), spawn "pactl set-sink-mute 0 toggle")

    -- Brightness keys
    , ((0,                    xF86XK_MonBrightnessUp), spawn "brightnessctl s +10%")
    , ((0,                    xF86XK_MonBrightnessDown), spawn "brightnessctl s 10-%")
 
    -- Screenshot
    , ((0,                    xK_Print), maimcopy)
    , ((modm,                 xK_Print), maimsave)
    , ((modm,                 xK_Page_Up), maimcopy)
    , ((modm,                 xK_Page_Down), maimsave)

    -- My Stuff
    -- , ((modm,               xK_F3     ), spawn "exec ~/bin/bartoggle")
    , ((modm,               xK_F3     ), spawn "exec ~/scripts/toggle_xmobar")
    , ((modm,               xK_z     ), spawn "exec ~/scripts/inhibit_activate")
    , ((modm .|. shiftMask, xK_z     ), spawn "exec ~/scripts/inhibit_deactivate")
    , ((modm .|. shiftMask, xK_a     ), clipboardy)
    -- Turn do not disturb on and off
    -- , ((modm,               xK_d     ), spawn "exec ~/bin/do_not_disturb.sh")
    , ((modm,               xK_d     ), spawn "find ~/wallpapers -type f | shuf -n 1 | xargs feh --bg-scale")


    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

    -- GAPS!!!
    -- , ((modm .|. controlMask, xK_g), sendMessage $ ToggleGaps)               -- toggle all gaps
    -- , ((modm .|. shiftMask, xK_g), sendMessage $ setGaps [(L,30), (R,30), (U,40), (D,60)]) -- reset the GapSpec
    
    -- , ((modm .|. controlMask, xK_t), sendMessage $ IncGap 10 L)              -- increment the left-hand gap
    -- , ((modm .|. shiftMask, xK_t     ), sendMessage $ DecGap 10 L)           -- decrement the left-hand gap
    
    -- , ((modm .|. controlMask, xK_y), sendMessage $ IncGap 10 U)              -- increment the top gap
    -- , ((modm .|. shiftMask, xK_y     ), sendMessage $ DecGap 10 U)           -- decrement the top gap
    
    -- , ((modm .|. controlMask, xK_u), sendMessage $ IncGap 10 D)              -- increment the bottom gap
    -- , ((modm .|. shiftMask, xK_u     ), sendMessage $ DecGap 10 D)           -- decrement the bottom gap

    -- , ((modm .|. controlMask, xK_i), sendMessage $ IncGap 10 R)              -- increment the right-hand gap
    -- , ((modm .|. shiftMask, xK_i     ), sendMessage $ DecGap 10 R)           -- decrement the right-hand gap

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), windows $ W.greedyView "notes")

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), spawn "~/scripts/powermenu.sh")

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- mouse scroll wheel, increase/decrease window size
    , ((modm, button4), (\w -> focus w >> sendMessage Shrink))
    , ((modm, button5), (\w -> focus w >> sendMessage Expand))

    ]

------------------------------------------------------------------------
-- Layouts:

--useful to set using keybind: Tall 1 (10/100) (2/3), tabbed shrinkText def

-- Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

mySpacingCustom :: Integer -> Integer -> Integer -> Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacingCustom t b l r layout = spacingRaw False (Border t b l r) True (Border t b l r) True layout

floats = renamed [Replace "floats"] $ smartBorders $ limitWindows 20 simplestFloat

tall = renamed [Replace "tall"] $ smartBorders $ windowNavigation $ subLayout [] (smartBorders Simplest) $ limitWindows 12 $ mySpacing 8 $
       ResizableTall 1 (3 / 100) (1 / 2) []

-- each layout is separated by |||
myLayout = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ onWorkspace "notes" zenLayout $ myDefaultLayout
  where
    myDefaultLayout =
        withBorder myBorderWidth tall
            ||| noBorders tiled
    zenLayout = noBorders tiled

    tiled = Tall nmaster delta ratio -- default tiling algorithm partitions the screen into two panes
    nmaster = 1     -- default number of windows in the master pane
    ratio = 1 / 2   -- default proportion of screen occupied by master pane
    delta = 3 / 100 -- % of screen to increment by when resizing panes


------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = fullscreenManageHook <+> manageDocks <+> composeAll
    [ className =? "Pavucontrol"    --> smallRect
    , className =? "Blueberry.py"   --> smallRect
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen --> doFullFloat
                                 ]

-- Floating window sizes
largeRect = (customFloating $ W.RationalRect (1/20) (1/20) (9/10) (9/10))
smallRect = (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))

------------------------------------------------------------------------
-- Scratchpads:
--
-- Allows to have several floating scratchpads running different applications.

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm largeRect
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty


------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"
  -- spawnOnce "exec ~/bin/bartoggle"
  spawnOnce "exec ~/bin/eww daemon"
  spawn "xsetroot -cursor_name left_ptr"
  spawn "exec ~/bin/lock.sh"
  spawnOnce "find ~/wallpapers -type f | shuf -n 1 | xargs feh --bg-scale"
  spawnOnce "picom --experimental-backends"
  spawnOnce "greenclip daemon"
  spawnOnce "dunst"
  -- spawnOn "notes" "obsidian & alacritty -e nvim $HOME/obsidian/husseljVault/Welcome.md"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
-- main = xmonad $ fullscreenSupport $ docks $ ewmh defaults
-- main = xmonad $ docks $ ewmhFullscreen $ ewmh $ xmobarProp $ defaults
main = xmonad
     . docks
     . ewmhFullscreen
     . ewmh
     . withEasySB (statusBarProp "xmobar ~/.xmonad/xmobar.config" (clickablePP myXmobarPP)) toggleStrutsKey
     $ defaults
   where
     toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
     toggleStrutsKey XConfig{ modMask = m } = (m, xK_F8)

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#8be9fd" 2
    , ppVisible         = wrap " " "" . wisteria
    , ppHidden          = wrap " " "" . jordyBlue
    , ppHiddenNoWindows = wrap " " "" . lowWhite
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, _, _, wins] -> [ws, wins]
    , ppExtras          = [logTitle]
    }
  where
    -- Windows should have *some* title, which should not not exceed a sane length
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 15

    blue, lowWhite, magenta, red, white, yellow :: String -> String
    magenta  = xmobarColor "#ff79c6" ""
    blue     = xmobarColor "#bd93f9" ""
    white    = xmobarColor "#f8f8f2" ""
    yellow   = xmobarColor "#f1fa8c" ""
    red      = xmobarColor "#ff5555" ""
    lowWhite = xmobarColor "#bbbbbb" ""
    jordyBlue= xmobarColor "#82AAFF" ""
    wisteria = xmobarColor "#C792EA" ""
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        manageHook = myManageHook <+> manageSpawn <+> namedScratchpadManageHook myScratchPads,
        layoutHook = myLayout,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook >> addEWMHFullscreen
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'super'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
