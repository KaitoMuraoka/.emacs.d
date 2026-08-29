;;; ============================================================
;;; markdown-mode
;;; ============================================================
(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode))
  :custom
  (markdown-hide-markup nil)                    ; 記号を隠さず生の Markdown を表示
  (markdown-header-scaling nil)                 ; 見出しの文字サイズは変えない
  (markdown-fontify-code-blocks-natively t))    ; コードブロックを言語別にハイライト

(provide 'mk-markdown)
