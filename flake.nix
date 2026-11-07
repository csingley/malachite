{
  description = "Malachite: a colorscheme with named roles, and the ports that apply it to your apps";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # only for the module checks
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, nixpkgs, ... }:
    let
      # A home-manager configuration that enables the module and the programs it applies, and a
      # check of the files it generates.
      moduleCheck =
        {
          pkgs,
          home-manager,
          extra,
          expect,
        }:
        let
          hm = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./modules/home-manager.nix
              {
                home = {
                  username = "test";
                  homeDirectory = "/home/test";
                  stateVersion = "24.11";
                };
                malachite = {
                  enable = true;
                  flavor = "jade";
                };
                programs.foot.enable = true;
                programs.btop.enable = true;
                programs.tmux.enable = true;
                programs.fzf.enable = true;
                services.mako.enable = true;
                programs.waybar.enable = true;
                programs.neovim.enable = true;
              }
              extra
            ];
          };
        in
        pkgs.runCommand "malachite-module-check" { } ''
          cd ${hm.config.home-files}
          grep -q '^include=.*malachite-jade' .config/foot/foot.ini
          test -e .config/btop/themes/malachite-jade.theme
          grep -q 'source-file .*malachite-jade.conf' .config/tmux/tmux.conf
          grep -q '^background-color=#20360c' .config/mako/config
          case '${hm.config.home.sessionVariables.FZF_DEFAULT_OPTS}' in *--color=fg:*) ;; *) echo "fzf options missing"; exit 1;; esac
          grep -q '^@define-color bg #050901;' .config/waybar/style.css
          grep -q 'malachite-jade' .config/nvim/colors/malachite-jade.lua
          test -e .config/nvim/lua/lualine/themes/malachite-jade.lua
          ${expect}
          touch $out
        '';
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake =
        let
          malachite = import ./. { inherit (nixpkgs) lib; };
        in
        {
          inherit (malachite) lib colorschemes;
          homeModules.default = ./modules/home-manager.nix;
        };

      perSystem =
        { pkgs, config, ... }:
        {
          packages = import ./packages {
            inherit (pkgs)
              lib
              runCommand
              writeText
              symlinkJoin
              nfpm
              ;
            malachite = import ./. { inherit (pkgs) lib; };
            src = self;
          };

          checks.contract = pkgs.callPackage ./checks {
            malachite = import ./. { inherit (pkgs) lib; };
            src = self;
          };
          # The home-manager module, built into a real configuration for Jade, against current
          # nixpkgs and home-manager and against the 26.05 release.
          checks.module = moduleCheck {
            inherit pkgs;
            home-manager = inputs.home-manager;
            extra = {
              programs.claude-code = {
                enable = true;
                package = null;
              };
              wayland.windowManager.sway = {
                enable = true;
                package = null;
                checkConfig = false;
              };
            };
            expect = ''
              grep -q '^include .*malachite-jade.conf' .config/sway/config
              test -e .claude/themes/malachite-jade.json
            '';
          };
          checks.module-stable = moduleCheck {
            pkgs = inputs.nixpkgs-stable.legacyPackages.${pkgs.system};
            home-manager = inputs.home-manager-stable;
            extra = { };
            expect = "";
          };
          # The PKGBUILD names the version being released.
          checks.version = pkgs.runCommand "malachite-version-check" { } ''
            grep -qx "pkgver=$(cat ${./VERSION})" ${./packaging/arch/PKGBUILD}
            touch $out
          '';
          checks.packages = pkgs.linkFarm "malachite-packages" (
            pkgs.lib.mapAttrsToList (name: path: { inherit name path; }) config.packages
          );
        };
    };
}
