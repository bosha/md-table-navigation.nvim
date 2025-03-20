# Markdown Table Navigation Plugin

**Translations**: [Русский (Russian)](README.ru.md)

The **Markdown Table Navigation (mdtn)** plugin is a Neovim plugin that allows you to navigate through Markdown tables by columns using simple keyboard shortcuts. By default, it uses `<Tab>` and `<S-Tab>` to move forward and backward between columns, respectively. The plugin also supports optional features like selecting cells (with or without leading/trailing spaces) during navigation.

## Features

- **Column Navigation**: Move between columns in a Markdown table using `<Tab>` and `<S-Tab>`.
- **Selection Options**: Optionally select cells, including or excluding leading/trailing spaces.
- **Customizable Keybindings**: Configure your own keybindings for navigation.
- **Buffer and Global Toggles**: Enable or disable the plugin globally or for specific buffers.
- **Commands**: Provides commands for manual navigation and toggling plugin behavior.

## Installation

Use your preferred Neovim plugin manager to install the plugin. For example, with [folke/lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
	"bosha/md-table-navigation.nvim",
	config = function()
		require("mdtn").setup()
	end,
},
```

## Configuration

The plugin can be configured by passing a table to the `setup` function. Below are the default options:

```lua
require("mdtn").setup({
  enabled = true, -- Enable the plugin by default
  select_on_navigate = false, -- Select cells when navigating
  select_whole_column = false, -- Select the entire cell (including leading/trailing spaces) when navigating
  filetypes = { "markdown" }, -- Filetypes to enable the plugin for
  keybindings = {
    n_move_forward = "<Tab>", -- Normal mode keybinding to move forward
    n_move_backward = "<S-Tab>", -- Normal mode keybinding to move backward
    i_move_forward = "<Tab>", -- Insert mode keybinding to move forward
    i_move_backward = "<S-Tab>", -- Insert mode keybinding to move backward
  },
})
```

## Usage

### Keybindings

By default, the plugin uses the following keybindings:

- **Normal Mode**:
  - `<Tab>`: Move to the next column.
  - `<S-Tab>`: Move to the previous column.
- **Insert Mode**:
  - `<Tab>`: Move to the next column.
  - `<S-Tab>`: Move to the previous column.

### Commands

The plugin provides the following commands for manual navigation and configuration:

#### Navigation Commands

- **`MDTableNavMoveForward [select=<bool>] [whole_col=<bool>]`**:

  - Move to the next column.
  - Optional arguments:
    - `select=true|false`: Whether to select the cell during navigation.
    - `whole_col=true|false`: Whether to include leading/trailing spaces in the selection.

- **`MDTableNavMoveBackward [select=<bool>] [whole_col=<bool>]`**:
  - Move to the previous column.
  - Optional arguments: same as for **MDTableNavMoveFoward**.

#### Toggle Commands

- **`MDTableNavEnable`**: Enable the plugin globally.
- **`MDTableNavDisable`**: Disable the plugin globally.
- **`MDTableNavToggle`**: Toggle the plugin globally.
- **`MDTableNavBufEnable`**: Enable the plugin for the current buffer.
- **`MDTableNavBufDisable`**: Disable the plugin for the current buffer.
- **`MDTableNavBufToggle`**: Toggle the plugin for the current buffer.

## Examples

### Basic Navigation

1. Open a Markdown file with a table.
2. Use `<Tab>` to move to the next column and `<S-Tab>` to move to the previous column.

### Selecting Cells

To select cells while navigating, enable `select_on_navigate` in the configuration:

```lua
require("mdtn").setup({
  select_on_navigate = true,
})
```

Now, when you navigate using `<Tab>` or `<S-Tab>`, the cell will be selected.

### Including Leading/Trailing Spaces in Selection

To include leading and trailing spaces in the selection, enable `select_whole_column` in the configuration:

```lua
require("mdtn").setup({
  select_on_navigate = true,
  select_whole_column = true,
})
```

Now, when you navigate, the entire cell (including leading/trailing spaces) will be selected. If `select_whole_column` is `false`, only the text content (excluding leading/trailing spaces) will be selected.

### Using Commands

You can manually navigate and toggle the plugin using commands:

```vim
:MDTableNavMoveForward select=true whole_col=true
:MDTableNavMoveBackward select=false
:MDTableNavToggle
```

Use these commands if you want to setup more complex keybinds for your own scenarios.

## Custom Keybindings

To customize the keybindings, pass your preferred keys to the `setup` function:

```lua
require("mdtn").setup({
  keybindings = {
    n_move_forward = "<C-l>", -- Use Ctrl+l to move forward in normal mode
    n_move_backward = "<C-h>", -- Use Ctrl+h to move backward in normal mode
    i_move_forward = "<C-l>", -- Use Ctrl+l to move forward in insert mode
    i_move_backward = "<C-h>", -- Use Ctrl+h to move backward in insert mode
  },
})
```

## Troubleshooting

- **Plugin not working**: Ensure the plugin is enabled globally and for the current buffer. Use `:MDTableNavEnable` or `:MDTableNavBufEnable` to enable it.
- **Keybindings conflict**: If the default keybindings conflict with other plugins, customize them using the `keybindings` option.

## License

This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
