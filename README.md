# EdEEX

**EdEEX** is a Neovim plugin for editing embdedded [Phoenix LiveView] templates, inspired by [Org Mode]ʼs `org-edit-src-code`.

![CleanShot 2021-10-30 at 14 51 16](https://user-images.githubusercontent.com/423798/139556758-78adc3ce-d65f-4650-89c5-8d5b1af11565.gif)

## Installation

### Requirements

This plugin depends on [`nvim-treesitter`] and the [Elixir Tree-sitter grammar].

### Install

Use Neovimʼs built-in packages feature (`:h packages`) or a plugin manager—[Packer] comes to mind:

```lua
use {"ngscheurich/edeex.nvim", requires = "nvim-treesitter/nvim-treesitter"}
```

## Usage

EdEEx has two primary functions, `edit` and `apply`. While these can be called directly, it is highly recommended to set up a key mapping using the `setup` function.

You can combine installation and setup into a single Packer form for convenience:

```lua
use {
  "ngscheurich/edeex.nvim",
  requires = "nvim-treesitter/nvim-treesitter"
  config = function ()
    require("edeex").setup({mapping = "<C-c>e"})
  end
}
```

### Example

Assuming you have configured EdEEx as above, and have the following Elixir code:

```elixir
defmodule AppWeb.HelloLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <section>
      <header>
        <h1>Hello, <%= @name %>!</h1>
      </header>
    </section>
    """
  end

  def mount(_params, %{"name" => name}, socket) do
    {:ok, assign(socket, :name, name)}
  end
end
```

Placing the cursor anywhere inside of the embedeed HEEx template and pressing `<C-c>e` will open a scratch buffer with the following contents:

```html
<section>
  <header>
    <h1>Hello, <%= @name %>!</h1>
  </header>
</section>
```

The bufferʼs `filetype` is set to `eelixir` and it inherits the indentation settings (`shiftwidth`, `tabstop`, and `softtabstop`) from the source buffer. By pressing `<C-c>e` in this buffer, any changes made to it will be applied to the source buffer.

## Options

| Name         | Default | Description                                                            |
| ------------ | ------- | ---------------------------------------------------------------------- |
| `mapping`    | `nil`   | Key mapping to enter and exit the edit buffer (Normal and Insert mode) |
| `split`      | `true`  | Open a horizontal split when summoning the edit buffer                 |
| `autoformat` | `true`  | Format EEx code when entering and leaving the edit buffer              |

## Note

This is a very beta-level plugin and could get broken or abandoned at any time. Use at your own peril!

[Org Mode]: https://orgmode.org/
[Phoenix LiveView]: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
[`nvim-treesitter`]: https://github.com/nvim-treesitter/nvim-treesitter
[Elixir Tree-sitter grammar]: https://github.com/elixir-lang/tree-sitter-elixir
[Packer]: https://github.com/wbthomason/packer.nvim
