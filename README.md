# vimcat

A supercat with Vim powers!

![Screenshot of a side by side comparison of vimcat on the left and cat on the right](screenshot.png)

## Installation

`vimcat` is a standard Vim plugin. Installing it via your favorite plugin manager automatically installs and symlinks the `vimcat` CLI executable into your `$PATH`.

### 1. Add to Plugin Manager

* **vim-plug**
  ```vim
  Plug 'ofavre/vimcat'
  ```

* **lazy.nvim**
  ```lua
  { 'ofavre/vimcat' }
  ```

* **packer.nvim**
  ```lua
  use 'ofavre/vimcat'
  ```

* **Standard Vim 8+ Packages**
  ```bash
  mkdir -p ~/.vim/pack/plugins/start
  git clone https://github.com/ofavre/vimcat.git ~/.vim/pack/plugins/start/vimcat
  ```

### 2. Automatic CLI Executable Linking

The plugin automatically detects if `vimcat` is available in your shell `$PATH`. On first launch of Vim or Neovim, `vimcat` automatically symlinks the CLI executable into the first available directory in your `$PATH` (checking `~/.local/bin`, `~/bin`, `~/.bin`).

* **Manual trigger**: You can re-trigger linking at any time inside Vim via `:VimcatInstall`.
* **Disable auto-linking**: Set `let g:vimcat_auto_install = 0` in your `.vimrc` / `init.vim` if you prefer to create the symlink manually.

---

## Usage

### From the Command Line (CLI)

```bash
# Print a file with Vim syntax highlighting
vimcat main.c

# Print with line numbers
vimcat -n main.c

# Force 256 colors or truecolor
vimcat --colors=256 main.c
vimcat --colors=true main.c

# For more options:
vimcat --help
```

### Inside Vim / Neovim

You can also use `:TOansicolorcodes` directly inside Vim to convert the current buffer or selection into ANSI escape sequences:

```vim
:TOansicolorcodes
:10,30TOansicolorcodes
```

---

## Configuration

`vimcat` will automatically load configuration files if present, checking in the following order:

1. `${XDG_CONFIG_HOME:-~/.config}/vim/vimcatrc` (or `.conf`)
2. `${XDG_CONFIG_HOME:-~/.config}/vimcat/vimcatrc` (or `.conf`)
3. `~/.vimcatrc`
4. `./.vimcatrc`

---

## How does it work?

`vimcat` launches headless Vim in Ex mode and runs a conversion VimScript to translate syntax highlighting into ANSI color escape codes, printing colorized output to standard output (`stdout`).

The translation VimScript is inspired by Vim's built-in `:TOhtml` plugin (`:help :TOhtml`).

## Performance

Inspecting syntax highlighting with `synID()` requires iterating over characters to detect color changes.

On an Intel Core i7-8750H CPU @ 2.20GHz capped at base frequency, highlighting a standard C file processes approximately 578 lines/sec (1.73s per 1,000 lines).
