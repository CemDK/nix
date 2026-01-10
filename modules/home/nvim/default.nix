{ pkgs, ... }:
{
  # ============================================================================
  # NVIM STUFF
  # ============================================================================
  home.packages = with pkgs; [
    # ---------------------------------
    # General tools
    # ---------------------------------
    fd
    lazygit
    neovide
    neovim
    ripgrep

    # ---------------------------------
    # Packages managed by home-manager
    # ---------------------------------
    # fzf

    # ---------------------------------
    # Development tools
    # ---------------------------------
    gcc # needed for treesitter
    gnumake # needed for avante
    lua
    luajitPackages.luarocks
    nodejs
    pnpm
    rustup # includes rust-analyzer
    typescript

    # ---------------------------------
    # LSP servers and tools
    # ---------------------------------
    # Parsers
    tree-sitter

    # Formatting / Linting
    biome
    eslint
    nixfmt
    nodePackages.prettier
    statix # nix linter
    treefmt

    # LSP servers
    bash-language-server
    docker-language-server
    dockerfile-language-server
    lua-language-server
    nixd
    omnisharp-roslyn
    roslyn-ls
    tailwindcss-language-server
    terraform-ls
    typescript-go
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server

    # NVIM lsp stuff seems to use libuv-watchdirs, but this makes nvim rather slow when opening
    # installing inotify-tools seems to fix this
    #  File watch backend: libuv-watchdirs
    #  ⚠️ WARNING libuv-watchdirs has known performance issues. Consider installing inotify-tools.
    inotify-tools
  ];
}
