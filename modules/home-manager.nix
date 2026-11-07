# Home-manager module: applies Malachite to the programs you enable, and hands the colorscheme to
# other modules as the `colorscheme` argument (and the library as `malachite`).
#
# It imports its sibling files by path, so it needs no flake: import this file, or use the flake's
# `homeModules.default`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.malachite;
  repo = import ../. { inherit lib; };

  theme = "malachite-${cfg.colorscheme.slug}";
  portFile = port: ext: "${cfg.package}/share/malachite/${cfg.colorscheme.slug}/${port}/${theme}.${ext}";

  # port -> whether home-manager has that program enabled (absent on older home-manager: false)
  programEnabled =
    path: lib.attrByPath path false config;
  applied = {
    foot = [ "programs" "foot" "enable" ];
    btop = [ "programs" "btop" "enable" ];
    tmux = [ "programs" "tmux" "enable" ];
    fzf = [ "programs" "fzf" "enable" ];
    claude-code = [ "programs" "claude-code" "enable" ];
    sway = [ "wayland" "windowManager" "sway" "enable" ];
    mako = [ "services" "mako" "enable" ];
    waybar = [ "programs" "waybar" "enable" ];
    neovim = [ "programs" "neovim" "enable" ];
    lualine = [ "programs" "neovim" "enable" ];
  };
in
{
  options.malachite = {
    enable = lib.mkEnableOption "Malachite colors for the programs enabled below";

    flavor = lib.mkOption {
      type = lib.types.enum (lib.attrNames repo.colorschemes);
      default = "emerald";
      example = "jade";
      description = "The Malachite flavor to use.";
    };

    colorscheme = lib.mkOption {
      type = lib.types.attrs;
      default = repo.colorschemes.${cfg.flavor};
      defaultText = lib.literalExpression "the colorscheme of `malachite.flavor`";
      example = lib.literalExpression "malachite.lib.fromBase16Yaml (builtins.readFile ./scheme.yaml)";
      description = ''
        The colorscheme as data (see the README). Also the `colorscheme` argument that other
        modules receive. Set it to use a colorscheme other than a built-in flavor.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default =
        (import ../packages {
          inherit lib;
          inherit (pkgs) runCommand writeText symlinkJoin;
          malachite = repo;
          src = ../.;
          colorschemes.${cfg.colorscheme.slug} = cfg.colorscheme;
        }).default;
      defaultText = lib.literalMD "the Malachite package for the selected colorscheme";
      description = "The package holding the port files for the selected colorscheme.";
    };

    ports = lib.mapAttrs (
      name: enablePath:
      lib.mkOption {
        type = lib.types.submodule {
          options.enable = lib.mkOption {
            type = lib.types.bool;
            default = programEnabled enablePath;
            defaultText = lib.literalMD "whether the program is enabled";
            description = "Apply the ${name} port.";
          };
        };
        default = { };
        description = "The ${name} port.";
      }
    ) applied;
  };

  config = lib.mkMerge [
    {
      _module.args = {
        colorscheme = cfg.colorscheme;
        malachite = {
          inherit (repo) lib colorschemes;
          inherit (cfg) package;
          # A port's file for the selected colorscheme, for programs the module does not configure.
          portFile = port: ext: portFile port ext;
        };
      };
    }

    (lib.mkIf cfg.enable (
      lib.mkMerge [
        (lib.mkIf cfg.ports.foot.enable {
          programs.foot.settings.main.include = "${cfg.package}/share/foot/themes/${theme}";
        })
        (lib.mkIf cfg.ports.btop.enable {
          xdg.configFile."btop/themes/${theme}.theme".source = "${cfg.package}/share/btop/themes/${theme}.theme";
        })
        (lib.mkIf cfg.ports.tmux.enable {
          programs.tmux.extraConfig = lib.mkAfter ''
            source-file ${portFile "tmux" "conf"}
          '';
        })
        (lib.mkIf cfg.ports.fzf.enable {
          programs.fzf.defaultOptions = [
            (lib.removeSuffix "\n" (repo.lib.ports.fzf cfg.colorscheme).text)
          ];
        })
        (lib.mkIf cfg.ports.claude-code.enable {
          home.file.".claude/themes/${theme}.json".source = portFile "claude-code" "json";
        })
        (lib.mkIf cfg.ports.sway.enable {
          wayland.windowManager.sway.extraConfig = ''
            include ${portFile "sway" "conf"}
          '';
        })
        (lib.mkIf cfg.ports.waybar.enable {
          # The color names come first, for the rules the user (or another module) appends.
          programs.waybar.style = lib.mkBefore (repo.lib.ports.waybar cfg.colorscheme).text;
        })
        (lib.mkIf cfg.ports.neovim.enable {
          xdg.configFile."nvim/colors/${theme}.lua".source = portFile "neovim" "lua";
        })
        (lib.mkIf cfg.ports.lualine.enable {
          xdg.configFile."nvim/lua/lualine/themes/${theme}.lua".source = portFile "lualine" "lua";
        })
        (lib.mkIf cfg.ports.mako.enable {
          services.mako.settings = (repo.lib.ports.mako cfg.colorscheme).settings;
        })
      ]
    ))
  ];
}
