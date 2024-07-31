{ self, pkgs, ... }:
{
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

    globals = {
      mapleader = " ";
    };

    keymaps = [
      # fzf-lua
      {
        action = "<cmd> Buffers<CR>";
        key = "<leader>b";
      }
      {
        action = "<cmd> Files<CR>";
        key = "<leader>f";
      }
      {
        action = "<cmd> History<CR>";
        key = "<leader>h";
      }
      {
        action = "<cmd> GFiles<CR>";
        key = "<leader>g";
      }
      {
        action = "<cmd> GFiles?<CR>";
        key = "<leader>G";
      }
      {
        action = "<cmd> Rg<CR><CR>";
        key = "<leader>r";
      }
    ];
    
    plugins = {
      lightline.enable = true;
      # nvim-tree.enable = true;
    };
    
    #colorschemes.gruvbox.enable = true;

    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = comment-nvim;
        config = ''lua require("Comment").setup()''; 
      }
      {
        plugin = fzf-lua;
        config = ''lua require("fzf-lua").setup({"fzf-vim"})''; 
      }
    ];
    
  };
}
