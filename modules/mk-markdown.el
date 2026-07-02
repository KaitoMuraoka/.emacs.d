;;; ============================================================
;;; markdown-mode
;;; ============================================================
(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode))
  :custom
  ;; render-markdown.nvim 相当のバッファ内装飾
  (markdown-hide-markup t)                      ; 強調・リンク等の記号を隠す
  (markdown-header-scaling t)                   ; 見出しをレベル別に拡大表示
  (markdown-fontify-code-blocks-natively t)     ; コードブロックを言語別にハイライト
  (markdown-list-item-bullets '("●" "○" "■"))) ; リストを Unicode バレットで表示

(provide 'mk-markdown)
