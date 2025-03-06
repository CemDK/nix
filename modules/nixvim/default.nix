{ self, pkgs, ... }: {
  config = {
    enable = true;

    opts = {
      inccommand = "split";

      scrolloff = 8;

      number = true;
      relativenumber = false;

      expandtab = true;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;
      wrap = false;

      autoindent = true;
      smartindent = true;
      breakindent = true;

      incsearch = true;
      ignorecase = true;
      smartcase = true;

      cursorline = true;
      cursorlineopt = "number";

      termguicolors = true;
    };

    globals = { mapleader = " "; };

    keymaps = import ./keymaps.nix;

    plugins = {
      lightline.enable = true;
      lsp = {
        enable = true;
        servers.rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
      };
      cmp = {
        enable = true;
        autoEnableSources = true;
      };
      treesitter = {
        enable = true;
        nodejsPackage = null;
        gccPackage = null;
        nixGrammars = true;
        grammarPackages = with pkgs.vimPlugins; [
          nvim-treesitter-parsers.c
          nvim-treesitter-parsers.markdown
          nvim-treesitter-parsers.nix
          nvim-treesitter-parsers.rust
          nvim-treesitter-parsers.terraform
          nvim-treesitter-parsers.toml
          nvim-treesitter-parsers.typescript
          nvim-treesitter-parsers.vim
          nvim-treesitter-parsers.vimdoc
          nvim-treesitter-parsers.yaml
        ];

        settings = {
          auto_install = true;
          highlight.enable = true;
          indent.enable = true;
        };
      };
    };

    colorscheme = "solarized";

    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = comment-nvim;
        config = ''lua require("Comment").setup()'';
      }
      {
        plugin = fzf-lua;
        config = ''lua require("fzf-lua").setup({"fzf-vim"})'';
      }
      (pkgs.vimUtils.buildVimPlugin {
        name = "oat-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "CemDK";
          repo = "oat.nvim";
          rev = "b6c501bf93db1de8eb5febf1013fd32023bcaa9f";
          hash = "sha256-lAN0hRpyloNZlft1ht8A7MNdanxJLi0RXWThobZO2Hg=";
        };
      })
    ];

    extraConfigLuaPre = ''
      require('solarized').setup({ 
        transparent = true, 
        palette = 'solarized' 
      })
    '';

    extraConfigLuaPost = "";

  };
}
