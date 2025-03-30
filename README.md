# Vim ""Lsp""

## Preview
![Woaw](https://github.com/user-attachments/assets/2bdb1db7-0fdd-453c-8703-10c297f9ee3c)

## Installation

Put all the .vim files in your `$HOME/.vim` folder.
All enabled lsps will be started on vim startup.

### For clang lsp

- Clang is required on the machine
- Run `:LspStart clang`

### For banana lsp

- The banana vera++ repo is required
- Put the files in `scripts` in a working `PATH`
- Run `:LspStart banana`
- Ignore the error (it only happens once)

## Removing

- Run `:LspStop <Nothing -> All|Lsp name>`
