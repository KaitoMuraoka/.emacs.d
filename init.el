;;; init.el --- -*- lexical-binding: t -*- ;; Emacs 30 からは、このクッキーがない elisp ファイルを読み込むと警告が出る。
(add-to-list 'load-path (locate-user-emacs-file "modules"))

;; カスタムファイルを別ファイルにする
(setq custom-file (locate-user-emacs-file "custom.el"))

;; (カスタムファイルが存在しない場合は作成する
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))

;; カスタムファイルを読み込む
(load custom-file)
(require 'backup)
(require 'emacs-frame)
(require 'indentation)
(require 'keybind)
(require 'os)
(require 'package-manager)
