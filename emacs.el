;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic UI cleanup
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
 '(indent-tabs-mode nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "JetBrains Mono" :slant normal :weight normal :height 190 :background "#0a0a0a" :foreground "#e8e8e8"))))
 '(fringe ((t (:background "#0a0a0a"))))
 '(mode-line ((t (:background "#3a3a3a" :foreground "#cccccc" :box (:line-width (3 . 3) :color "#555555")))))
 '(mode-line-inactive ((t (:background "#1a1a1a" :foreground "#777777" :box (:line-width (3 . 3) :color "#1a1a1a"))))))

(setq-default line-spacing 4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Quality-of-life improvements

;; Better defaults
(global-auto-revert-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)

;; Better scrolling
(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Show matching parens immediately
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Window navigation with Shift+arrows
(windmove-default-keybindings)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keybindings

(global-set-key (kbd "C-c c") 'recompile)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-c j") 'join-line)

;; Project management
(global-set-key (kbd "C-x p p") 'project-switch-project)
(global-set-key (kbd "C-x p f") 'project-find-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Paredit for Lisp editing

(require 'paredit)
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook #'enable-paredit-mode)
(add-hook 'sly-mode-hook #'enable-paredit-mode)
(add-hook 'sly-repl-mode-hook #'enable-paredit-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Environment integration

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP with eglot (built-in)

(use-package eglot
  :hook ((c-mode c-ts-mode c++-mode c++-ts-mode
          cmake-mode cmake-ts-mode
          meson-mode
          nix-mode
          llvm-mode)
         . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-report-progress nil)
  (eglot-confirm-server-initiated-edits nil)
  (eglot-events-buffer-size 0)
  :config
  ;; Configure clangd for C/C++
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode)
                 . ("clangd"
                    "--header-insertion=never"
                    "--clang-tidy"
                    "--log=error")))
  ;; Configure nixd for Nix
  (add-to-list 'eglot-server-programs
               '(nix-mode . ("nixd")))
  ;; Configure cmake-language-server
  (add-to-list 'eglot-server-programs
               '((cmake-mode cmake-ts-mode) . ("cmake-language-server")))
  ;; Configure mesonlsp
  (add-to-list 'eglot-server-programs
               '(meson-mode . ("mesonlsp")))
  ;; Configure mlir-lsp-server for LLVM IR
  (add-to-list 'eglot-server-programs
               '(llvm-mode . ("mlir-lsp-server"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Company - in-buffer completion (manual trigger)

(use-package company
  :hook (prog-mode . company-mode)
  :custom
  ;; Manual completion only - no automatic popups
  (company-idle-delay nil)
  (company-minimum-prefix-length 2)
  (company-show-quick-access 'left)
  (company-selection-wrap-around t)
  (company-tooltip-align-annotations t)
  (company-require-match nil)
  (company-dabbrev-downcase nil)
  (company-dabbrev-ignore-case nil)
  :bind
  (:map company-mode-map
        ("C-c TAB" . company-complete)
        ("C-c <tab>" . company-complete))
  (:map company-active-map
        ("C-j" . company-select-next)
        ("C-k" . company-select-previous)
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("TAB" . company-complete-selection)
        ("<tab>" . company-complete-selection)
        ("RET" . nil)
        ("<return>" . nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Visual enhancements

;; Rainbow delimiters for better paren visibility
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Which-key shows available keybindings
(use-package which-key
  :config
  (which-key-mode)
  :custom
  (which-key-idle-delay 1.0))

;; Git diff indicators in the fringe
(use-package diff-hl
  :config
  (global-diff-hl-mode)
  :hook
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gptel - LLM interaction in Emacs

(require 'gptel)
(require 'gptel-anthropic)
(require 'gptel-openai)

(use-package gptel
  :ensure nil  ;; loaded from nixpkgs
  :custom
  ;; API keys are loaded from ~/.authinfo
  (gptel-api-key #'gptel-api-key-from-auth-source)

  ;; Use curl if available for better streaming
  (gptel-use-curl t)

  ;; Default model - Claude Sonnet 4.5
  (gptel-model 'claude-sonnet-4-5-20250929)

  :bind
  (("C-c g" . gptel)              ;; Open a dedicated chat buffer
   ("C-c C-g" . gptel-send)       ;; Send region or buffer to LLM
   :map gptel-mode-map
   ("C-c RET" . gptel-send))      ;; Send in gptel chat buffer

  :config
  ;; Default to org-mode for chat buffers
  (setq gptel-default-mode 'org-mode)

  ;; Enable Anthropic Claude backend as default
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key #'gptel-api-key-from-auth-source))

  ;; Also register OpenAI backend with GPT-5 models
  (gptel-make-openai "OpenAI"
    :stream t
    :key #'gptel-api-key-from-auth-source
    :models '(;; GPT-5 models (August 2025)
              gpt-5                    ;; Main GPT-5 model
              gpt-5-mini               ;; Smaller, faster GPT-5
              gpt-5-nano               ;; Smallest, fastest GPT-5
              gpt-5-thinking           ;; Reasoning model
              gpt-5-thinking-mini      ;; Smaller reasoning model
              gpt-5-thinking-nano      ;; Smallest reasoning model
              gpt-5-codex              ;; Specialized for coding (Sept 2025)
              ;; o-series reasoning models
              o3-mini
              o1
              o1-mini
              ;; Legacy models
              gpt-4o
              gpt-4o-mini
              gpt-4-turbo))

  ;; Tips:
  ;; - Use C-u C-c RET to access the transient menu to switch models/backends
  ;; - Use gptel-send in any buffer to interact with LLM inline
  ;; - Use gptel-add to include additional context (files, buffers, regions)
  ;; - Use gptel-rewrite to refactor/rewrite selected regions
  ;; - Save chat buffers as .org files and reopen with gptel-mode
  )
