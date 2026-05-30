;;; ============================================================
;;; 言語モード
;;; ============================================================

;; Swift サポート
;; swift-mode は MELPA から提供
(use-package swift-mode)

;; TypeScript サポート
(use-package typescript-mode
  :mode ("\\.ts\\'" . typescript-mode)
  :mode ("\\.tsx\\'" . tsx-ts-mode))

;; Ruby サポート
;; ruby-ts-mode は Emacs 30 組み込みの tree-sitter ベースのモード
;; （grammar libtree-sitter-ruby は導入済み）
;; .rb のほか Gemfile / Rakefile などの拡張子なしファイルも対象にする
(use-package ruby-ts-mode
  :straight (:type built-in)
  :mode ("\\.rb\\'" "\\.rake\\'" "\\.gemspec\\'" "\\.ru\\'"
         "/\\(?:Gem\\|Cap\\|Guard\\|Rake\\|Brew\\|Berks\\|Vagrant\\|Pod\\)file\\'")
  :init
  ;; 旧 ruby-mode が呼ばれても ruby-ts-mode に置き換える
  (add-to-list 'major-mode-remap-alist '(ruby-mode . ruby-ts-mode)))

;; ERB テンプレートサポート
;; web-mode は HTML に埋め込まれた Ruby（<%= %>）を適切にハイライトする
(use-package web-mode
  :mode ("\\.erb\\'" "\\.html\\.erb\\'"))

;; YAML サポート
;; config/database.yml など Rails の設定ファイル用
;; yaml-mode は MELPA 提供で tree-sitter grammar 不要
(use-package yaml-mode
  :mode ("\\.ya?ml\\'"))

(provide 'mk-language-mode)
