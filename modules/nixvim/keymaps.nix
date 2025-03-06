[
  # fzf-lua
  {
    key = "<leader>b";
    action = "<cmd> Buffers<CR>";
  }
  {
    key = "<leader>f";
    action = "<cmd> Files<CR>";
  }
  {
    key = "<leader>h";
    action = "<cmd> History<CR>";
  }
  {
    key = "<leader>g";
    action = "<cmd> GFiles<CR>";
  }
  {
    key = "<leader>G";
    action = "<cmd> GFiles?<CR>";
  }
  {
    key = "<leader>r";
    action = "<cmd> Rg<CR><CR>";
  }

  # -- Keep results centered while searching
  {
    mode = "n";
    key = "n";
    action = "nzzzv";
  }
  {
    mode = "n";
    key = "N";
    action = "Nzzzv";
  }

  # -- Keep things highlighted when moving with < or >
  {
    mode = "v";
    key = "<";
    action = "<gv";
  }
  {
    mode = "v";
    key = ">";
    action = ">gv";
  }

  # TODO: fix
  {
    mode = "n";
    key = "<leader>ts";
    action = ''
      function() vim.cmd("belowright 12split")
                  vim.cmd("set winfixheight")
                  vim.cmd("term")
                  vim.cmd("startinsert")
    '';
  }

]
