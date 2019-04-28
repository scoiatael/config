(add-hook 'ruby-mode-hook
          (lambda () (hs-minor-mode)))

(eval-after-load "hideshow"
  '(add-to-list 'hs-special-modes-alist
                `(ruby-mode
                  ,(rx (or "def" "class" "module" "{" "[" "do")) ; Block start
                  ,(rx (or "}" "]" "end"))                  ; Block end
                  ,(rx (or "#" "=begin"))                   ; Comment start
                  nil
                  nil)))

(setq ruby-insert-encoding-magic-comment nil)

(eval-after-load "rubocop" '(diminish 'rubocop-mode "🅡"))

(setq feature-default-language "fi")
