;;; os.el --- -*- lexical-binding: t -*-
;; Macだけに読み込ませる内容を書く
(when (eq system-type 'darwin)
  ;; MacのEmacsでファイル名を正しく扱うための設定
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs)
  ;; Xcode 26 の ld は MacOSX27 SDK の tbd を読めず native-comp が失敗するため、MacOSX26 SDK を優先させる
  (let ((sdk-lib "/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk/usr/lib"))
    (when (file-directory-p sdk-lib)
      (setq native-comp-driver-options (list "-Wl,-w" (concat "-L" sdk-lib))))))

;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
  (menu-bar-mode 0))

(provide 'os)
;;; os.el ends here
