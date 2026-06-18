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
              (hl-line-mode -1)))

  ;; project.el のプロジェクトスイッチコマンドに追加
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)

  :bind
  ;; C-c C-g t : ghostel を開く
  ("C-c C-g t" . ghostel)
  ;; C-c C-g p : プロジェクトルートで ghostel を開く
  ("C-c C-g p" . ghostel-project))

(provide 'mk-ghostel)
