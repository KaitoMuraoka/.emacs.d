;;; mk-package.el --- -*- lexical-binding: t -*-

(require 'package) ; package.elを有効化
;; パッケージリポジトリにMELPAを追加
(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/"))
(package-initialize) ; インストール済みのElispを読み込む

(provide 'mk-package)
;;; mk-package.el ends here
