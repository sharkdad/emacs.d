;; Visual

(setq modus-themes-italic-constructs t
      modus-themes-bold-constructs t
      modus-themes-fringes 'subtle)
(load-theme 'modus-vivendi)

;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; (load-theme 'flatland t)

(column-number-mode t)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(set-frame-font "Fira Code Retina-12" nil t)
(set-fringe-mode 20)
(tool-bar-mode 0)
(tooltip-mode 0)

(setq default-frame-alist '((undecorated . t)))
(setq inhibit-startup-message t)
(setq visible-bell t)

(tab-bar-mode 1)
(setq tab-bar-close-button-show nil)
(setq tab-bar-new-button-show nil)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(defun adapt-font-size (&optional frame)
  (let* ((attrs (frame-monitor-attributes frame))
         (size (alist-get 'mm-size attrs))
         (geometry (alist-get 'geometry attrs))
         (ppmm (/ (* 1.0 (caddr geometry)) (car size)))
         (height-mm (/ (frame-char-height) ppmm))
         (height-pt (/ (face-attribute 'default :height frame) 10)))
    (set-face-attribute 'default frame :height (* 10 (round 4 (/ height-mm height-pt))))))

(add-function :after after-focus-change-function #'adapt-font-size)
(add-hook 'after-make-frame-functions #'adapt-font-size)

;; Behavior

(setq bookmark-save-flag 1)
(setq completion-ignore-case t)
(setq custom-file null-device)
(setq kill-whole-line 1)

(setq-default buffer-file-coding-system 'utf-8-unix)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(global-auto-revert-mode t)
(global-set-key (kbd "<escape>") 'keyboard-quit)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c p") 'previous-buffer)
(global-set-key (kbd "C-c n") 'next-buffer)
(global-unset-key (kbd "C-h C-h"))
(savehist-mode t)

;; dired

(with-eval-after-load 'dired
  (require 'dired-x)
  (add-hook 'dired-mode-hook 'dired-hide-details-mode)
  ;; (add-hook 'dired-mode-hook 'dired-omit-mode)
  (define-key dired-mode-map [mouse-2] 'dired-find-file)
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$")))

;; Languages

(setq common-lisp-style-default "basic")
(setq inferior-lisp-program "sbcl")

(setq js-indent-level 2)
(setq js-jsx-indent-level 2)
(setq typescript-indent-level 2)

;; Backups

(setq auto-save-timeout 5)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,(concat user-emacs-directory "backups"))))
(setq delete-old-versions t)
(setq kept-new-versions 10)
(setq kept-old-versions 0)
(setq vc-make-backup-files t)
(setq version-control t)

;; Packages

(require 'package)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(unless (package-installed-p 'quelpa)
  (with-temp-buffer
    (url-insert-file-contents "https://raw.githubusercontent.com/quelpa/quelpa/master/quelpa.el")
    (eval-buffer)
    (quelpa-self-upgrade)))

(quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://github.com/quelpa/quelpa-use-package.git"))
(require 'quelpa-use-package)

(use-package amx)

(use-package avy
  :demand
  :bind (("C-;" . avy-goto-char)
	 ("C-'" . avy-goto-char-2)
	 ("M-g g" . avy-goto-line)
	 ("M-g w" . avy-goto-word-1)
	 ("M-g e" . avy-goto-word-0)))

(use-package diminish)

(use-package company
  :diminish
  :config
  (setq company-idle-delay 0.5)
  (global-company-mode t))

(use-package counsel
  :demand
  :diminish counsel-mode
  :diminish ivy-mode
  :bind (("C-c f" . counsel-git)
         ("C-c s" . swiper)
	 ("C-x C-r" . counsel-recentf))
  :config
  (setq ivy-height 15)
  (ivy-mode t)
  (counsel-mode t))

(use-package flx)

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package sly)

(use-package smartparens
  :diminish
  :config
  (require 'smartparens-config)
  (sp-pair "{" nil :post-handlers '(("||\n[i]" "RET")))
  (smartparens-global-mode t)
  (smartparens-global-strict-mode t)
  (sp-use-smartparens-bindings))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :bind (("C-h C-b" . which-key-show-top-level))
  :config
  (setq which-key-show-early-on-C-h t)
  (setq which-key-idle-delay 10000)
  (setq which-key-idle-secondary-delay 0.05)
  (which-key-mode))

(use-package tree-sitter
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs
  :ensure t
  :after tree-sitter)

(use-package typescript-mode
  :after tree-sitter
  :config
  (define-derived-mode typescriptreact-mode typescript-mode
    "TypeScript TSX")
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescriptreact-mode))
  (add-to-list 'tree-sitter-major-mode-language-alist '(typescriptreact-mode . tsx)))

(use-package tsi
  :after tree-sitter
  :quelpa (tsi :fetcher github :repo "orzechowskid/tsi.el")
  :commands (tsi-typescript-mode tsi-json-mode tsi-css-mode)
  :init
  (add-hook 'typescript-mode-hook (lambda () (tsi-typescript-mode 1)))
  (add-hook 'json-mode-hook (lambda () (tsi-json-mode 1)))
  (add-hook 'css-mode-hook (lambda () (tsi-css-mode 1)))
  (add-hook 'scss-mode-hook (lambda () (tsi-scss-mode 1))))

(use-package go-mode)

(use-package lsp-mode
  :init
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-keymap-prefix "C-c l")
  :hook ((go-mode . lsp-deferred)
         (typescript-mode . lsp-deferred))
  :commands lsp-deferred)

(use-package lsp-ui
  :commands lsp-ui-mode)
(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)

(use-package yaml-mode
  :mode (("\\.yml\\'" . yaml-mode)))

(use-package sql-indent)

(use-package magit
  :defer 0
  :bind (("C-c g" . magit-file-dispatch))
  :config
  (magit-wip-mode)
  (setq magit-diff-refine-hunk 'all))
