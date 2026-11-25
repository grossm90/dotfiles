# Neovim config

A guide to what this config does, written for coming back after a few weeks
away. Most of it comes from ThePrimeagen's setup, with a few additions for
PICO-8, Marp slides, and the Zen browser.

Open this file from inside Neovim with `:e ~/.config/nvim/README.md`.

**The leader key is Space.** Wherever this guide says `<leader>`, press Space.

## Contents

- [Custom keys](#custom-keys)
- [Keys that come with Neovim but matter here](#keys-that-come-with-neovim-but-matter-here)
- [Editor settings](#editor-settings)
- [Plugins](#plugins)
- [PICO-8](#pico-8)
- [Todo lists](#todo-lists)
- [Where things live](#where-things-live)
- [Things that may surprise you](#things-that-may-surprise-you)
- [Finding out what a key does](#finding-out-what-a-key-does)

## Custom keys

These are defined in `lua/config/remap.lua` unless a different file is named.

### Files and navigation

| Keys | Mode | What it does |
|---|---|---|
| `<leader>pv` | normal | Opens the built-in file browser (netrw) in the current file's folder. "pv" is "project view". |
| `<leader>pf` | normal | Fuzzy-finds a file by name, starting from the folder Neovim was opened in. "pf" is "project files". |
| `Ctrl-p` | normal | The same, but only files tracked by git. Gives an error outside a git repository. |
| `<leader>ps` | normal | Asks for some text, then lists every place it appears in the project. "ps" is "project search". |
| `<leader>pb` | normal | Lists open buffers (files you have open) to switch between. |
| `<leader>vh` | normal | Searches Neovim's help pages. |
| `<leader>vk` | normal | Searches every key mapping, including the ones in this guide. |
| `Ctrl-d` / `Ctrl-u` | normal | Scrolls half a page down / up and keeps the cursor line in the middle of the screen. |
| `n` / `N` | normal | Next / previous search match, centred on screen. |
| `Ctrl-k` / `Ctrl-j` | normal | Next / previous entry in the quickfix list (compiler errors, search results), centred. |
| `<leader>k` / `<leader>j` | normal | Next / previous entry in the location list (a per-window quickfix list), centred. |

The six finder keys are set in `lua/plugins/telescope.lua`. In a finder
window, type to filter, `Ctrl-n` / `Ctrl-p` move through the results, `Enter`
opens, and `Esc` twice closes.

Inside the file browser: `Enter` opens, `-` goes up a folder, `%` creates a
file, `d` creates a folder, `R` renames, `D` deletes.

### Editing

| Keys | Mode | What it does |
|---|---|---|
| `J` / `K` | visual | Moves the selected lines down / up and fixes their indentation. |
| `J` | normal | Joins the next line onto this one, without moving the cursor. |
| `=ap` | normal | Re-indents the current paragraph and puts the cursor back where it was. |
| `<leader>s` | normal | Starts a find-and-replace for the word under the cursor across the whole file. Type the new text and press `Enter`. |
| `<leader>f` | normal | Formats the current file (set in `lua/plugins/conform.lua`). |
| `<leader>u` | normal | Opens the undo history tree (set in `lua/plugins/undotree.lua`). |
| `Ctrl-c` | insert | Leaves insert mode, same as `Esc`. |
| `Q` | normal | Disabled, so you can't fall into Ex mode by accident. |

### Copy, paste, delete

Vim puts deleted text in the same place as copied text, so deleting something
overwrites what you copied. These keys work around that.

| Keys | Mode | What it does |
|---|---|---|
| `<leader>p` | visual | Pastes over the selection and **keeps** what you copied, so you can paste it again. |
| `<leader>y` | normal, visual | Copies to the system clipboard, so you can paste in other apps. Takes a motion in normal mode, e.g. `<leader>yap` for a paragraph. |
| `<leader>Y` | normal | Copies the rest of the line to the system clipboard. |
| `<leader>d` | normal, visual | Deletes without saving the text anywhere, so your last copy survives. |

### Small helpers

| Keys | Mode | What it does |
|---|---|---|
| `<leader>x` | normal | Makes the current file executable (`chmod +x`). Handy for shell scripts. |
| `<leader>ee` | normal | Inserts a Go error check (`if err != nil { return err }`) below the cursor. Only useful in Go. |

### Completion menu

Set in `lua/plugins/lsp.lua`. These apply in insert mode while the suggestion
menu is showing.

| Keys | What it does |
|---|---|
| `Ctrl-n` / `Ctrl-p` | Next / previous suggestion |
| `Ctrl-y` | Accept the highlighted suggestion ("yes") |
| `Ctrl-e` | Close the menu without accepting |
| `Ctrl-Space` | Open the menu manually |

`Enter` and `Tab` do **not** accept a suggestion. `Enter` just makes a new line.

## Keys that come with Neovim but matter here

This config defines no keys for code intelligence (the language server, or
LSP). It relies on the ones Neovim 0.11 and later provide out of the box. They
work once a language server is running for the file.

| Keys | Mode | What it does |
|---|---|---|
| `K` | normal | Shows documentation for the thing under the cursor |
| `Ctrl-]` | normal | Jumps to the definition. `Ctrl-t` or `Ctrl-o` jumps back. |
| `grn` | normal | Renames the symbol everywhere |
| `gra` | normal, visual | Shows code actions (quick fixes, imports) |
| `grr` | normal | Lists every reference to the symbol |
| `gri` | normal | Jumps to the implementation |
| `gO` | normal | Lists the symbols (functions, variables) in this file |
| `Ctrl-s` | insert | Shows the signature of the function you are calling |
| `]d` / `[d` | normal | Next / previous error or warning |
| `Ctrl-w d` | normal | Shows the full error or warning under the cursor in a floating box |

`gd` is **not** "go to definition" here. It is Vim's older "go to local
declaration". Use `Ctrl-]`.

## Editor settings

Set in `init.lua`.

| Setting | Effect |
|---|---|
| `guicursor = ""` | The cursor is a block in every mode, including insert. |
| `nu`, `relativenumber` | The current line shows its real number; the others show their distance from it. That distance is the count for motions: a line marked 5 is `5j` or `5k` away. |
| `tabstop`, `softtabstop`, `shiftwidth = 4`, `expandtab` | Indentation is 4 spaces, and `Tab` inserts spaces, not a tab character. |
| `smartindent` | New lines get a sensible indent automatically. |
| `wrap = false` | Long lines run off the right edge instead of wrapping. |
| `swapfile = false`, `backup = false` | No `.swp` or backup files are created. |
| `undofile`, `undodir` | Undo history is saved to `~/.vim/undodir`, so `u` still works after closing and reopening a file. |
| `hlsearch = false` | Search matches are not left highlighted after you finish searching. |
| `incsearch` | Matches are shown as you type the search. |
| `termguicolors` | Full 24-bit colour, needed by the theme. |
| `scrolloff = 8` | The view scrolls before the cursor reaches the edge, keeping 8 lines visible above and below. |
| `signcolumn = "yes"` | The narrow column left of the line numbers (for error markers) is always shown, so text doesn't shift sideways. |
| `isfname:append("@-@")` | `@` counts as part of a file name, which matters for `gf` (go to file under cursor). |
| `updatetime = 50` | Neovim reacts faster to the cursor stopping, e.g. for showing diagnostics. |
| `colorcolumn = "80"` | A vertical guide marks column 80. |
| Transparent background | The `Normal` and `NormalFloat` backgrounds are cleared, so the terminal's background shows through. |
| `FIREFOX_PATH` | Points at Zen, for the Marp slide preview. |
| `.p8` files | Highlighted as Lua. See [PICO-8](#pico-8) for the rest. |

## Plugins

Each plugin has its own file in `lua/plugins/`. The plugin manager is
lazy.nvim, set up in `lua/config/lazy.lua`.

| Plugin | File | What it gives you |
|---|---|---|
| lazy.nvim | `config/lazy.lua` | Installs and updates the other plugins. Run `:Lazy` to see them; press `U` there to update, `q` to close. It checks for updates in the background and tells you when there are some. |
| catppuccin | `plugins/catppuccin.lua` | The colour theme. |
| telescope | `plugins/telescope.lua` | Fuzzy finder for files, text, buffers, help and key mappings. Keys are listed under [Files and navigation](#files-and-navigation). `:Telescope` followed by `Tab` shows everything else it can search. |
| nvim-treesitter | `plugins/treesitter.lua` | Accurate syntax highlighting and indentation. The first time you open a new kind of file, it downloads the grammar for that language, then turns highlighting on. Needs the `tree-sitter-cli` package. |
| undotree | `plugins/undotree.lua` | A visual history of every change, including branches that plain undo loses. `<leader>u` toggles it. |
| conform | `plugins/conform.lua` | Code formatting with `<leader>f`. See the table below. |
| nvim-lspconfig, mason, mason-lspconfig | `plugins/lsp.lua` | Language servers: errors as you type, go to definition, rename. `:Mason` opens an installer for servers and formatters. `lua_ls` (Lua) is installed automatically, and any server installed through Mason is switched on by itself. Per-server settings are the `vim.lsp.config(...)` blocks. |
| nvim-cmp, LuaSnip, and the `cmp-*` plugins | `plugins/lsp.lua` | The completion menu. Suggestions come from the language server, snippets, and words in the current file. The signature-help source adds parameter hints. |
| fidget | `plugins/lsp.lua` | Small progress messages in the bottom-right corner while a language server is working. |
| checkmate.nvim | `plugins/checkmate.lua` | Todo-list files with checkboxes, `@tags`, counts and an archive. See [Todo lists](#todo-lists). |
| todo-comments.nvim | `plugins/todo-comments.lua` | Highlights `TODO:`-style comments in code and lists them across the project. |
| marp.nvim | `plugins/marp.lua` | Preview and export Marp slide decks from Markdown. Type `:Marp` and press `Tab` to see its commands. Themes are read from `~/.local/share/marp/themes` (installed by the `teaching-scripts` repo), and the preview opens in Zen. |

### Formatters

conform runs these when you press `<leader>f`. Each one is a separate program
that has to be installed, through `:Mason` or `paru`.

| File type | Formatter |
|---|---|
| C, C++ | `clang-format` (uses a `.clang-format` file if the project has one, otherwise LLVM style) |
| Lua | `stylua` |
| PICO-8 (carts and their modules) | the PICO-8 language server |
| Go | `gofmt` |
| JavaScript, TypeScript | `prettier` |
| Anything else | The language server's own formatting, if it has any |

Format-on-save is written into `plugins/conform.lua` but is currently switched
off; see the first item under "Things that may surprise you".

## PICO-8

This mirrors the VS Code setup (the `pico8-ls` extension with its workspace
settings), using the same language server.

**What counts as PICO-8 code:** a `.p8` cart, and any `.lua` file in the same
folder as a cart. That covers a cart whose code is a list of `#include`
lines, with the modules beside it. Lua files anywhere else, including this
config, are ordinary Lua. The rule lives in `lua/config/pico8.lua`.

In PICO-8 code:

| Feature | Behaviour |
|---|---|
| Language server | `pico8-ls` runs, so `spr()`, `btn()` and the rest are known. The general Lua server stays out, so it doesn't flag PICO-8 syntax as errors. |
| Completion | Suggestions appear as you type code, but not inside comments or strings. |
| Parameter hints | While you type a call's arguments, the menu shows the function's parameters with the current one marked. This works in every language, not only PICO-8. `Ctrl-s` still shows the full signature on request. |
| Documentation | `K` on a function shows its help. |
| Formatting | `<leader>f` uses the PICO-8 server's formatter. It does nothing while the file has a syntax error. Nothing is formatted on save or as you type. |

`pico8-ls` is installed by Mason automatically. It needs Node; if the install
fails on a new machine, run `nvm install --lts` and then `:Mason`.

A new `.lua` file created in a cart's folder is saved to disk immediately,
empty. The server only knows about files it can find on disk, so without
this it gives no suggestions until the first `:w`. For a new module to see
the rest of the game's functions and variables, add its `#include` line to
the cart.

A file's status is decided when it is first opened. If you add a cart to a
folder while its `.lua` files are already open, reopen them (`:e`).

## Todo lists

Two plugins stand in for the VS Code Todo+ extension: checkmate.nvim for
todo files, and todo-comments.nvim for `TODO` comments inside code.

### Todo files

A todo file is one named `TODO`, `todo`, `TODO.md`, `todo.md`, or ending in
`.todo`. It is ordinary Markdown: headings for projects, checkboxes for
tasks, and indentation for subtasks.

```markdown
# Luna

## Player
- [ ] Movement @priority(high)
  - [x] Walk @done(11/25/26 10:02)
  - [ ] Jump @started(11/25/26 10:15)
- [c] Double jump

## Archive
- [x] Create the repo @done(11/25/26 09:50)
```

In Neovim the boxes are drawn as `☐` (to do), `✔` (done) and `✘`
(cancelled), and a parent task shows a done/total count for its subtasks.
On disk and on GitHub they stay `- [ ]`, `- [x]` and `- [c]`.

Typing `- [ ]` and leaving insert mode makes a todo. Pressing `Enter` at the
end of a todo starts the next one.

All keys start with `<leader>T` and only work in a todo file. They are set in
`lua/plugins/checkmate.lua`.

| Keys | What it does |
|---|---|
| `<leader>Tn` | New todo on this line |
| `<leader>Tt` | Toggle between to do and done |
| `<leader>Tc` / `<leader>Tu` | Mark done / not done |
| `<leader>Tx` | Mark cancelled |
| `<leader>T=` / `<leader>T-` | Step forwards / backwards through the states |
| `<leader>Ts` | Add or remove `@started` with the current time |
| `<leader>Td` | Add or remove `@done` with the current time (also ticks the box) |
| `<leader>Tp` | Add or remove `@priority`; pick low, medium or high |
| `<leader>Tv` | Change the value of the `@tag` under the cursor |
| `<leader>T]` / `<leader>T[` | Jump to the next / previous `@tag` on the todo |
| `<leader>Ta` | Archive: move finished todos under the `## Archive` heading |
| `<leader>TF` | Pick a todo in this file from a list |
| `<leader>Tr` | Turn a todo back into plain text |
| `<leader>TR` | Remove all `@tags` from a todo |

The toggle, check and state keys also work on a visual selection of several
todos. You can write any other `@tag` or `@tag(value)` by hand.

Not available, compared with Todo+: elapsed time (`@lasted`), estimates
(`@est`), the running timer, and whole-file statistics.

### Todo comments in code

Comments beginning with `TODO:`, `FIX:`, `HACK:`, `WARN:`, `PERF:`, `NOTE:`
or `TEST:` are highlighted, in any language. The colon is required. Set in
`lua/plugins/todo-comments.lua`.

| Keys | What it does |
|---|---|
| `<leader>pt` | Lists every todo comment in the project in a finder. "pt" is "project todos". |
| `]t` / `[t` | Jumps to the next / previous todo comment in the file. This replaces Neovim's built-in use of those keys for stepping through tag matches. |

## Where things live

```
~/.config/nvim/
├── init.lua              editor settings; loads the two files below
├── lua/
│   ├── config/
│   │   ├── lazy.lua      plugin manager setup; sets the leader key
│   │   ├── remap.lua     custom keys
│   │   └── pico8.lua     decides whether a file is PICO-8 code
│   └── plugins/          one file per plugin (or group of plugins)
├── lazy-lock.json        exact plugin versions; rewritten on update, not in git
└── README.md             this file
```

To add a plugin, create a new file in `lua/plugins/` that returns its spec.
lazy.nvim picks up every file in that folder.

## Things that may surprise you

- **Format-on-save is configured but switched off.** `plugins/conform.lua`
  asks for it, but `plugins/lsp.lua` calls conform's setup a second time,
  which resets it. Formatting only happens when you press `<leader>f`. To turn
  format-on-save on, delete the marked block near the top of the `config`
  function in `plugins/lsp.lua`. `:autocmd Conform` shows whether it is
  active: an empty list means off.
- **The leader key is set twice,** in `config/lazy.lua` and `config/remap.lua`.
  Both set it to Space, so it is harmless.
- **`Ctrl-k` is next and `Ctrl-j` is previous** in the quickfix list, which is
  the opposite of what `j` and `k` suggest.

## Finding out what a key does

| Command | What it shows |
|---|---|
| `:verbose nmap <leader>s` | What a normal-mode key is mapped to, and which file set it |
| `<leader>vk` | A searchable list of every mapping |
| `:help K` | The built-in meaning of a key (here, `K`) |
| `:Tutor` | Neovim's built-in refresher lesson, about 30 minutes |
