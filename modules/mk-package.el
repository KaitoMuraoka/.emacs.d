;;; mk-package.el --- -*- lexical-binding: t -*-

;; パッケージリポジトリに MELPA を追加
(use-package package
  :custom
  (package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                      ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                      ("melpa"  . "https://melpa.org/packages/"))))

(provide 'mk-package)
;;; mk-package.el ends here
