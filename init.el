
;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Naoya Yamashita

;; Author: Naoya Yamashita <conao3@gmail.com>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My init.el.

;;; Code:

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/init.el
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))
;; 日本語設定
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-file-coding-system 'utf-8)
(setq org-startup-truncated nil);; org-modeの折り返しを有効
;;(global-hl-line-mode +1) ;; 現在行を強調
(global-display-line-numbers-mode +1) ;; 左側に行番号を表示する
;;(setq display-line-numbers-type 'relative) ;; 現在の行の相対行
(electric-pair-mode +1) ;; 括弧を補完する
(setq inhibit-startup-message t) ;; 起動時のWelcomeメッセージを非表示
(set-face-attribute 'default nil :height 160) ;; フォントサイズを 14pt に設定
(setq auto-save-default nil);; 自動保存を無効化する
(setq make-backup-files nil);; バックアップファイルを作成しない
(setq ring-bell-function 'ignore);; ピープ音とフラッシュをOFF
;;(setq initial-major-mode 'org-mode) ;; Eacs 起動時に scratch バッファをorg-modeにする

(global-set-key (kbd "C-c C-b") 'byte-compile-file)

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; カレンダーから選択した日時をプットする
(defun my/insert-date-at-point ()
  "Minibufferで日付を選択し、カーソル位置に `YYYY/MM/DD DOW` フォーマットで挿入する。"
  (interactive)
  (let* ((system-time-locale "ja_JP.utf8")
         (date (org-read-date nil nil nil "日付を選択してください:")))
    (insert (format "%04d年%d月%d日(%s)"
                    (string-to-number (format-time-string "%Y" (org-time-string-to-time date)))
                    (string-to-number (format-time-string "%m" (org-time-string-to-time date)))
                    (string-to-number (format-time-string "%d" (org-time-string-to-time date)))
                    (format-time-string "%a" (org-time-string-to-time date)))))
  )

;; ここにいっぱい設定を書く

;;Emacs入門から始めるleaf.el入門より
(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))
(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

;;evil
(defun my-evil-line-numbers ()
  "Evilモード時は相対行番号、Emacsモード時は絶対行番号に切り替える"
  (setq display-line-numbers-type
        (if (evil-emacs-state-p) 'absolute 'relative))
  (display-line-numbers-mode t))

;; Evilのモード切り替え時にフックを設定
(add-hook 'evil-normal-state-entry-hook #'my-evil-line-numbers)
(add-hook 'evil-visual-state-entry-hook #'my-evil-line-numbers)
(add-hook 'evil-insert-state-entry-hook #'my-evil-line-numbers)
(add-hook 'evil-replace-state-entry-hook #'my-evil-line-numbers)
(add-hook 'evil-emacs-state-entry-hook #'my-evil-line-numbers)

;; 最初にEvilが起動したときも適用
(add-hook 'evil-mode-hook #'my-evil-line-numbers)

(use-package evil
  :ensure t
  :custom
  (evil-want-C-u-scroll t)
  (evil-toggle-key "")
  (display-line-numbers-type 'relative)
  :config
  (evil-mode t)
  )

(dolist (mode '(org-mode markdown-mode text-mode))
  (add-to-list 'evil-emacs-state-modes mode))

;; カラーテーマを設定する
(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi t))

;; magit: Emacs上でGitを操作する
(leaf magit
  :when (version<= "25.1" emacs-version)
  :ensure t
  :preface
  (defun c/git-commit-a ()
    "Commit after add anything."
    (interactive)
    (shell-command "git add .")
    (magit-commit-create))
  :bind (("M-=" . hydra-magit/body))
  :hydra (hydra-magit
          (:hint nil :exit t)
          "
^^         hydra-magit
^^------------------------------
 _s_   magit-status
 _C_   magit-clone
 _c_   magit-commit
 _d_   magit-diff-working-tree
 _M-=_ magit-commit-create"
          ("s" magit-status)
          ("C" magit-clone)
          ("c" magit-commit)
          ("d" magit-diff-working-tree)
          ("M-=" c/git-commit-a)))

;; dired-sidebar
(leaf dired-sidebar
  :ensure t
  :bind ("C-q" . dired-sidebar-toggle-sidebar)
  :custom ((dired-sidebar-theme . 'nerd)))

;; Show Git branch information to mode-line
(let ((cell (or (memq 'mode-line-position mode-line-format)
		(memq 'mode-line-buffer-identification mode-line-format)))
      (newcdr '(:eval (my/update-git-branch-mode-line))))
  (unless (member newcdr mode-line-format)
    (setcdr cell (cons newcdr (cdr cell)))))

(defun my/update-git-branch-mode-line ()
  (let* ((branch (replace-regexp-in-string
                  "[\r\n]+\\'" ""
                  (shell-command-to-string "git symbolic-ref -q HEAD")))
         (mode-line-str (if (string-match "^refs/heads/" branch)
                            (format "[%s]" (substring branch 11))
                          "[Not Repo]")))
    (propertize mode-line-str
                'face '((:foreground "white" :weight bold)))))

;; 名前をつけずに新規作成(https://qiita.com/tadsan/items/4ad2e5e3114fff172b6a)
(defun my/new-untitled-buffer ()
  "Create and switch to untitled buffer."
  (interactive)
  (switch-to-buffer (generate-new-buffer "Untitled")))
;; Alt+Shift+N に割り当てる
(global-set-key (kbd "M-N") 'my/new-untitled-buffer)

;; open-junk-file
(use-package open-junk-file
  :ensure t
  :bind (("C-x j" . open-junk-file))
  :config
  (setq open-junk-file-format "~/junk/%Y_%m_%d_%H%M%S.")) ;; 作成したファイルの場所とファイル名を設置

;; autorevert
(leaf autorevert
  :doc "revert buffers when files on disk change"
  :tag "builtin"
  :custom ((auto-revert-interval . 1))
  :global-minor-mode global-auto-revert-mode)

;;paren 対応するカッコを強調
(leaf paren
  :doc "highlight matching paren"
  :tag "builtin"
  :custom ((show-paren-delay . 0.1))
  :global-minor-mode show-paren-mode)

;; flycheck-リアルタイムにソースのエラーやワーニングを表示
(leaf flycheck
  :doc "On-the-fly syntax checking"
  :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
  :tag "minor-mode" "tools" "languages" "convenience" "emacs>=24.3"
  :url "http://www.flycheck.org"
  :emacs>= 24.3
  :ensure t
  :bind (("M-n" . flycheck-next-error)
         ("M-p" . flycheck-previous-error))
  :global-minor-mode global-flycheck-mode)

;;company
(leaf company
  :doc "Modular text completion framework"
  :req "emacs-24.3"
  :tag "matching" "convenience" "abbrev" "emacs>=24.3"
  :url "http://company-mode.github.io/"
  :emacs>= 24.3
  :ensure t
  :blackout t
  :leaf-defer nil
  :bind ((company-active-map
          ("M-n" . nil)
          ("M-p" . nil)
          ("C-s" . company-filter-candidates)
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("<tab>" . company-complete-selection))
         (company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)))
  :custom ((company-idle-delay . 0)
           (company-minimum-prefix-length . 1)
           (company-transformers . '(company-sort-by-occurrence)))
  :global-minor-mode global-company-mode)

(leaf company-c-headers
  :doc "Company mode backend for C/C++ header files"
  :req "emacs-24.1" "company-0.8"
  :tag "company" "development" "emacs>=24.1"
  :added "2020-03-25"
  :emacs>= 24.1
  :ensure t
  :after company
  :defvar company-backends
  :config
  (add-to-list 'company-backends 'company-c-headers))


;;; ===================
;;; Git に関するプラグイン
;;; ===================
;; git-gutter : Git 差分
(leaf git-gutter
  :ensure t
  :global-minor-mode global-git-gutter-mode)

;; magit
(leaf magit
  :ensure t
  :bind (("C-x g" . magit-status)))

;; ================================
;; Org-mode の設定
;; ================================
(add-to-list 'exec-path "/opt/homebrew/bin/gpg") ;; 上記で確認したパスを設定
(setq epg-gpg-program "/opt/homebrew/bin/gpg") ;; EmacsでGPGを指定

(use-package ob-shell
  :ensure nil
  :config
  (setq org-babel-sh-command "zsh")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t))))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize)
  (setq shell-file-name "zsh")
  (setq explicit-shell-file-name "/bin/zsh")
  )

(setq org-babel-sh-command "zsh")

;; org-roam
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (concat
                       (s-trim-right (shell-command-to-string "ghq root"))
                       "/note"))
  (org-roam-completion-everywhere t)
  (org-roam-database-connector 'sqlite-builtin)
  (org-roam-db-gc-threshold (* 4 gc-cons-threshold))
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n c" . org-roam-capture))
  :config
  ;; データベースの自動同期を有効化
  (org-roam-db-autosync-enable)
  ;; キャプチャテンプレートの設定
  (setq org-roam-capture-templates
        '(("f" "Fleeting(技術的なメモ)" plain "%?"
           :target (file+head "org/fleeting/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
           :unnarrowed t)
          ("l" "Literature(文献)" plain "%?"
           :target (file+head "org/literature/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
           :unnarrowed t)
          ("p" "Permanent(体裁を整えた技術記事)" plain "%?"
           :target (file+head "org/permanent/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
           :unnarrowed t)
          ("d" "Diary(日記や非技術的なメモ)" plain "%?"
           :target (file+head "org/diary/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
           :unnarrowed t)
          ("q" "Qiita" plain "%?"
           :target (file+head "org/qiita/%<%Y%m%d%H%M%S>.org" "#+TITLE: ${title}\n")
           :unnarrowed t)
          ("m" "Private" plain "%?"
           :target (file+head "org/private/%<%Y%m%d%H%M%S>.org.gpg" "#+TITLE: ${title}\n")
           :unnarrowed t))))


;; Org BabelでSwiftをサポート
(add-to-list 'load-path "~/personalDevelop/emacs-plugin/ob-swift/");; ローカルパスをEmacsのload-pathに設定
(require 'ob-swift) ;; `ob-swift`をロード
;; org babel
(org-babel-do-load-languages
 'org-babel-do-load-languages
 '((swift t))
 )

(use-package ob-swiftui
  :ensure t
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((swiftui . t))))

;;; これを実行するとbytecomp でエラーが発生する
;; ox-qmd: Org-mode から Qiita 用 Markdown にエクスポート
;; (use-package ox-qmd
;;   :ensure t
;;   :config
;;   (add-to-list 'ox-qmd-language-keyword-alist '("shell-script" . "sh")))

; treesitter
(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install t)
  (global-treesit-auto-mode))

(use-package treesit
  :config
  (setq treesit-font-lock-level 4))

;; Typescript mode
(leaf typescript-mode
  :ensure t
  :mode
  (("\\.ts\\'" . typescript-mode)
   ("\\.tsx\\'" . tsx-ts-mode)))

;; Markdown mode
(leaf markdown-mode :ensure t
  :mode ("\\.md\\'" . gfm-mode)
  :config
  (setopt markdown-command '("pandoc" "--from=markdown" "--to=html5"))
  (setopt markdown-fontify-code-blocks-natively t)
  (setopt markdown-header-scaling t)
  (setopt markdown-indent-on-enter 'indent-and-new-item)
  (define-key markdown-mode-map (kbd "C-c C-c") 'markdown-toggle-gfm-checkbox)
  )

;; "find-sourcekit-lsp"という名前の関数を自前で定義する例
(defun find-sourcekit-lsp ()
  "sourcekit-lspが存在する場合はそのPathを返し、存在しない場合は fallbackする"
  (or (executable-find "sourcekit-lsp")
      "/usr/local/bin/sourcekit-lsp"))

;; .editorconfig file support
(use-package editorconfig
    :ensure t
    :config (editorconfig-mode +1))

;; Rainbow delimiters makes nested delimiters easier to understand
(use-package rainbow-delimiters
    :ensure t
    :hook ((prog-mode . rainbow-delimiters-mode)))

;; lsp
(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration '(emacs-lisp-mode . "emacs-lisp")))
(use-package lsp-mode
  :ensure t
  :hook
    (prog-mode-hook . lsp)
    (swift-mode . lsp)
    (lua-mode . lsp)
    (sh-mode . lsp)
    (yaml-mode . lsp)
  :commands lsp)

;; スニペットの有効化
(setq lsp-enable-snippet t)

;; yasnippetの設定
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

;; java-lsp
(use-package lsp-java
  :ensure t
  :after lsp-mode
  :config
  (add-hook 'java-mode-hook #'lsp))

;; lsp-modeとyasnippetの連携
(require 'lsp-mode)
(setq lsp-prefer-capf t)

;; lsp-mode's UI modules
(use-package lsp-ui
    :ensure t)

;; sourcekit-lsp support
(use-package lsp-sourcekit
  :ensure t
  :after lsp-mode
  :config
  (setq lsp-sourcekit-executable "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp"))

;; Swift editing support
(use-package swift-mode
  :ensure t
  :hook (swift-mode . (lambda () (lsp)))
  :mode "\\.swift\\'"
  :interpreter "swift")

;; lua
(use-package lua-mode
  :ensure t
  :mode "\\.lua\\'"
  :interpreter "lua"
  )

;; yaml
(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" . yaml-mode)
        ("\\.yaml\\'" . yaml-mode)
  )


(use-package xcode-mode :ensure t)

(provide 'init)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
 ;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
