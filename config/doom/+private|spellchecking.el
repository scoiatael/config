;;; +private|spellchecking.el -*- lexical-binding: t; -*-

(use-package! jinx
  :hook ((emacs-startup . global-jinx-mode)))

(map!
 :n  "z="   #'jinx-correct
 ;; these error out for some reason?
 ;; :m  "[s"   #'jinx-correct-previous
 ;; :m  "]s"   #'jinx-correct-next
 )


(after! jinx
  (setq jinx-languages "en cs pl"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide '+private|spellchecking)
