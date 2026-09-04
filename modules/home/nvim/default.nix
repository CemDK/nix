{ pkgs, ... }:
{
  # ============================================================================
  # MY NVIM DEPENDENCIES
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
    # Managed by home-manager
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
    typescript-go
    php # runtime for php-cs-fixer

    # ---------------------------------
    # LSP servers and tools
    # ---------------------------------
    # Parsers
    tree-sitter

    # Formatting / Linting
    biome
    eslint
    nixfmt
    php84Packages.php-cs-fixer
    prettierd # markdown/js/ts/json/yaml/css formatter (daemonized prettier)
    ruff # python linter/formatter (also an LSP server)
    statix # nix linter
    treefmt

    # LSP servers
    bash-language-server
    basedpyright
    docker-language-server
    dockerfile-language-server
    lua-language-server
    nixd
    intelephense
    omnisharp-roslyn
    roslyn-ls
    tailwindcss-language-server
    terraform-ls
    texlab
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server

    # NVIM lsp stuff seems to use libuv-watchdirs, but this makes nvim rather slow when starting.
    # installing inotify-tools seems to fix this. neovim message:
    #  File watch backend: libuv-watchdirs
    #  ⚠️ WARNING libuv-watchdirs has known performance issues. Consider installing inotify-tools.
    # inotify-tools
    # only import if x86_64-linux, since inotify-tools is not available for darwin
    (lib.mkIf pkgs.stdenv.isLinux inotify-tools)
  ];
}
