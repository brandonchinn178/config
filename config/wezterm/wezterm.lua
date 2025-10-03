local wezterm = require 'wezterm'

--------------- Constants ---------------

local WHITE = '#cecece'
local GRAY = '#303030'
local TEAL = '#4ac9e2'
local LIGHT_BLUE = '#a3bfd1'
local YELLOW = '#eef0b6'
local BLACK = '#000'
local RED = '#ff0000'

-- https://wezfurlong.org/wezterm/config/lua/config/custom_block_glyphs.html
local POWERLINE_FSLASH_UPPER = utf8.char(0xe0bc)
local POWERLINE_FSLASH_LOWER = utf8.char(0xe0ba)
local POWERLINE_LEFT_ARROW = utf8.char(0xe0b2)

--------------- Utilities ---------------

function ifthen(cond, t, f)
  if cond then
    return t
  else
    return f
  end
end

--------------- Configuration ---------------

function ActivatePaneRelative(dir)
  return wezterm.action_callback(function(window, pane)
    local active_pane
    local panes = pane:tab():panes_with_info()
    for _, pane in ipairs(panes) do
      if pane.is_active then
        active_pane = pane
        break
      end
    end
    assert(active_pane, 'Could not find active pane')

    local new_index = (active_pane.index + dir) % #panes
    window:perform_action(
      wezterm.action.ActivatePaneByIndex(new_index),
      pane
    )
  end)
end

wezterm.on('update-right-status', function(window, pane)
  function set_right_status(s)
    window:set_right_status(wezterm.format {
      { Background = { Color = GRAY } },
      { Foreground = { Color = YELLOW } },
      { Text = POWERLINE_LEFT_ARROW },
      { Attribute = { Intensity = 'Bold' } },
      { Background = { Color = YELLOW } },
      { Foreground = { Color = BLACK } },
      { Text = ' ' .. s .. '  ' },
    })
  end

  local name = window:active_key_table()

  if window:leader_is_active() then
    set_right_status('LEADER')
  elseif name then
    set_right_status(name:upper())
  else
    window:set_right_status('')
  end
end)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  return ''
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local background = GRAY
  local foreground = WHITE
  local intensity = 'Normal'

  local is_first_tab = tab.tab_index == 0
  local tab_start = ifthen(is_first_tab, '', POWERLINE_FSLASH_LOWER)
  local tab_end = POWERLINE_FSLASH_UPPER
  local title_suffix = ''
  local title_padding_start = ifthen(is_first_tab, ' ', '')
  local title_padding_end = ''
  wezterm.log_info(tab.active_pane.is_zoomed)

  if tab.is_active then
    background = TEAL
    foreground = BLACK
    intensity = 'Bold'
    if tab.active_pane.is_zoomed then
      title_suffix = '[Z]'
    end
    title_padding_start = ' '
    title_padding_end = ' '
  end

  local title = tab.active_pane.title

  local title_max_width = (
          max_width
          - wezterm.column_width(tab_start)
          - wezterm.column_width(tab_end)
          - wezterm.column_width(title_suffix)
          - wezterm.column_width(title_padding_start)
          - wezterm.column_width(title_padding_end)
        )
  if wezterm.column_width(title) > title_max_width then
    title = wezterm.truncate_right(title, title_max_width - 3) .. '...'
  end

  return {
    -- begin
    { Background = { Color = GRAY } },
    { Foreground = { Color = background } },
    { Text = tab_start },
    -- content
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Attribute = { Intensity = intensity } },
    { Text = title_padding_start .. title .. title_suffix .. title_padding_end },
    -- end
    { Background = { Color = GRAY } },
    { Foreground = { Color = background } },
    { Text = tab_end },
  }
end)

return {
  font_size = 14, -- set this to keep $COLUMNS >= 80 when half-screen
  audible_bell = 'Disabled',
  enable_scroll_bar = true,

  color_scheme = 'Afterglow',
  colors = {
    selection_bg = LIGHT_BLUE,
    selection_fg = BLACK,
    scrollbar_thumb = WHITE,
    split = RED,
  },
  inactive_pane_hsb = {
    saturation = 0.5,
    brightness = 0.5,
  },

  tab_max_width = 24,
  tab_bar_at_bottom = true,
  show_tab_index_in_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  use_fancy_tab_bar = false,

  leader = { key = ';', mods = 'CMD' },
  keys = {
    -- Configuration
    {
      mods = 'CMD|SHIFT',
      key = 'r',
      action = wezterm.action.ReloadConfiguration,
    },

    -- Commands
    {
      mods = 'CMD|SHIFT',
      key = 'p',
      action = wezterm.action.ActivateCommandPalette,
    },

    -- Font
    {
      mods = 'CTRL',
      key = '=',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      mods = 'CTRL',
      key = '+',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      mods = 'CTRL',
      key = '-',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      mods = 'CTRL',
      key = '_',
      action = wezterm.action.DisableDefaultAssignment,
    },

    -- Windows
    {
      mods = 'CMD|SHIFT',
      key = 'n',
      action = wezterm.action.SpawnWindow,
    },
    {
      -- Unbind default ToggleFullScreen binding
      mods = 'ALT',
      key = 'Enter',
      action = wezterm.action.Nop,
    },

    -- Tabs
    {
      -- https://github.com/wez/wezterm/issues/3021
      mods = 'LEADER|CMD|CTRL|ALT|SHIFT',
      key = 'w',
      action = wezterm.action.CloseCurrentTab { confirm = true },
    },
    {
      mods = 'LEADER|CMD',
      key = 'w',
      action = wezterm.action.CloseCurrentTab { confirm = true },
    },
    {
      -- https://github.com/wez/wezterm/issues/3021
      mods = 'CMD',
      key = 'w',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      mods = 'CMD',
      key = 'e',
      action = wezterm.action.MoveTabRelative(1),
    },
    {
      mods = 'CMD|SHIFT',
      key = 'e',
      action = wezterm.action.MoveTabRelative(-1),
    },

    -- Panes
    {
      mods = 'CMD',
      key = 'n',
      action = wezterm.action_callback(function(window, pane)
        local panes = pane:tab():panes_with_info()

        if #panes == 1 then
          pane:split { direction = 'Bottom' }
        elseif panes[1].is_active then
          -- if the top pane is active, choose bottom-left pane and create 'Left'
          window:perform_action(wezterm.action.ActivatePaneByIndex(1), pane)
          panes[2]["pane"]:split { direction = 'Left' }
        else
          pane:split { direction = 'Right' }
        end
      end),
    },
    {
      -- https://github.com/wez/wezterm/issues/3021
      mods = 'LEADER|CMD|CTRL|ALT|SHIFT',
      key = 'd',
      action = wezterm.action.CloseCurrentPane { confirm = true },
    },
    {
      mods = 'LEADER|CMD',
      key = 'd',
      action = wezterm.action.CloseCurrentPane { confirm = true },
    },
    {
      mods = 'CMD',
      key = 'l',
      action = wezterm.action.TogglePaneZoomState,
    },
    {
      mods = 'CMD',
      key = 'j',
      action = ActivatePaneRelative(1),
    },
    {
      mods = 'CMD',
      key = 'k',
      action = ActivatePaneRelative(-1),
    },
    {
      mods = 'CMD',
      key = 'p',
      action = wezterm.action.PaneSelect,
    },
    {
      mods = 'CMD',
      key = 'm',
      -- TODO: keep same pane active
      -- https://github.com/wez/wezterm/issues/3014
      action = wezterm.action.PaneSelect { mode = 'SwapWithActive' },
    },

    -- Scrollback
    {
      mods = 'CMD|SHIFT',
      key = 'k',
      action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
    },
    {
      mods = 'CMD',
      key = 'UpArrow',
      action = wezterm.action.ScrollToPrompt(-1),
    },
    {
      mods = 'CMD',
      key = 'DownArrow',
      action = wezterm.action.ScrollToPrompt(1),
    },
    {
      mods = 'CMD|SHIFT',
      key = 'UpArrow',
      action = wezterm.action.ScrollToTop,
    },
    {
      mods = 'CMD|SHIFT',
      key = 'DownArrow',
      action = wezterm.action.ScrollToBottom,
    },
    -- https://github.com/wez/wezterm/issues/3038
    -- {
    --   mods = 'CMD',
    --   key = 'f',
    --   action = wezterm.action.Search{ CaseInSensitiveString = '' },
    -- },
    {
      mods = 'CMD|SHIFT',
      key = 'f',
      action = wezterm.action.Search('CurrentSelectionOrEmptyString'),
    },

    -- Modes
    {
      mods = 'CMD',
      key = 'r',
      action = wezterm.action.ActivateKeyTable {
        name = 'resize_pane',
        one_shot = false,
      },
    },
    {
      mods = 'CMD',
      key = 's',
      action = wezterm.action.ActivateKeyTable {
        name = 'split_pane',
      },
    },
  },

  key_tables = {
    resize_pane = {
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'h', action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
      { key = 'l', action = wezterm.action.AdjustPaneSize { 'Right', 1 } },
      { key = 'k', action = wezterm.action.AdjustPaneSize { 'Up', 1 } },
      { key = 'j', action = wezterm.action.AdjustPaneSize { 'Down', 1 } },
    },
    split_pane = {
      { key = 'Escape', action = 'PopKeyTable' },
      { mods = 'CMD',  key = 'h', action = wezterm.action.SplitPane { direction = 'Left' } },
      { mods = 'NONE', key = 'h', action = wezterm.action.SplitPane { direction = 'Left' } },
      { mods = 'CMD',  key = 'l', action = wezterm.action.SplitPane { direction = 'Right' } },
      { mods = 'NONE', key = 'l', action = wezterm.action.SplitPane { direction = 'Right' } },
      { mods = 'CMD',  key = 'k', action = wezterm.action.SplitPane { direction = 'Up' } },
      { mods = 'NONE', key = 'k', action = wezterm.action.SplitPane { direction = 'Up' } },
      { mods = 'CMD',  key = 'j', action = wezterm.action.SplitPane { direction = 'Down' } },
      { mods = 'NONE', key = 'j', action = wezterm.action.SplitPane { direction = 'Down' } },
    },
    search_mode = {
      { key = 'Enter', mods = 'NONE', action = wezterm.action.CopyMode 'NextMatch' },
      { key = 'Enter', mods = 'SHIFT', action = wezterm.action.CopyMode 'PriorMatch' },
      { key = 'Escape', mods = 'NONE', action = wezterm.action.CopyMode 'Close' },
      { key = 'r', mods = 'CTRL', action = wezterm.action.CopyMode 'CycleMatchType' },
      { key = 'Backspace', mods = 'CMD', action = wezterm.action.CopyMode 'ClearPattern' },
    },
  },

  mouse_bindings = {
    -- Override default left-click, which copies to clipbard + opens links
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action.Nop,
    },
    -- Open links with alt+click
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'ALT',
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  },
}
