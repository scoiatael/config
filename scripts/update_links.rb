#!/usr/bin/env ruby

require_relative 'lib/linker'

Linker.create! do
  link 'config/fish', to: 'fish'

  group 'rvm' do
    link 'rvmrc'
    link 'rvm/gemsets/default.gems', to: "#{current_group}/default.gems"
  end

  group 'git' do
    link 'gitconfig'
    link 'gitignore_global', to: "#{current_group}/gitignore"
  end

  group 'node' do
    link 'local/package.json', to: "#{current_group}/package.json"
  end

  group 'misc' do
    links %w(dir_colors curlrc slate)

    link 'lein/profiles.clj', to: "#{current_group}/lein_profiles.clj"
  end

  group 'haskell' do
    link 'xmonad/xmonad.hs', to: "#{current_group}/xmonad.hs"
    link 'stack/config.yml', to: "#{current_group}/stack.yml"
  end

  group 'emacs' do
    link 'emacs.d', to: "#{current_group}/spacemacs.d"
    link 'spacemacs'
  end
end
