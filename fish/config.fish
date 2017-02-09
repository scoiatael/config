function _scoiatael_fish_init
	set -U fish_greeting ""
	set -U fish_key_bindings fish_vi_key_bindings
	function fish_mode_prompt; end

	for file in ~/.config/fish/conf.d/*.fish
	    source $file
	end

	alias vi=vim
	alias pacman=yaourt
	alias em='emacsclient -nw -s console-edit -a \'\''
	alias emg='open -a Emacs'
	python -m virtualfish auto_activation compat_aliases | source

	function random;
	  set -l length $argv[1]
	  if test -z $length;
	    set -l length 10
	  end
	  ruby -e "puts (('a'..'z').to_a + (0..9).to_a).sample($length).join('')"
	end

	set -l iterm_integration $HOME/.iterm2_shell_integration.fish
	if test -f $iterm_integration
	  source $iterm_integration
	end

	set PATH $PATH /usr/local/opt/go/libexec/bin
	set EDITOR em

	set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
	set -g fish_user_paths "$HOME/.local/bin" $fish_user_paths
	set -g fish_user_paths "$HOME/Library/Python/2.7/bin" $fish_user_paths

	test -e ~/.cargo/env; and bass source ~/.cargo/env

	which envoy; and envoy -p | source
	ssh-add -l | grep -v 'no identities'; or ssh-add -A; or ssh-add
	which thefuck; and thefuck --alias | source > /dev/null

	which nvim; and alias vim nvim
end

_scoiatael_fish_init > /dev/null
