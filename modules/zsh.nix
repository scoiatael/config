{ config, lib, pkgs, ... }:

{
  # for emacsclient.sh
  home.packages = with pkgs; [ gnused coreutils-full ];
  programs.zsh = {
    enable = true;
    shellAliases = {
      hmr =
        "home-manager switch --flake 'path:${config.home.homeDirectory}/dotfiles'";
      nor =
        "doas nixos-rebuild switch --flake 'path:${config.home.homeDirectory}/dotfiles'";
      nix-test =
        "nix-build --keep-failed --expr 'with import <nixpkgs> {}; callPackage ./default.nix {}'";
    };
    shellGlobalAliases = { "..." = "../../"; };
    sessionVariables = {
      DOOMLOCALDIR = "$HOME/.emacs.local";
      LSP_USE_PLISTS = "true";
      EDITOR =
        "env PATH=${config.home.homeDirectory}/.nix-profile/bin ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/emacs/emacsclient.sh";
    };
    enableAutosuggestions = true;
    historySubstringSearch = { enable = true; };
    initExtra = lib.mkAfter ''
      autoload -U add-zsh-hook
      add-zsh-hook -Uz chpwd (){ print -Pn "\e]2;%m:%2~\a" }

      setopt PROMPT_SUBST
      PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

      path+=("$HOME/dotfiles/bin" "$HOME/.emacs.doom/bin")
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "tmux" "gpg-agent" "emacs" ];
      extraConfig = ''
        ZSH_TMUX_AUTOSTART=true
        ZSH_TMUX_CONFIG=~/.config/tmux/tmux.conf

        export TMUX_COLORTAG_TAG_ONLY=yes
        export TMUX_COLORTAG_USE_POWERLINE=yes
        export TMUX_COLORTAG_ROUNDED_POWERLINE=yes

        vterm_printf() {
            if [ -n "$TMUX" ] && ([ "$TERM" = "tmux" ] || [ "$TERM" = "screen" ]); then
                # Tell tmux to pass the escape sequences through
                printf "\ePtmux;\e\e]%s\007\e\\" "$1"
            elif [ "$TERM" = "screen" ]; then
                # GNU screen (screen, screen-256color, screen-256color-bce)
                printf "\eP\e]%s\007\e\\" "$1"
            else
                printf "\e]%s\e\\" "$1"
            fi
        }

        if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
            alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
        fi

        vterm_prompt_end() {
            vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
        }

        vterm_cmd() {
            local vterm_elisp
            vterm_elisp=""
            while [ $# -gt 0 ]; do
                vterm_elisp="$vterm_elisp""$(printf '"%s" ' "$(printf "%s" "$1" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
                shift
            done
            vterm_printf "51;E$vterm_elisp"
        }

        find_file() {
            vterm_cmd find-file "$(realpath "$@")"
        }

        say() {
            vterm_cmd message "%s" "$*"
        }
      '';
    };
    plugins = with pkgs; [
      {
        name = "forgit";
        src = zsh-forgit;
        file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
      }
      {
        name = "edit";
        src = zsh-edit;
        file = "share/zsh/zsh-edit/zsh-edit.plugin.zsh";
      }
      {
        name = "autopair";
        src = zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
      {
        name = "fzf-tab";
        src = zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "you-should-use";
        src = zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "syntax-hightlighing";
        src = zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];
  };
  programs.starship.enableZshIntegration = true;
}