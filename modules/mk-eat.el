;;; ============================================================
;;; eat（Emulate A Terminal）
;;; ============================================================

(use-package eat
  :straight (:type git :host codeberg :repo "akib/emacs-eat"
             :files ("*.el" ("term" "term/*.ti") "integration"))

  :custom
  ;; ターミナル名（xterm-256color 互換）
  (eat-term-name "xterm-256color")
  ;; ログインシェルで起動する（vterm と同様の理由）
  (eat-shell (concat shell-file-name " -l"))

  :hook
  ;; eshell 内で eat を使う場合のシェル統合
  (eshell-load . eat-eshell-mode)

  :config
  ;; global-display-line-numbers-mode の内部 turn-on 関数をアドバイス
  ;; hook の実行順序に依存せず、eat バッファへの有効化を根本から阻止する
  (with-eval-after-load 'display-line-numbers
    (advice-add 'display-line-numbers--turn-on :around
                (lambda (orig-fn)
                  (unless (derived-mode-p 'eat-mode)
                    (funcall orig-fn)))))

  ;; eat バッファの表示をターミナルに近づける
  (add-hook 'eat-mode-hook
            (lambda ()
              (display-line-numbers-mode -1) ; 行番号を無効化
              (hl-line-mode -1)              ; カーソル行ハイライトを無効化
              (setq-local cursor-in-non-selected-windows nil)
              ;; 日本語環境では曖昧幅文字が全角扱いになり TUI レイアウトが崩れるため
              ;; 罫線・記号・Nerd Font の Private Use Area を半角幅に固定する
              (dolist (range '((#x2500 . #x257F)   ; Box Drawing
                               (#x2580 . #x259F)   ; Block Elements
                               (#x25A0 . #x25FF)   ; Geometric Shapes
                               (#x2600 . #x26FF)   ; Miscellaneous Symbols
                               (#x2700 . #x27BF)   ; Dingbats
                               (#xE000 . #xF8FF))) ; Private Use Area (Nerd Fonts)
                (set-char-table-range char-width-table range 1)))))

(provide 'mk-eat)
