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

(require 'shr)

(defun my/markdown-preview ()
  "現在のバッファの Markdown を shr で描画する。一時ファイルは作らない。"
  (interactive)
  (let* ((src (current-buffer))
         (dom (with-temp-buffer
                (let ((html-buf (current-buffer)))
                  (with-current-buffer src
                    (call-process-region (point-min) (point-max) "pandoc"
                                         nil html-buf nil
                                         "--from=gfm" "--to=html5")))
                (libxml-parse-html-region (point-min) (point-max)))))
    (with-current-buffer (get-buffer-create "*markdown preview*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (shr-insert-document dom))
      (goto-char (point-min))
      (special-mode))
    (display-buffer "*markdown preview*")))

(defun my/markdown-preview-update ()
  (when (get-buffer-window "*markdown preview*" t)
    (let* ((win (get-buffer-window "*markdown preview*" t))
           (start (window-start win))
           (pt (window-point win)))
      (my/markdown-preview)
      (set-window-start win start)
      (set-window-point win (min pt (point-max))))))

(add-hook 'markdown-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'my/markdown-preview-update nil t)))

(provide 'mk-markdown)
