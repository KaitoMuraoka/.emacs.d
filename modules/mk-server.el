;; -*- lexical-binding: t; -*-
(require 'server)

;; GUI フレームが全て閉じられたら Emacs ごと終了してサーバーを止める
;; 理由: emacsclient -t の端末フレームが残っていると最後の GUI を閉じても Emacs が残るため
(defun mk-server--kill-when-no-gui-frame (_frame)
  (unless (seq-some #'display-graphic-p (frame-list))
    (save-buffers-kill-emacs)))

;; GUI 起動時のみサーバーを起動する（daemon は自前でサーバーを持つため対象外）
(when (and (display-graphic-p) (not (daemonp)))
  (unless (server-running-p)
    (server-start))
  (add-hook 'after-delete-frame-functions #'mk-server--kill-when-no-gui-frame))

(provide 'mk-server)
