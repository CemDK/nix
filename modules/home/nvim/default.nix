{ pkgs, ... }: {
  # nvim dependencies
  home.packages = with pkgs; [
    fd
    # fzf
    lazygit
    neovide
    neovim
    ripgrep

    ###################
    # Code
    lua
    luajitPackages.luarocks
    nodejs
    pnpm
    rustup
    typescript

    tree-sitter
    # formatting / linting
    nodePackages.prettier
    statix # nix linter
    nixd
    nixfmt-classic
    # Let mason do these
    # eslint
    # eslint_d
    # lua-language-server
    # nodePackages.vscode-json-languageserver
    # tailwindcss-language-server
    # typescript-language-server
  ];
}
