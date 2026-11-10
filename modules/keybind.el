;;; keybind.el --- -*- lexical-binding: t -*-
(global-set-key (kbd "C-m") 'newline-and-indent);; C-mにnewline-and-indentを割り当てる。
(global-set-key (kbd "C-h") (kbd "<DEL>"));; C-h を<DEL>(バックスペース)に置き換える
(global-set-key (kbd "C-x ?") 'help-command);; 別のキーバインドにヘルプを割り当てる
(global-set-key (kbd "C-t") 'other-window);; "C-t" でウィンドウを切り替える。初期値はtranspose-chars
(global-set-key (kbd "C-;") 'set-mark-command) ;; C-;でマークセット


(provide 'keybind)
;;; keybind.el ends here
