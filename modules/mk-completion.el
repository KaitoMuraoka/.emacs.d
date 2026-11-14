;;; mk-completion.el --- -*- lexical-binding: t -*-

;; ===== ミニバッファ補完 =====

;; vertico: ミニバッファの候補を縦に並べて表示する
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

;; orderless: スペース区切りの各語を順不同でマッチさせる
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  ;; ファイル名は ~/.e/in → ~/.emacs.d/init.el のような前方一致展開を使う
  (completion-category-overrides '((file (styles partial-completion)))))

;; partial-completion で先頭にもワイルドカードを補う
(use-package minibuffer
  :custom
  (completion-pcm-leading-wildcard t))

;; marginalia: 候補の横に説明（docstring・ファイル情報など）を表示する
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;; savehist: ミニバッファの入力履歴を再起動後も残す
(use-package savehist
  :init
  (savehist-mode))

;; ===== 検索・移動コマンド =====

;; consult: バッファ切り替え・行検索・grep などを候補選択付きで行う
(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
         ("M-s l" . consult-line)
         ("M-s r" . consult-ripgrep)
         ("M-g i" . consult-imenu)))

;; ===== 候補へのアクション =====

;; embark: カーソル位置や選択中の候補に対する操作メニューを開く
(use-package embark
  :ensure t
  :bind ("C-." . embark-act))

;; embark-consult: embark の一覧画面で consult のプレビューを効かせる
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ===== バッファ内補完 =====

;; corfu: 入力中に補完候補をポップアップ表示する
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)  ; 入力に応じて自動で候補を出す
  (corfu-cycle t) ; 末尾の次は先頭に戻る
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode)) ; 選択中の候補のドキュメントを横に表示する

;; cape: バッファ内の単語・ファイルパスを補完候補の取得元に加える
(use-package cape
  :ensure t
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

(provide 'mk-completion)
;;; mk-completion.el ends here
