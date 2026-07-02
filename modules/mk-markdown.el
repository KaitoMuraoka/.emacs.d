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

(defun mk-markdown--heading-face-on-line (beg end)
  "BEG から END の間にある見出しフェイス (markdown-header-face-N) を返す。"
  (let ((pos beg) result)
    (while (and (not result) (< pos end))
      (let ((face (get-text-property pos 'face)))
        (dolist (f (ensure-list face))
          (when (and (symbolp f)
                     (string-match-p "\\`markdown-header-face-[1-6]\\'"
                                     (symbol-name f)))
            (setq result f))))
      (setq pos (or (next-single-property-change pos 'face nil end) end)))
    result))

(defun mk-markdown--scale-heading-delimiter (beg end)
  "BEG から END の見出し記号 # に見出しフェイスを重ね、文字サイズを揃える。"
  (let ((header-face (mk-markdown--heading-face-on-line beg end)))
    (when header-face
      (let ((pos beg))
        (while (< pos end)
          (let ((next (or (next-single-property-change pos 'face nil end) end))
                (face (get-text-property pos 'face)))
            (when (memq 'markdown-header-delimiter-face (ensure-list face))
              (put-text-property pos next 'face
                                 (list 'markdown-header-delimiter-face header-face)))
            (setq pos next)))))))

(defun mk-markdown--reveal-region ()
  "reveal 対象の範囲 (BEG . END) を返す。
コードブロック内ではフェンス行が行ごと invisible になりカーソルを
置けないため、ブロック全体を対象にする。それ以外は現在行。"
  (let ((block (markdown-code-block-at-pos (point))))
    (if block
        (cons (car block) (min (cadr block) (point-max)))
      (cons (line-beginning-position) (line-end-position)))))

(defun mk-markdown--reveal-markup-at-point ()
  "カーソル位置の Markdown 記号を一時的に表示する。
その場所を離れたら font-lock による再フォント化で隠し直す。"
  (when markdown-hide-markup
    (pcase-let ((`(,beg . ,end) (mk-markdown--reveal-region)))
      ;; 前に表示していた範囲から離れたら隠し直す
      (when (and mk-markdown--revealed-extent
                 (or (<= end (car mk-markdown--revealed-extent))
                     (>= beg (cdr mk-markdown--revealed-extent))))
        (font-lock-flush (car mk-markdown--revealed-extent)
                         (cdr mk-markdown--revealed-extent))
        (setq mk-markdown--revealed-extent nil))
      ;; 現在行に隠れた記号があれば表示する
      (when (mk-markdown--hidden-markup-p beg end)
        (with-silent-modifications
          (remove-text-properties beg end '(invisible nil))
          (mk-markdown--remove-empty-display beg end)
          (mk-markdown--scale-heading-delimiter beg end))
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
  (markdown-list-item-bullets '("●" "○" "■")) ; リストを Unicode バレットで表示
  :config
  ;; コードブロックの範囲を背景色で示す(render-markdown.nvim 風)
  (require 'color)
  (when-let* ((bg (face-background 'default nil t))
              (rgb (color-name-to-rgb bg)))
    (set-face-attribute 'markdown-code-face nil
                        :background (if (color-dark-p rgb)
                                        (color-lighten-name bg 10)
                                      (color-darken-name bg 8))
                        :extend t)))

(provide 'mk-markdown)
