;; -*- lexical-binding: t; -*-
;;; ============================================================
;;; Denote（Obsidian 相当のノート環境）
;;; ============================================================
;; 方針: DB・インデックスは作らない。検索や集計は毎回 .org ファイルを走査する。
;;       リンクは ID ベースの denote: に統一する。
;; キーは C-c n をプレフィックスにまとめる。

;; Vault・ノート作成・リンク・バックリンク・タグ・名前変更
(use-package denote
  ;; 自作コマンドと capture テンプレートが denote の関数を使うため起動時に読み込む
  :demand t
  :custom
  ;; Vault は ~/org。サブディレクトリ（journal など）も再帰的に対象になる
  (denote-directory (expand-file-name "~/org/"))
  (denote-file-type 'org)
  (denote-known-keywords '("idea" "book" "meeting" "project"))
  ;; バックリンクは右のサイドウィンドウに出す（Obsidian のバックリンクパネル）
  (denote-backlinks-display-buffer-action
   '((display-buffer-reuse-window display-buffer-in-side-window)
     (side . right)
     (slot . 0)
     (window-width . 0.3)
     (dedicated . t)
     (preserve-size . (t . t))))
  ;; denote-template で選ぶテンプレート（TYPE などのプロパティは org-ql で集計できる）
  (denote-templates
   '((plain . "")
     ;; denote-journal は journal キーがあれば選択プロンプトを出さずに使う
     (journal . "* 今日やること\n\n* ログ\n\n* 振り返り\n")
     (meeting . "* 参加者\n\n* 議題\n\n* 決定事項\n\n* TODO\n")
     (book . "* 概要\n:PROPERTIES:\n:TYPE: book\n:AUTHOR:\n:STATUS: 未読\n:RATING:\n:END:\n\n* メモ\n")))
  ;; capture の本文に呼び出し元の file: リンク（%l）を入れない
  (denote-org-capture-specifiers "%i\n%?")
  :hook
  (dired-mode . denote-dired-mode)
  :bind
  (("C-c n n" . denote)
   ("C-c n o" . denote-open-or-create)
   ("C-c n l" . denote-link-or-create)
   ("C-c n b" . denote-backlinks)
   ("C-c n g" . denote-grep)
   ("C-c n t" . mk/denote-filter-by-keyword)
   ("C-c n T" . denote-template)
   ("C-c n r" . denote-rename-file)
   ("C-c n R" . denote-rename-file-using-front-matter)))

(defun mk/denote-filter-by-keyword (keyword)
  "KEYWORD（ファイル名の __tag）を持つノートを Dired で一覧する。"
  (interactive (list (completing-read "タグ: " (denote-keywords))))
  (denote-sort-dired (concat "_" (regexp-quote keyword) "[_.]") nil nil nil))

;; ノート内のバックリンク・リンク・ファイル一覧（動的ブロック）
(use-package denote-org
  :after denote
  :bind
  (("C-c n d" . denote-org-dblock-insert-backlinks)
   ("C-c n D" . denote-org-dblock-insert-links)))

;; デイリーノート（~/org/journal に作る）
(use-package denote-journal
  :after denote
  :custom
  (denote-journal-directory (expand-file-name "journal" denote-directory))
  (denote-journal-title-format 'day-date-month-year)
  :bind
  ("C-c n j" . denote-journal-new-or-existing-entry))

;; 全文検索（ripgrep が必要）
(use-package consult
  :bind
  ("C-c n s" . mk/denote-ripgrep))

(defun mk/denote-ripgrep ()
  "ノートディレクトリ内を consult-ripgrep で全文検索する。"
  (interactive)
  (consult-ripgrep denote-directory))

;; Properties / Bases / カンバン（実行時にファイルを走査するだけで DB は作らない）
(use-package org-super-agenda)

(use-package org-ql
  :custom
  (org-ql-views
   '(("Denote: TODO 一覧"
      :buffers-files mk/denote-org-files
      :query (todo)
      :sort (todo priority date)
      :title "TODO 一覧")
     ("Denote: カンバン"
      :buffers-files mk/denote-org-files
      :query (todo)
      :super-groups ((:auto-todo t))
      :title "カンバン")
     ("Denote: 本（TYPE=book）"
      :buffers-files mk/denote-org-files
      :query (property "TYPE" "book")
      :super-groups ((:auto-property "STATUS"))
      :title "本の一覧")))
  :bind
  (("C-c n q" . org-ql-view)
   ("C-c n k" . mk/denote-kanban)))

(defun mk/denote-org-files ()
  "Denote ディレクトリ配下の .org ファイル一覧を返す。"
  (denote-directory-files "\\.org\\'"))

(defun mk/denote-kanban ()
  "TODO キーワードごとに列分けしたカンバン表示を開く。"
  (interactive)
  (org-ql-view "Denote: カンバン"))

;; グラフビュー（実行時に走査して Graphviz で SVG を出力する。graphviz が必要）
(use-package denote-explore
  :after denote
  :custom
  (denote-explore-network-format 'graphviz)
  :bind
  ("C-c n G" . denote-explore-network))

;; Live Preview 風の表示
(use-package org-modern
  :custom
  ;; 見出しは * の数で階層がわかるよう、記号への置き換えも先頭の * の非表示もしない
  (org-modern-star nil)
  (org-modern-hide-stars nil)
  :hook (org-mode . org-modern-mode))

(use-package org-appear
  :custom
  (org-appear-autolinks t)
  :hook (org-mode . org-appear-mode))

(add-hook 'org-mode-hook #'visual-line-mode)

;; Quick Capture / Web クリップ（org-protocol）
(require 'org-protocol)
(with-eval-after-load 'org-capture
  (add-to-list 'org-capture-templates
               '("n" "Denote ノート" plain
                 (file denote-last-path)
                 #'denote-org-capture
                 :no-save t
                 :immediate-finish nil
                 :kill-buffer t
                 :jump-to-captured t))
  (add-to-list 'org-capture-templates
               '("w" "Web クリップ（Denote ノート）" plain
                 (file denote-last-path)
                 (function
                  (lambda ()
                    (let ((denote-org-capture-specifiers
                           "* 出典\n%:link\n\n* 引用\n#+begin_quote\n%i\n#+end_quote\n\n* メモ\n%?"))
                      (denote-org-capture))))
                 :no-save t
                 :immediate-finish nil
                 :kill-buffer t
                 :jump-to-captured t)))

;; Publish（denote: リンクは denote-link-ol-export が相対 .html リンクに変換する）
(with-eval-after-load 'ox-publish
  (add-to-list 'org-publish-project-alist
               `("denote"
                 :base-directory ,(expand-file-name "~/org/")
                 :base-extension "org"
                 :recursive t
                 :exclude "public_html/"
                 :publishing-directory ,(expand-file-name "~/org/public_html/")
                 :publishing-function org-html-publish-to-html
                 :with-toc nil)))

(provide 'mk-denote)
