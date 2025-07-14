(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)

(add-to-list 'default-frame-alist '(undecorated . t))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "input mono condensed" :slant normal :weight regular :height 135 :width normal :background "#100010" :foreground "#ffaacc"))))
 '(fringe ((t nil)))
 '(mode-line ((t (:background "#003355" :foreground "#cccccc" :box (:line-width (1 . 6) :color "#003355")))))
 '(mode-line-inactive ((t (:background "#002233" :foreground "#888888" :box (:line-width (1 . 6) :color "#002233"))))))

(setq-default line-spacing 2)

(global-auto-revert-mode 1)

(require 'lsp-bridge)
(global-lsp-bridge-mode)

(require 'sweeprolog)

(add-to-list 'auto-mode-alist '("\\.pl\\'" . sweeprolog-mode))

(global-set-key (kbd "C-c c") 'recompile)

(ido-mode 1)

(require 'paredit)
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)
(add-hook 'sly-mode-hook #'enable-paredit-mode)
(add-hook 'sly-repl-mode-hook #'enable-paredit-mode)

(global-set-key (kbd "C-c j") 'join-line)
