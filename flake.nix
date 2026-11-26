{
  description = "Standalone nvf Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nvf, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      texEnv = pkgs.texlive.combine {
        inherit (pkgs.texlive)
          scheme-basic
          latexmk
          amsmath
          ec
          cm-super
          ;
      };
      customNeovim = nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          {
            vim = {
              theme = {
                enable = true;
                name = "tokyonight";
                style = "night";
              };
              binds.whichKey = {
                enable = true;
                setupOpts = {
                  windows = true;
                  text_objects = true;
                  z = true;
                  nav = true;
                };
              };
              tabline.nvimBufferline.enable = true;
              statusline.lualine.enable = true;
              telescope.enable = true;
              autocomplete.nvim-cmp.enable = true;

              luaConfigRC.cmp-sources = ''
                local cmp = require('cmp')
                cmp.setup({
                  sources = cmp.config.sources({
                    { name = 'nvim_lsp' }, -- LSP suggesties
                    { name = 'path' },     -- Bestanden en mappen paden (typ / of ./ om te activeren)
                    { name = 'buffer' },   -- Tekst uit huidige buffer
                  })
                })
              '';
              # Enable core LSP framework features
              lsp = {
                enable = true;
                formatOnSave = true;
                lightbulb.enable = true;
                trouble.enable = true;
              };
              languages = {
                enableTreesitter = true;

                nix = {
                  enable = true;
                  lsp.enable = true;
                  lsp.servers = [ "nixd" ]; # or "nil"
                  format = {
                    enable = true;
                    type = [ "nixfmt" ]; # Uses nixfmt-rfc-style package from nixpkgs
                  };
                };
                # LaTeX / TeX module configuration
                tex = {
                  enable = true;
                  lsp = {
                    enable = true;
                    servers = [ "texlab" ];
                  };
                  treesitter = {
                    enable = true;
                  };
                };

                markdown.enable = true;
                bash.enable = true;
              };
              extraPlugins = {
                vimtex = {
                  package = pkgs.vimPlugins.vimtex;
                  setup = ''
                    vim.g.vimtex_view_method = 'zathura'
                    vim.g.vimtex_compiler_method = 'latexmk'
                    vim.g.vimtex_quickfix_open_on_warning = 0
                  '';
                };
              };

              options = {
                timeoutlen = 2000;
                tabstop = 2;
                shiftwidth = 2;
                expandtab = true;
                number = true;
                relativenumber = true;
              };
              keymaps = [
                {
                  key = "<localleader>ll";
                  mode = "n";
                  silent = true;
                  action = "<cmd>VimtexCompile<CR>";
                  desc = "VimTeX compile toggle";
                }
                {
                  key = "<localleader>lv";
                  mode = "n";
                  silent = true;
                  action = "<cmd>VimtexView<CR>";
                  desc = "VimTeX view PDF";
                }
                {
                  key = "<C-Tab>";
                  mode = "n";
                  silent = true;
                  action = ":bn<CR>";
                  desc = "Next buffer";
                }
                {
                  key = "<C-S-Tab>";
                  mode = "n";
                  silent = true;
                  action = ":bp<CR>";
                  desc = "Previous buffer";
                }
                {
                  key = "<leader>fk";
                  mode = "n";
                  silent = true;
                  action = ":Telescope keymaps<CR>";
                  desc = "Open keymaps in telescope";
                }
              ];
              extraPackages = [
                texEnv
                pkgs.texlab
                pkgs.zathura
              ];
            };
          }
        ];
      };
    in
    {
      # Access via `nix build` or `nix run`
      packages.${system}.default = (customNeovim.neovim).overrideAttrs (oldAttrs: {
        meta = (oldAttrs.meta or { }) // {
          license = pkgs.lib.licenses.gpl3Only;
          platforms = pkgs.lib.platforms.unix;
        };
      });
    };
}
