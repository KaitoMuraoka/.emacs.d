;;; init.el --- -*- lexical-binding: t -*- ;; Emacs 30 からは、このクッキーがない elisp ファイルを読み込むと警告が出る。
(add-to-list 'load-path (locate-user-emacs-file "modules"))

;; customize の書き込みを init.el に混ぜないよう、使い捨ての一時ファイルに逃がす
(setq custom-file (make-temp-file "emacs-custom-" nil ".el"))
(require 'mk-package)
(require 'mk-base)
(require 'mk-keybind)
(require 'mk-view)
(require 'mk-auto-complete)
(require 'mk-git)
(require 'mk-which-key)
(require 'mk-vertico)
