;;; ============================================================
;;; markdown-mode
;;; ============================================================
(defvar mk-markdown-heading-markers '("① " "② " "③ " "④ " "⑤ " "⑥ ")
  "見出しレベル 1〜6 の # の代わりに表示する記号。")

(defvar-local mk-markdown--revealed-extent nil
  "現在記号を再表示している行の範囲 (BEG-MARKER . END-MARKER)。")

(defun mk-markdown--hidden-display-p (value)
  "display プロパティ VALUE が記号を隠すためのものか。
見出しの # は丸数字、それ以外の記号は \"\" に置き換えられる。"
  (or (equal value "")
      (and (stringp value) (member value mk-markdown-heading-markers) t)))

(defun mk-markdown--hidden-markup-p (beg end)
  "BEG から END の間に隠された Markdown 記号があるか。
強調・リンク等は invisible、見出しの # は display で置き換えられる。"
  (or (text-property-any beg end 'invisible 'markdown-markup)
      (let ((pos beg) found)
        (while (and (not found) (< pos end))
          (when (mk-markdown--hidden-display-p (get-text-property pos 'display))
            (setq found t))
          (setq pos (or (next-single-property-change pos 'display nil end) end)))
        found)))

(defun mk-markdown--remove-hidden-display (beg end)
  "BEG から END の記号を隠す display プロパティのみ除去する。
インライン画像などの display プロパティは対象にしない。"
  (let ((pos beg))
    (while (< pos end)
      (let ((next (or (next-single-property-change pos 'display nil end) end)))
        (when (mk-markdown--hidden-display-p (get-text-property pos 'display))
          (remove-text-properties pos next '(display nil)))
        (setq pos next)))))

(defun mk-markdown--number-heading-markup (fn last)
  "`markdown-fontify-headings' の後で atx 見出しの # を丸数字に差し替える。"
  (let ((result (funcall fn last)))
    (when (and result markdown-hide-markup (match-beginning 4))
      (let* ((beg (match-beginning 4))
             (end (match-end 4))
             (level (save-excursion (goto-char beg) (skip-chars-forward "#")))
             (marker (nth (1- level) mk-markdown-heading-markers)))
        (when marker
          (put-text-property beg end 'display marker))))
    result))

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
その場所を離れたら font-lock による再フォント化で隠し直す。
エラー時は demote し、post-command-hook から自動除去されるのを防ぐ。"
  (with-demoted-errors "mk-markdown reveal error: %S"
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
            (mk-markdown--remove-hidden-display beg end))
          (setq mk-markdown--revealed-extent
                (cons (copy-marker beg) (copy-marker end))))))))

(defvar mk-markdown--reveal-timer nil
  "reveal を再実行するアイドルタイマー。")

(defun mk-markdown--reveal-on-idle ()
  "アイドル時に reveal を再実行する。
jit-lock のフォント化は post-command-hook より後(再描画時)に走るため、
未フォント化領域へのカーソル移動時に記号が隠し直される。ここで回復する。"
  (when (derived-mode-p 'markdown-mode)
    (mk-markdown--reveal-markup-at-point)))

(defun mk-markdown--setup-reveal ()
  (add-hook 'post-command-hook #'mk-markdown--reveal-markup-at-point nil t)
  (unless mk-markdown--reveal-timer
    (setq mk-markdown--reveal-timer
          (run-with-idle-timer 0.15 t #'mk-markdown--reveal-on-idle))))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode))
  :hook (markdown-mode . mk-markdown--setup-reveal)
  :custom
  ;; render-markdown.nvim 相当のバッファ内装飾
  (markdown-hide-markup t)                      ; 強調・リンク等の記号を隠す
  (markdown-header-scaling nil)                 ; 見出しの文字サイズは変えない
  (markdown-fontify-code-blocks-natively t)     ; コードブロックを言語別にハイライト
  (markdown-list-item-bullets '("●" "○" "■")) ; リストを Unicode バレットで表示
  :config
  ;; 見出しの # をレベル別の丸数字で表示する
  (advice-add 'markdown-fontify-headings :around #'mk-markdown--number-heading-markup)
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
