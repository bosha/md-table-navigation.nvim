# Markdown Table Navigation Plugin

**Translations**: [Русский (Russian)](README.ru.md) 🇷🇺

The **Markdown Table Navigation (mdtn)** plugin is a Neovim plugin that allows you to navigate through Markdown tables by columns using simple keyboard shortcuts. By default, it uses `<Tab>` and `<S-Tab>` to move forward and backward between columns, respectively. The plugin also supports optional features like selecting cells (with or without leading/trailing spaces) during navigation, provides text objects for manipulating table cells, and allows jumping to the beginning or end of a cell.

## Features

- **Column Navigation**: Move between columns in a Markdown table using `<Tab>` and `<S-Tab>`.
- **Selection Options**: Optionally select cells, including or excluding leading/trailing spaces.
- **Text Objects**:
  - `ac`: Select a cell including leading/trailing spaces.
  - `ic`: Select only the text inside a cell (excluding leading/trailing spaces).
- **Cell Navigation**:
  - `[c`: Jump to the beginning of the current cell.
  - `]c`: Jump to the end of the current cell.
- **Customizable Keybindings**: Configure your own keybindings for navigation and text objects.
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
  inside_cell_pattern = "ic", -- Text object pattern for selecting inside a cell (excluding spaces)
  around_cell_pattern = "ac", -- Text object pattern for selecting around a cell (including spaces)
  keybindings = {
    n_move_forward = "<Tab>", -- Normal mode keybinding to move forward
    n_move_backward = "<S-Tab>", -- Normal mode keybinding to move backward
    i_move_forward = "<Tab>", -- Insert mode keybinding to move forward
    i_move_backward = "<S-Tab>", -- Insert mode keybinding to move backward
    n_jump_to_cell_start = "[c", -- Normal mode keybinding to jump to the beginning of the current cell
    n_jump_to_cell_end = "]c", -- Normal mode keybinding to jump to the end of the current cell
  },
})
```

## Usage

### Keybindings

By default, the plugin uses the following keybindings:

- **Normal Mode**:
  - `<Tab>`: Move to the next column.
  - `<S-Tab>`: Move to the previous column.
  - `[c`: Jump to the beginning of the current cell.
  - `]c`: Jump to the end of the current cell.
- **Insert Mode**:
  - `<Tab>`: Move to the next column.
  - `<S-Tab>`: Move to the previous column.

### Text Objects

The plugin provides the following text objects for manipulating table cells:

- **`ac`**: Select a cell including leading and trailing spaces.
  - Example: `dac` to delete a cell including spaces, `yac` to yank a cell including spaces.
- **`ic`**: Select only the text inside a cell (excluding leading/trailing spaces).
  - Example: `dic` to delete only the text inside a cell, `yic` to yank only the text inside a cell.

#### Supported Actions

The text objects work with the following actions:

- `d`: Delete
- `y`: Yank
- `c`: Change
- `gU`: Convert to uppercase
- `gu`: Convert to lowercase

Example:

- Convert a cell to uppercase: `gUac`
- Convert the text inside a cell to lowercase: `guic`

**Note**: Counts before the text object patterns (e.g., `2dac`) are **not supported**.

### Customizing Text Object Patterns

If the default text object patterns (`ac` and `ic`) conflict with other plugins, you can customize them in the configuration:

```lua
require("mdtn").setup({
  inside_cell_pattern = "ic", -- Change to your preferred pattern for selecting inside a cell
  around_cell_pattern = "ac", -- Change to your preferred pattern for selecting around a cell
})
```

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

### Jumping to Cell Boundaries

- Jump to the beginning of the current cell: `[c`
- Jump to the end of the current cell: `]c`

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

### Using Text Objects

Use the `ac` and `ic` text objects to manipulate table cells:

- **Delete a cell including spaces**:
  ```vim
  dac
  ```
- **Yank only the text inside a cell**:
  ```vim
  yic
  ```
- **Change the text inside a cell**:
  ```vim
  cic
  ```
- **Convert a cell to uppercase**:
  ```vim
  gUac
  ```
- **Convert the text inside a cell to lowercase**:
  ```vim
  guic
  ```

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
    n_jump_to_cell_start = "[c", -- Custom keybinding to jump to the beginning of the current cell
    n_jump_to_cell_end = "]c", -- Custom keybinding to jump to the end of the current cell
  },
})
```

## Troubleshooting

- **Plugin not working**: Ensure the plugin is enabled globally and for the current buffer. Use `:MDTableNavEnable` or `:MDTableNavBufEnable` to enable it.
- **Keybindings conflict**: If the default keybindings conflict with other plugins, customize them using the `keybindings` option.
- **Text object conflicts**: If the `ac` or `ic` patterns conflict with other plugins, customize them using the `inside_cell_pattern` and `around_cell_pattern` options.

## License

This plugin is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
