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
            config.vim = {
              theme = {
                enable = true;
                name = "tokyonight";
                style = "night";
              };

              statusline.lualine.enable = true;
              telescope.enable = true;
              autocomplete.nvim-cmp.enable = true;
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
