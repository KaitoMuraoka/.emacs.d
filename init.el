(add-to-list 'load-path (locate-user-emacs-file "modules"))


;; 1. 地球儀(Fn)キーを Emacs の 'Hyper' (H-) キーとして認識させる
(setq mac-function-modifier 'hyper)

;; 2. ウィンドウ（フレーム）を画面中央に配置する関数を定義
(defun mac-center-frame ()
  "現在のフレームを画面の中央に配置する"
  (interactive)
  (let* ((display-attrs (frame-monitor-attributes))
         (work-area (alist-get 'workarea display-attrs))
         ;; 画面の幅と高さ
         (screen-x (nth 0 work-area))
         (screen-y (nth 1 work-area))
         (screen-w (nth 2 work-area))
         (screen-h (nth 3 work-area))
         ;; Emacsフレームの幅と高さ
         (frame-w (frame-pixel-width))
         (frame-h (frame-pixel-height))
         ;; 中央の座標を計算
         (left (+ screen-x (max 0 (/ (- screen-w frame-w) 2))))
         (top (+ screen-y (max 0 (/ (- screen-h frame-h) 2)))))
    (set-frame-position (selected-frame) left top)))

;; 3. 地球儀 + Control + C (つまり H-C-c) に先ほどの関数を割り当て
(global-set-key (kbd "C-H-c") 'mac-center-frame)

(require 'mk-straight)
(require 'mk-base)
(require 'mk-keybind)
;;(require 'mk-drill-instructor)
;;(require 'mk-skk)
(require 'mk-view)
(require 'mk-git)
(require 'mk-dirvish)
(require 'mk-shell)
(require 'mk-vterm)
(require 'mk-ghostel)
(require 'mk-claude-code-ide)
(require 'mk-claude-code)
(require 'mk-path-from-shell)
(require 'mk-engine-mode)
(require 'mk-which-key)
(require 'mk-ai-code-interface)
(require 'mk-org)
(require 'mk-org-scratch)
(require 'mk-markdown)
(require 'mk-treesit)
(require 'mk-lsp)
(require 'mk-lsp-manager)
(require 'mk-language-mode)
(require 'mk-rails)
(require 'mk-origami)
(require 'mk-multiple-cursors)
