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

                markdown.enable = true;
                bash.enable = true;
              };

              options = {
                timeoutlen = 1000;
                tabstop = 2;
                shiftwidth = 2;
                expandtab = true;
                number = true;
                relativenumber = true;
              };
            };
          }
        ];
      };
    in
    {
      # Access via `nix build` or `nix run`
      packages.${system}.default = customNeovim.neovim;
    };
}
