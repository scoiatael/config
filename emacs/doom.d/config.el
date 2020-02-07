;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!

(setq doom-localleader-key ",")

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Lukasz Czaplinski"
      user-mail-address "lczaplinski@opera.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "FuraMono Nerd Font" :size 12))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-one)

;; If you intend to use org, it is recommended you change this!
(setq org-directory "~/org/")

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

(map! :leader
      "c x" #'lsp-treemacs-errors-list
      "f d" #'dired-jump
      "/"   #'scoiatael/helm-rg-project
      "s c" #'evil-ex-nohighlight
      "w 2" #'split-window-below
      "w 3" #'split-window-right
      "a k" #'helm-show-kill-ring)

(map! :after python
      :map python-mode-map
      :localleader
      :prefix "d"
      :desc "Start debugging" "d" #'dap-debug
      :desc "Debugger hydra" "h" #'dap-hydra
      :desc "Debugger REPL" "r" #'dap-ui-repl
      :desc "Stop debugger" "q" #'dap-delete-all-sessions
      :prefix "i"
      :desc "Remove obsolete imports" "d" #'scoiatael/python-remove-unused-imports)

(use-package! evil-surround
  :config
    (global-evil-surround-mode 1))

(after! swiper
  (define-key swiper-map (kbd "ESC") #'keyboard-quit)
  (define-key swiper-map (kbd "C-j") #'ivy-next-line)
  (define-key swiper-map (kbd "C-k") #'ivy-previous-line))

;;; :lang org
(setq org-directory "~/iCloud/org/"
      org-archive-location (concat org-directory "archive/%s::")
      org-ellipsis " ▼ "
      org-bullets-bullet-list '("☰" "☱" "☲" "☳" "☴" "☵" "☶" "☷" "☷" "☷" "☷"))

(add-hook! 'org-load-hook
           #'scoiatael/set-org-todo-keywords)

(after! org
  (add-to-list 'org-modules 'org-habit t))

(setq magit-repository-directories '(("~/Documents" . 2))
      magit-save-repository-buffers nil
      ;; Don't restore the wconf after quitting magit
      magit-inhibit-save-previous-winconf t
      transient-values '((magit-commit "--gpg-sign=DEB2867E60E7593C4C3EE576AD53A88A3E2D87BC")
                         (magit-rebase "--autosquash" "--gpg-sign=DEB2867E60E7593C4C3EE576AD53A88A3E2D87BC")
                         (magit-pull "--rebase" "--gpg-sign=DEB2867E60E7593C4C3EE576AD53A88A3E2D87BC")))

(after! direnv
   (advice-add 'python-mode :before #'direnv-update-environment))

(map!
 :map puppet-mode-map
 :after puppet-mode
 :localleader
 :desc "Align block" "b" #'puppet-align-block
 :desc "Align class params" "p" #'scoiatael/puppet-align-parameters
 :desc "Toggle string quotes" "'" #'puppet-toggle-string-quotes)

(map!
 :map org-mode-map
 :localleader
 :desc "Insert date" "d" #'org-time-stamp)

(map!
 :map direnv-envrc-mode-map
 :after direnv
 :localleader
 :desc "Allow envrc" "a" #'direnv-allow)

(use-package! dap-mode
  :after lsp-mode
  :preface
  (setq dap-breakpoints-file (concat doom-etc-dir "dap-breakpoints")
        dap-utils-extension-path (concat doom-etc-dir "dap-extension/"))
  :config
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (tooltip-mode 1)
  (require 'dap-python)
  (require 'dapui)
  ;; (dap-register-debug-template
  ;;  "Python :: pytest focused"
  ;;  (list :type "python"
  ;;        :args "-m focus -s"
  ;;        :cwd nil
  ;;        :program nil
  ;;        :module "pytest"
  ;;        :request "launch"
  ;;        :name "Python :: pytest focused"))
  ;; (add-hook 'dap-stopped-hook
  ;;           (lambda (_arg) (call-interactively #'dap-hydra)))
  (add-hook 'dap-stopped-hook
            (lambda (_arg) (call-interactively #'dap-ui-repl)))
  )

(setq safe-local-variable-values
      '((flycheck-puppet-lint-executable . "/Users/opera_user/Documents/puppet/.direnv/ruby/bin/puppet-lint")
        (flycheck-puppet-parser-executable . "/Users/opera_user/Documents/puppet/.direnv/ruby/bin/puppet")))

(setq desktop-restore-eager 3)