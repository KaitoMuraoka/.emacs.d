;;; ============================================================
;;; Ruby / Rails 言語モード
;;; ============================================================
(require 'treesit)
;; .rb / Gemfile / Rakefile / Capfile / config.ru などを ruby-ts-mode に振る

(add-to-list 'auto-mode-alist '("\\.rb\\'"      . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("\\.rake\\'"    . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("/Gemfile\\'"   . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("/Rakefile\\'"  . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("/Capfile\\'"   . ruby-ts-mode))
(add-to-list 'auto-mode-alist '("/config\\.ru\\'" . ruby-ts-mode))

;; Tree-sitter の言語ソース定義
(add-to-list 'treesit-language-source-alist
             '(ruby "https://github.com/tree-sitter/tree-sitter-ruby"))

;; web-mode
(use-package web-mode
  :mode (("\\.erb\\'" . web-mode)
         ("\\.html\\.erb\\'" . web-mode))
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-engines-alist '(("erb" . "\\.erb\\'"))))

(provide 'mk-ruby)

