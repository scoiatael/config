{ config, lib, pkgs, persway, ... }:
# https://github.com/johnae/nixos-configuration/blob/b10bedaf0dc66bba527a2d825fe5f4b687a1cbe2/home/sway.nix
let
  swayservice = Description: Service: {
    Unit = {
      inherit Description;
      After = "sway-session.target";
      BindsTo = "sway-session.target";
    };

    Service = { Type = "simple"; } // Service;

    Install = { WantedBy = [ "sway-session.target" ]; };
  };
  swayr = "${pkgs.swayr}/bin/swayr";
in {
  nixpkgs.overlays = [ persway.overlays.default ];

  systemd.user.services = {
    persway = swayservice "Small Sway IPC Deamon" {
      ExecStart = "${pkgs.persway}/bin/persway -a";
    };
    swayrd = swayservice "A window-switcher & more for sway" {
      ExecStart = "${pkgs.swayr}/bin/swayrd";
      Environment = [ "PATH=${pkgs.wofi}/bin" ];
    };
    mako = swayservice "Lightweight notification daemon for Wayland" {
      ExecStart = "${pkgs.mako}/bin/mako";
    };
  };

  wayland.windowManager.sway.swaynag = { enable = true; };
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
      base = true;
    };
    package = null;
    extraSessionCommands = ''
      export XDG_CURRENT_DESKTOP=Unity
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QT_QPA_PLATFORMTHEME=qt5ct
      export MOZ_ENABLE_WAYLAND=1
    '';
    systemdIntegration = true;
    extraConfig = let
      swaylock =
        ''bash -c "swaylock -f --image $(shuf -e -n 1 ~/Wallpapers/*)"'';
    in ''
      ### Output configuration
      #
      # Default wallpaper (more resolutions are available in /run/current-system/sw/share/backgrounds/sway/)
      output * bg ~/Wallpapers/82bfba84-4d9d-4c7b-bd5c-19d1bb3aee1a.jpg fill
      #
      # Example configuration:
      #
      #   output HDMI-A-1 resolution 1920x1080 position 1920,0
      #
      # You can get the names of your outputs by running: swaymsg -t get_outputs
      output  'Acer Technologies XB271HK #ASOP6fQBuwTd' scale 1.8

      set $laptop 'Unknown 0x095F 0x00000000'
      output $laptop scale 1.8
      bindswitch --reload --locked lid:on output $laptop disable
      bindswitch --reload --locked lid:off output $laptop enable
      exec_always ~/dotiles/bin/__sway_reset_outputs.sh

      bindsym Ctrl+Left workspace prev
      bindsym Ctrl+Right workspace next
      bindsym Mod4+Ctrl+L exec ${swaylock}
      bindsym Alt+Tab exec ${swayr} switch-window
      bindsym Mod4+Tab exec ${swayr} switch-workspace
      bindsym Mod4+c exec ${swayr} execute-swaymsg-command

      ### Idle configuration
      #
      # Example configuration:
      #
      exec swayidle -w \
              timeout 300 '${swaylock}' \
              timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
              timeout 1200 'systemctl suspend' \
              before-sleep '${swaylock}'

      #
      # This will lock your screen after 300 seconds of inactivity, then turn off
      # your displays after another 300 seconds, and turn your screens back on when
      # resumed. It will also lock your screen before your computer goes to sleep.

      input "type:touchpad" {
          dwt enabled
          tap enabled
          natural_scroll enabled
          middle_emulation enabled
      }
      #
      input "type:keyboard" {
          xkb_layout pl
          xkb_variant ,nodeadkeys
          xkb_options caps:ctrl_modifier
      }

      # https://dev.gnupg.org/T6041
      for_window [app_id="pinentry-qt"] floating enable

      # NOTE: zoom doesn't set class nor app id.
      # main window is 'Zoom - X account'
      # meeting window is 'Zoom Meeting'
      # settings window is 'Settings'. duh.
      # ...and of course waiting window is '.zoom '
      for_window [title="^\.?[Zz]oom"] floating enable
      for_window [title="^\.?[Zz]oom"] border normal
      # and if the app is not on when you join it's even worse.
      for_window [title="^join"] floating enable
      for_window [title="^join"] border normal

      bar swaybar_command waybar

      # https://github.com/swaywm/sway/issues/4112
      seat seat0 xcursor_theme Adwaita

      include /etc/sway/config.d/*
    '';
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "rofi -no-lazy-grab -show drun";
      bars = [{
        mode = "dock";
        hiddenState = "hide";
        position = "top";
        workspaceButtons = true;
        workspaceNumbers = true;
        statusCommand =
          "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 9.0;
        };
        trayOutput = "primary";
        colors = {
          background = "#323232";
          statusline = "#ffffff";
          separator = "#666666";
          focusedWorkspace = {
            border = "#4c7899";
            background = "#285577";
            text = "#ffffff";
          };
          activeWorkspace = {
            border = "#333333";
            background = "#5f676a";
            text = "#ffffff";
          };
          inactiveWorkspace = {
            border = "#333333";
            background = "#222222";
            text = "#888888";
          };
          urgentWorkspace = {
            border = "#2f343a";
            background = "#900000";
            text = "#ffffff";
          };
          bindingMode = {
            border = "#2f343a";
            background = "#900000";
            text = "#ffffff";
          };
        };
      }];
    };
  };
  programs.mako = {
    enable = true;
    font = "JetBrainsMono Nerd Font 10";
    backgroundColor = "#1E1D2F";
    textColor = "#D9E0EE";
    defaultTimeout = 5000;
  };
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "bottom";
        position = "bottom";
        height = 30;
        modules-left = [ "custom/shutdown" "idle_inhibitor" "custom/ddcutil" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "tray" ];
        "custom/shutdown" = {
          format = "";
          interval = "once";
          on-click = "nwgbar";
        };
        "custom/ddcutil" = {
          format = "{percentage}% {icon}";
          interval = 10;
          format-icons = [ "" "" "" ];
          return-type = "json";
          exec = ../bin/monitor.sh;
          on-scroll-up = "${../bin/monitor.sh} up";
          on-scroll-down = "${../bin/monitor.sh} down";
          on-click = "ddcui";
          # exec-if = "bash -c 'ddcutil detect | grep VCP'";
        };
        idle_inhibitor = {
          format = "{icon} ";
          format-icons = {
            "activated" = "";
            "deactivated" = "";
          };
        };
        "sway/window" = { icon = true; };
      };
    };
    style = ''
      * {
          font-size: 13px;
          font-family: 'JetBrainsMono Nerd Font';
      }
      window#waybar {
          background: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: white;
      }

      tooltip {
          background: rgba(43, 48, 59, 0.5);
          border: 1px solid rgba(100, 114, 125, 0.5);
      }

      tooltip label {
          color: white;
      }

      #idle_inhibitor,
      #custom-ddcutil,
      #custom-shutdown {
          padding: 0 0;
          margin: 0 0;
          min-width: 2.5em;
      }

      #idle_inhibitor {
          background-color: #2d3436;
      }

      #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
      }

      #custom-ddcutil {
          background-color: #f1c40f;
          color: #000000;
          min-width: 4em;
      }

    '';
  };

  programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        settings = {
          icons = { name = "material-nf"; };
          theme = { name = "slick"; };
          block = [
            { block = "uptime"; }
            {
              block = "disk_space";
              path = "/";
              alias = "/";
              info_type = "available";
              unit = "GB";
              interval = 60;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "memory";
              display_type = "memory";
              format_mem = "{mem_used_percents}";
              format_swap = "{swap_used_percents}";
            }
            {
              block = "cpu";
              interval = 1;
            }
            {
              block = "temperature";
              collapsed = true;
              interval = 10;
              format = "{min} min, {max} max, {average} avg";
              warning = 90; # i7 11th gen is running kinda hot.
            }
            {
              block = "load";
              interval = 1;
              format = "{1m}";
            }
            { block = "sound"; }
            {
              block = "battery";
              interval = 10;
              format = "{percentage} {time}";
            }
            {
              block = "backlight";
              minimum = 15;
              maximum = 100;
              cycle = [ 100 75 50 25 0 25 50 75 ];
            }
            {
              block = "custom";
              command = ''
                swaymsg -t get_outputs | jq 'map(select(.name=="eDP-1")) | if .[0].active then {"text": "ON"} else {"text": "OFF"} end' '';
              on_click = "~/dotiles/bin/__sway_reset_outputs.sh";
              json = true;
            }
            {
              block = "networkmanager";
              on_click = "alacritty -e nmtui";
              interface_name_exclude = [ "br\\-[0-9a-f]{12}" "docker\\d+" ];
              interface_name_include = [ ];
              ap_format = "{ssid^10}";
            }
            {
              block = "time";
              interval = 60;
              format = "%a %d/%m %R";
            }
          ];
        };
      };
    };
  };
  programs.rofi = let
    # Use `mkLiteral` for string-like values that should show without
    # quotes, e.g.:
    # {
    #   foo = "abc"; => foo: "abc";
    #   bar = mkLiteral "abc"; => bar: abc;
    # };
    inherit (config.lib.formats.rasi) mkLiteral;
  in {
    enable = true;
    extraConfig = {
      modi = "drun,ssh,filebrowser";
      lines = 5;
      font = "JetBrainsMono Nerd Font 14";
      show-icons = true;
      icon-theme = "Papirus";
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 﩯  Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
    };
    theme = {
      "*" = {
        bg-col = mkLiteral "#1E1D2F";
        bg-col-light = mkLiteral "#1E1D2F";
        border-color = mkLiteral "#1E1D2F";
        selected-col = mkLiteral "#1E1D2F";
        blue = mkLiteral "#7aa2f7";
        grey = mkLiteral "#D9E0EE";
        fg-col = mkLiteral "#D9E0EE";
        fg-col2 = mkLiteral "#F28FAD";
        width = 600;
      };
      "element-text, element-icon, mode-switcher" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      window = {
        height = mkLiteral "360px";
        border = mkLiteral "3px";
        border-color = mkLiteral "@border-col";
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "0.1em";
      };

      mainbox = { background-color = mkLiteral "@bg-col"; };

      inputbar = {
        children = mkLiteral "[prompt,entry]";
        background-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "5px";
        padding = mkLiteral "2px";
      };

      prompt = {
        background-color = mkLiteral "@blue";
        padding = mkLiteral "6px";
        text-color = mkLiteral "@bg-col";
        border-radius = mkLiteral "3px";
        margin = mkLiteral "20px 0px 0px 20px";
      };

      textbox-prompt-colon = {
        expand = mkLiteral "false";
        str = ":";
      };

      entry = {
        padding = mkLiteral "6px";
        margin = mkLiteral "20px 0px 0px 10px";
        text-color = mkLiteral "@fg-col";
        background-color = mkLiteral "@bg-col";
      };

      listview = {
        border = mkLiteral "0px 0px 0px";
        padding = mkLiteral "6px 0px 0px";
        margin = mkLiteral "10px 0px 0px 20px";
        columns = mkLiteral "2";
        background-color = mkLiteral "@bg-col";
      };

      element = {
        padding = mkLiteral "5px";
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@fg-col";
      };

      element-icon = { size = mkLiteral "25px"; };

      "element selected" = {
        background-color = mkLiteral " @selected-col";
        text-color = mkLiteral "@fg-col2";
      };

      mode-switcher = { spacing = mkLiteral "0"; };

      button = {
        padding = mkLiteral "10px";
        background-color = mkLiteral "@bg-col-light";
        text-color = mkLiteral "@grey";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.5";
      };

      "button selected" = {
        background-color = mkLiteral "@bg-col";
        text-color = mkLiteral "@blue";
      };
    };
    terminal = "${pkgs.alacritty}/bin/alacritty";
  };
}