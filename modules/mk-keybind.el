;; -*- lexical-binding: t; -*-
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

;; macOS: Cmd+クリックで定義へジャンプ
(global-set-key [s-mouse-1] #'xref-find-definitions-at-mouse)

;; MarkのキーバインドをEmacsデフォルトに戻す
(global-set-key (kbd "C-;") #'set-mark-command)

;; C-h を削除キー（バックスペース相当）に変更する
;; 理由: ターミナル環境でバックスペースが C-h として送られることが多く、
;;       直感的な操作に合わせる
;; ヘルプは C-? で引き続き使用可能
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key (kbd "C-?") 'help-command)

;; 日本語入力（Quail/KKC）の変換中も C-h を DEL と同じ動作にする
(with-eval-after-load 'quail
  (define-key quail-translation-keymap "\C-h" #'quail-delete-last-char)
  (define-key quail-conversion-keymap "\C-h" #'quail-conversion-backward-delete-char))
(with-eval-after-load 'kkc
  (define-key kkc-keymap "\C-h" #'kkc-cancel))
;; 日本語入力（Quail）で "nn" を「ん」にする
(setq quail-japanese-use-double-n t)

(provide 'mk-keybind)
