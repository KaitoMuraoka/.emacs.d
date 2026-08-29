;;; ============================================================
;;; ghostel
;;; ============================================================

(use-package compat
  :straight t)

(use-package ghostel
  :straight (:type git :host github :repo "dakra/ghostel" :branch "main" :depth 1
             :files ("lisp/*.el"))

  :custom
  ;; プロセス終了時にバッファを自動で閉じる
  (ghostel-kill-buffer-on-exit t)
  ;; モジュールをリポジトリディレクトリに保存する
  ;; 理由: straight.el はリビルド時に build/ を再作成するため
  ;;       build/ 内のモジュールが消える。repos/ は stable なので残る。
  (ghostel-module-directory
   (expand-file-name "straight/repos/ghostel" user-emacs-directory))

  :config
  ;; ログインシェル起動ラッパーを作成して ghostel-shell に設定する。
  ;; 理由: ghostel-shell は引数を取らないため "-l" を直接渡せない。
  ;;       exec -a -zsh とすることで argv[0] を "-zsh" にし、
  ;;       zsh をログインシェルとして起動する（.zprofile も読み込まれる）。
  ;;       スクリプト名に "zsh" を含めることで ghostel のシェル検出にも一致する。
  (let* ((wrapper (expand-file-name "ghostel-zsh" user-emacs-directory)))
    (with-temp-file wrapper
      (insert "#!/bin/bash\nexec -a -zsh /bin/zsh\n"))
    (set-file-modes wrapper #o755)
    (setq ghostel-shell wrapper))

  ;; straight.el は etc/ を build/ にコピーしないため、シンボリックリンクで代替する。
  ;; リビルド後に空の etc/ ディレクトリが作られた場合でも対応するため
  ;; 普通のディレクトリなら削除してからリンクを張る。
  (let* ((build-dir (file-name-directory (locate-library "ghostel")))
         (link (expand-file-name "etc" build-dir))
         (target (expand-file-name "straight/repos/ghostel/etc" user-emacs-directory)))
    (unless (file-symlink-p link)
      (when (file-directory-p link)
        (delete-directory link))
      (make-symbolic-link target link)))

  (add-hook 'ghostel-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)
              (hl-line-mode -1)
              ;; visual-line-mode を明示的に切ることで set-explicitly を立て、
              ;; globalized 版が有効でもこのバッファを対象外にする。
              ;; 無効化時に truncate-lines のローカル値が消えるため後から張り直す。
              (visual-line-mode -1)
              (setq-local truncate-lines t)
              (setq-local word-wrap nil)))

  ;; project.el のプロジェクトスイッチコマンドに追加
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)

  ;; ghostel 内でも C-h を削除キーとして使えるようにする。
  ;; 理由: ghostel-keymap-exceptions のデフォルトに "C-h" が含まれており、
  ;;       C-h が端末に送られずグローバルの delete-backward-char が走るため、
  ;;       バッファ直接編集が redraw で巻き戻されて削除できない。
  ;;       ctrl+h (0x08) ではなく Backspace (0x7f) を送ることで、
  ;;       zsh でも TUI アプリでも確実に1文字削除になる。
  (defun mk-ghostel-send-backspace ()
    "ghostel の端末に Backspace (0x7f) を送る。"
    (interactive)
    (ghostel-send-key "backspace"))

  (define-key ghostel-semi-char-mode-map (kbd "C-h") #'mk-ghostel-send-backspace)

  :bind
  ;; C-c C-g t : ghostel を開く
  ("C-c C-g t" . ghostel)
  ;; C-c C-g p : プロジェクトルートで ghostel を開く
  ("C-c C-g p" . ghostel-project))

(provide 'mk-ghostel)
