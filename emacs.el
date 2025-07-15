;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)

;; Configure backup and auto-save files to avoid ~ files everywhere
(let ((backup-dir (expand-file-name "~/.cache/emacs/backups/")))
  (unless (file-exists-p backup-dir)
    (make-directory backup-dir t)))

(let ((auto-save-dir (expand-file-name "~/.cache/emacs/auto-saves/")))
  (unless (file-exists-p auto-save-dir)
    (make-directory auto-save-dir t)))

(setq backup-directory-alist
      `(("." . ,(expand-file-name "~/.cache/emacs/backups/"))))

(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.cache/emacs/auto-saves/") t)))

(setq version-control t
      kept-new-versions 10
      kept-old-versions 5
      delete-old-versions t
      vc-make-backup-files t
      create-lockfiles nil)

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
 '(default ((t (:family "iosevka" :width expanded :slant normal :weight normal 
			:height 195 :background "#100010" :foreground "ivory"))))
 '(fringe ((t nil)))
 '(mode-line ((t (:background "#003355" :foreground "#cccccc" :box (:line-width (1 . 6) :color "#114466") :width condensed))))
 '(mode-line-inactive ((t (:background "#002233" :foreground "#888888" :box (:line-width (1 . 6) :color "#002233"))))))

(setq-default line-spacing 4)

(global-auto-revert-mode 1)

(require 'lsp-bridge)
(global-lsp-bridge-mode)

(require 'sweeprolog)

(add-to-list 'auto-mode-alist '("\\.pl\\'" . sweeprolog-mode))

(global-set-key (kbd "C-c c") 'recompile)

(require 'paredit)
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)
(add-hook 'sly-mode-hook #'enable-paredit-mode)
(add-hook 'sly-repl-mode-hook #'enable-paredit-mode)

(global-set-key (kbd "C-c j") 'join-line)

(envrc-global-mode)

(use-package vertico
  :custom
  (vertico-count 20)  ;; limit to a fixed size
  :bind (:map vertico-map
    ;; Use page-up/down to scroll vertico buffer, like ivy does by default.
    ("<prior>" . 'vertico-scroll-down)
    ("<next>"  . 'vertico-scroll-up))
  :init
  ;; Activate vertico
  (vertico-mode))

;; Convenient path selection
(use-package vertico-directory
  :after vertico
  :ensure nil  ;; no need to install, it comes with vertico
  :bind (:map vertico-map
    ("DEL" . vertico-directory-delete-char)))

(use-package orderless
  :custom
  ;; Activate orderless completion
  (completion-styles '(orderless basic))
  ;; Enable partial completion for file wildcard support
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package consult
  :custom
  ;; Disable preview
  (consult-preview-key nil)
  :bind
  (("C-x b" . 'consult-buffer)    ;; Switch buffer, including recentf and bookmarks
   ("M-l"   . 'consult-git-grep)  ;; Search inside a project
   ("M-y"   . 'consult-yank-pop)  ;; Paste by selecting the kill-ring
   ("M-s"   . 'consult-line)      ;; Search current buffer, like swiper
   ))

(use-package embark
  :bind
  (("C-."   . embark-act)         ;; Begin the embark process
   ("C-;"   . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :config
  (use-package embark-consult))

(use-package savehist :init (savehist-mode))

(use-package emacs
  :custom
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt)))

(use-package marginalia
  :bind (:map minibuffer-local-map ("M-a" . marginalia-cycle))
  :init (marginalia-mode))

(add-to-list 'sweeprolog-analyze-region-fragment-hook 'my-fragger)

(defun my-fragger (x y z)
  (message "frag %s" z))
