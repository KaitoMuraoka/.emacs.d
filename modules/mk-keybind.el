;;; ============================================================
;;; プロジェクト管理
;;; ============================================================

;; project.el は Emacs 組み込み
;; Git リポジトリをプロジェクトとして認識し
;; プロジェクト内のファイル検索などができる
(global-set-key (kbd "C-c p f") #'project-find-file)
(global-set-key (kbd "C-c p b") #'project-switch-to-buffer)


;;; ============================================================
;;; よく使うキーバインド
;;; ============================================================

;; バッファの切り替えを便利に
(global-set-key (kbd "C-c b") #'switch-to-buffer)

;; ウィンドウ移動
(global-set-key (kbd "M-o") #'other-window)

;; macOS: Cmd+V でペースト
(global-set-key (kbd "s-v") #'yank)

;; IME切り替えとMarkのキーバインドをEmacsデフォルトに戻す
(global-set-key (kbd "C-SPC")  #'toggle-input-method)
(global-set-key (kbd "C-\\") #'set-mark-command)

;; C-x C-j で Emacs 内蔵の日本語入力（toggle-input-method）を切り替える
(global-set-key (kbd "C-x C-j") #'toggle-input-method)

;; C-h を削除キー（バックスペース相当）に変更する
;; 理由: ターミナル環境でバックスペースが C-h として送られることが多く、
;;       直感的な操作に合わせる
;; ヘルプは C-? で引き続き使用可能
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key (kbd "C-?") 'help-command)

;; 日本語入力（内蔵 quail / kkc）の変換中も C-h をバックスペースとして扱う
;; 既定では C-h がヘルプ（kkc-help / quail-translation-help）に割り当てられており、
;; グローバルの C-h（delete-backward-char）と挙動が食い違うため、各文脈の
;; バックスペースキー（DEL）と同じコマンドに統一する
(with-eval-after-load 'kkc
  (define-key kkc-keymap (kbd "C-h") #'kkc-cancel))
(with-eval-after-load 'quail
  (define-key quail-translation-keymap (kbd "C-h") #'quail-delete-last-char)
  (define-key quail-conversion-keymap (kbd "C-h") #'quail-conversion-backward-delete-char))

(provide 'mk-keybind)
