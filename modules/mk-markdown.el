;;; ============================================================
;;; markdown-mode
;;; ============================================================
(defvar-local mk-markdown--revealed-extent nil
  "現在記号を再表示している行の範囲 (BEG-MARKER . END-MARKER)。")

(defun mk-markdown--hidden-markup-p (beg end)
  "BEG から END の間に隠された Markdown 記号があるか。
強調・リンク等は invisible、見出しの # は display \"\" で隠される。"
  (or (text-property-any beg end 'invisible 'markdown-markup)
      (let ((pos beg) found)
        (while (and (not found) (< pos end))
          (when (equal (get-text-property pos 'display) "")
            (setq found t))
          (setq pos (or (next-single-property-change pos 'display nil end) end)))
        found)))

(defun mk-markdown--remove-empty-display (beg end)
  "BEG から END の display \"\" プロパティのみ除去する。
インライン画像などの display プロパティは対象にしない。"
  (let ((pos beg))
    (while (< pos end)
      (let ((next (or (next-single-property-change pos 'display nil end) end)))
        (when (equal (get-text-property pos 'display) "")
          (remove-text-properties pos next '(display nil)))
        (setq pos next)))))

(defun mk-markdown--reveal-markup-at-point ()
  "カーソル行の Markdown 記号を一時的に表示する。
行を離れたら font-lock による再フォント化で隠し直す。"
  (when markdown-hide-markup
    (let ((beg (line-beginning-position))
          (end (line-end-position)))
      ;; 前に表示していた行から離れたら隠し直す
      (when (and mk-markdown--revealed-extent
                 (or (< end (car mk-markdown--revealed-extent))
                     (> beg (cdr mk-markdown--revealed-extent))))
        (font-lock-flush (car mk-markdown--revealed-extent)
                         (cdr mk-markdown--revealed-extent))
        (setq mk-markdown--revealed-extent nil))
      ;; 現在行に隠れた記号があれば表示する
      (when (mk-markdown--hidden-markup-p beg end)
        (with-silent-modifications
          (remove-text-properties beg end '(invisible nil))
          (mk-markdown--remove-empty-display beg end))
        (setq mk-markdown--revealed-extent
              (cons (copy-marker beg) (copy-marker end)))))))

(defun mk-markdown--setup-reveal ()
  (add-hook 'post-command-hook #'mk-markdown--reveal-markup-at-point nil t))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode))
  :hook (markdown-mode . mk-markdown--setup-reveal)
  :custom
  ;; render-markdown.nvim 相当のバッファ内装飾
  (markdown-hide-markup t)                      ; 強調・リンク等の記号を隠す
  (markdown-header-scaling t)                   ; 見出しをレベル別に拡大表示
  (markdown-fontify-code-blocks-natively t)     ; コードブロックを言語別にハイライト
  (markdown-list-item-bullets '("●" "○" "■"))) ; リストを Unicode バレットで表示

(provide 'mk-markdown)
