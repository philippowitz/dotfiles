;; -*- no-byte-compile: t; no-native-compile: t; no-update-autoloads: t; lexical-binding: t -*-
        (setq gc-cons-threshold (* 50 1000 1000))
        (setq read-process-output-max (* 1024 1024)) ;; 1mb
        (setq init-start-time (current-time))
        (setq custom-file (make-temp-file "emacs-custom-"))
        (setq safe-local-variable-values '((org-use-property-inheritance . t)))
        (setq inhibit-splash-screen t ;; no thanks
              use-dialog-box nil
              use-file-dialog nil ;; don't use system file dialog
              tab-bar-new-button-show nil ;; don't show new tab button
              tab-bar-close-button-show nil ;; don't show tab close button
              tab-line-close-button-show nil ;; don't show tab close button
              tab-bar-show nil
              history-length 25
              pgtk-wait-for-event-timeout nil)

      (add-hook 'before-save-hook #'whitespace-cleanup)

        (when (native-comp-available-p)
          (setq native-comp-async-report-warnings-errors 'silent) ; Emacs 28 with native compilation
          (setq native-compile-prune-cache t)) ; Emacs 29

    (setq-default indent-tabs-mode nil)

    (add-hook 'prog-mode-hook (lambda () (setq indent-tabs-mode nil)))

(dolist (mode '(prog-mode-hook))
  (add-hook mode #'hs-minor-mode))

(setq x-stretch-cursor t)


        ;; Disable line numbers for some modes
        (dolist (mode '(org-mode-hook
                        term-mode-hook
                        eshell-mode-hook))
          (add-hook mode (lambda () (display-line-numbers-mode))))

        (defun beginning-of-line-or-indentation ()
          "move to beginning of line, or indentation"
          (interactive)
          (if (bolp)
              (back-to-indentation)
            (beginning-of-line)))
        (define-key global-map (kbd "C-a") 'beginning-of-line-or-indentation)

(defun phil/backward-kill-word ()
  "Remove all whitespace if the character behind the cursor is whitespace, otherwise remove a word."
  (interactive)
  (if (looking-back "[ \n]")
      ;; delete horizontal space before us and then check to see if we
      ;; are looking at a newline
      (progn (delete-horizontal-space 't)
             (while (looking-back "[ \n]")
               (backward-delete-char 1)))
    ;; otherwise, just do the normal kill word.
    (backward-kill-word 1)))

(global-set-key  [C-backspace]
                 'phil/backward-kill-word)

(defun prot-simple-keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(global-set-key  (kbd "C-g")
                 'prot-simple-keyboard-quit-dwim)



(setq major-mode-remap-alist
      '((yaml-mode . yaml-ts-mode)
        (bash-mode . bash-ts-mode)
        (java-mode . java-ts-mode)
        (js2-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (json-mode . json-ts-mode)
        (css-mode . css-ts-mode)
        (python-mode . python-ts-mode)))

(load-theme 'modus-operandi)

(defvar elpaca-installer-version 0.10)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))
  (elpaca-wait)
  (use-package no-littering :ensure (:wait t)
    :config
    (no-littering-theme-backups))

(use-package org
  :ensure `(org :repo "https://code.tecosaur.net/tec/org-mode.git/"
                          :branch "dev" :wait t)
  :defer t
  :config
  (add-to-list 'org-latex-packages-alist '("" "akkmathset" t))
      (add-to-list 'org-latex-packages-alist '("" "mathtools" t))
  (setq org-startup-indented t)
  (setq org-M-RET-may-split-line '((default . nil)))
  (setq org-insert-heading-respect-content t)
  (setq org-use-property-inheritance t))

(use-package savehist
  :init
  (savehist-mode 1))

(use-package emacs
  :ensure nil
  :init
  (setopt use-short-answers t)
  (set-face-attribute 'default nil
                      :font "Iosevka Comfy"
                      :height 100)

  (defun ab/enable-line-numbers ()
    "Enable relative line numbers"
    (interactive)
    (display-line-numbers-mode)
    (setq display-line-numbers 'relative))
  (add-hook 'prog-mode-hook #'ab/enable-line-numbers)
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

  (setq initial-scratch-message nil)
  (defun display-startup-echo-area-message ()
    (message ""))
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2)
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p)

  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

(defun efs/display-startup-time ()
    (let ((init-time (float-time (time-subtract (current-time) init-start-time)))
      (total-time (string-to-number (emacs-init-time "%f"))))
  (message (concat
    "Startup time: "
    (format "%.2fs " init-time)
    (format "(+ %.2fs system time)"
                        (- total-time init-time))))))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

(defun ct/dir-contains-project-marker (dir)
  "Checks if `.project' file is present in directory at DIR path."
  (let ((project-marker-path (file-name-concat dir ".projectile")))
    (when (file-exists-p project-marker-path)
       (cons 'transient dir))))

(customize-set-variable 'project-find-functions
                        (list #'project-try-vc
                              #'ct/dir-contains-project-marker))

(let ((default-directory (locate-user-emacs-file "local-modules/")))
  (normal-top-level-add-subdirs-to-load-path))

(setenv "SHELL" "/bin/bash")
(setq explicit-shell-file-name "/bin/bash")

(use-package on
  :ensure
  (:host gitlab :repo "axgfn/on.el"))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (daemonp)
    (exec-path-from-shell-initialize)))

(defun my-md-to-org-region (start end)
"Convert region from markdown to org"
(interactive "r")
(shell-command-on-region start end "pandoc -f markdown -t org" t t))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package tabspaces
  :ensure t
  :commands (tabspaces-switch-or-create-workspace
             tabspaces-open-or-create-project-and-workspace)
  :bind
  ("<C-tab>" . tabspaces-switch-or-create-workspace)
  :custom
  (tabspaces-use-filtered-buffers-as-default t)
  (tabspaces-default-tab "Default")
  (tabspaces-remove-to-default t)
  (tabspaces-include-buffers '("*scratch*"))
  (tabspaces-initialize-project-with-todo t)
  (tabspaces-todo-file-name "project-todo.org")
  ;; sessions
  (tabspaces-session t)
  (tabspaces-session-auto-restore nil)
  (tab-bar-new-tab-choice "*scratch*")
  (tabspaces-keymap-prefix "C-x t")
  (defvar tabspaces-command-map
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "C") 'tabspaces-clear-buffers)
      (define-key map (kbd "b") 'tabspaces-switch-to-buffer)
      (define-key map (kbd "d") 'tabspaces-close-workspace)
      (define-key map (kbd "k") 'tabspaces-kill-buffers-close-workspace)
      (define-key map (kbd "o") 'tabspaces-open-or-create-project-and-workspace)
      (define-key map (kbd "r") 'tabspaces-remove-current-buffer)
      (define-key map (kbd "R") 'tabspaces-remove-selected-buffer)
      (define-key map (kbd "s") 'tabspaces-switch-or-create-workspace)
      (define-key map (kbd "t") 'tabspaces-switch-buffer-and-tab)
      map)
    "Keymap for tabspace/workspace commands after `tabspaces-keymap-prefix'.")
    :config
    ;; Tabspace integration
    (with-eval-after-load 'consult
      ;; hide full buffer list (still available with "b" prefix)
      (consult-customize consult--source-buffer :hidden t :default nil)
      ;; set consult-workspace buffer list
      (defvar consult--source-workspace
        (list :name     "Workspace Buffers"
              :narrow   ?w
              :history  'buffer-name-history
              :category 'buffer
              :state    #'consult--buffer-state
              :default  t
              :items    (lambda () (consult--buffer-query
                                    :predicate #'tabspaces--local-buffer-p
                                    :sort 'visibility
                                    :as #'buffer-name)))

        "Set workspace buffer list for consult-buffer.")
      (add-to-list 'consult-buffer-sources 'consult--source-workspace)))

(use-package which-key
      :init (which-key-mode)
      :diminish which-key-mode)

    (use-package nerd-icons
      :defer t
      :ensure t)

    (use-package emojify
      :ensure t
      :hook (on-first-buffer . global-emojify-mode))

    (use-package rainbow-delimiters
      :ensure t
      :hook (prog-mode . rainbow-delimiters-mode))

    (use-package spacious-padding
      :ensure t
      :init
      (setq spacious-padding-widths
        '( :internal-border-width 10
           :header-line-width -4
           :mode-line-width -4
           :tab-width 4
           :right-divider-width 20
           :scroll-bar-width 4
           :fringe-width 8))
      (spacious-padding-mode))

(use-package pixel-scroll
  :ensure nil
  :bind
  ([remap scroll-up-command]   . pixel-scroll-interpolate-down)
  ([remap scroll-down-command] . pixel-scroll-interpolate-up)
  :custom
  (pixel-scroll-precision-interpolate-page t))


    (use-package casual-suite
      :ensure t
      :defer t
      :bind (("M-g" . casual-avy-tmenu)
             ("M-o" . casual-editkit-main-tmenu))
      :hook   (calc-mode . (lambda () (keymap-set calc-mode-map "M-o" #'casual-calc-tmenu)))
      (dired-mode . (lambda () (keymap-set dired-mode-map "M-o" #'casual-dired-tmenu)))
      (isearch-mode . (lambda () (keymap-set isearch-mode-map "M-o" #'casual-isearch-tmenu)))
      (ibuffer-mode . (lambda ()
                        (keymap-set ibuffer-mode-map "M-o" #'casual-ibuffer-tmenu)
                        (keymap-set ibuffer-mode-map "F" #'casual-ibuffer-filter-tmenu)
                        (keymap-set ibuffer-mode-map "s" #'casual-ibuffer-sortby-tmenu)))
      (Info-mode . (lambda () (keymap-set Info-mode-map "M-o" #'casual-info-tmenu)))
      (reb-mode . (lambda () (keymap-set reb-mode-map "M-o" #'casual-re-builder-tmenu)))
      (reb-lisp-mode . (lambda () (keymap-set reb-lisp-mode-map "M-o" #'casual-re-builder-tmenu)))
      (bookmark-bmenu-mode . (lambda () (keymap-set bookmark-bmenu-mode-map "M-o" #'casual-bookmarks-tmenu)))
      (org-agenda-mode . (lambda () (keymap-set org-agenda-mode-map "M-o" #'casual-agenda-tmenu)))
      (symbol-overlay-mode . (lambda () (keymap-set symbol-overlay-map "M-o" #'casual-symbol-overlay-tmenu))))

(use-package ace-window
  :ensure t
  :bind
  ("M-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package undo-fu
  :ensure t
  :config
  (setq undo-limit 400000           ; 400kb (default is 160kb)
        undo-strong-limit 3000000   ; 3mb   (default is 240kb)
        undo-outer-limit 48000000)  ; 48mb  (default is 24mb)

  ;; Keybindings
  (global-set-key [remap undo] #'undo-fu-only-undo)
  (global-set-key [remap redo] #'undo-fu-only-redo)
  (global-set-key (kbd "C-_")     #'undo-fu-only-undo)
  (global-set-key (kbd "M-_")     #'undo-fu-only-redo)
  (global-set-key (kbd "C-M-_")   #'undo-fu-only-redo-all)
  (global-set-key (kbd "C-x r u") #'undo-fu-session-save)
  (global-set-key (kbd "C-x r U") #'undo-fu-session-recover))

(use-package undo-fu-session
  :ensure t
  :config
  (when (executable-find "zstd")
    (setq undo-fu-session-compression 'zst))
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))
  (undo-fu-session-global-mode 1)
  :custom
  (undo-fu-session-directory (concat no-littering-var-directory "undo-fu-session/")))

  (use-package vundo
    :ensure t
    :defer t
    :bind ("C-x u" . vundo))

(use-package vertico
  :ensure t
  :hook (on-first-input . vertico-mode)
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  (vertico-resize nil) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycgle t) ;; Enable cycling for `vertico-next/previous'
  )

(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("C-DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package marginalia
  :ensure t
  :after vertico
  :config
  (marginalia-mode))

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package corfu
    :ensure t
    :hook (on-first-input . global-corfu-mode)
    :bind
    (:map corfu-map
          ("C-n" . corfu-next)
          ("C-p" . corfu-previous)
          ("M-n". corfu-popupinfo-scroll-down)
          ("M-p". corfu-popupinfo-scroll-up))
    :config
    (setq tab-always-indent 'complete)
    (setq corfu-preview-current nil)
    (setq corfu-min-width 20)

     (setq corfu-auto t
          corfu-cycle t
          corfu-preselect 'prompt
          corfu-count 16
          corfu-max-width 120)

    (with-eval-after-load 'savehist
      (corfu-history-mode 1)
      (add-to-list 'savehist-additional-variables 'corfu-history))
)

(use-package cape
:after corfu
:ensure t
;; Bind prefix keymap providing all Cape commands under a mnemonic key.
;; Press C-c p ? to for help.
;; :bind ("M-p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
;; Alternatively bind Cape commands individually.
;; :bind (("C-c p d" . cape-dabbrev)
;;        ("C-c p h" . cape-history)
;;        ("C-c p f" . cape-file)
;;        ...)
:init
;; Add to the global default value of `completion-at-point-functions' which is
;; used by `completion-at-point'.  The order of the functions matters, the
;; first function returning a result wins.  Note that the list of buffer-local
;; completion functions takes precedence over the global list.
(defun my/eglot-capf ()
(setq-local completion-at-point-functions
            (list (cape-capf-super
                   #'eglot-completion-at-point
                   #'cape-file))))

(add-hook 'eglot-managed-mode-hook #'my/eglot-capf)
(add-hook 'completion-at-point-functions #'cape-dabbrev)
(add-hook 'completion-at-point-functions #'cape-file)
(add-hook 'completion-at-point-functions #'cape-elisp-block)

(add-hook 'completion-at-point-functions #'cape-history))

(use-package fussy
  :defer t
  :ensure
  (:host github :repo "jojojames/fussy")
  :config
  (setq fussy-use-cache t)
  (setq fussy-compare-same-score-fn 'fussy-histlen->strlen<)
  (fussy-setup))

;; (use-package fzf-native
;;   :ensure
;;   (fzf-native :repo "dangduc/fzf-native" :host github :files (:defaults "*.c" "*.h" "*.txt"))
;;   :init
;;   (setq fzf-native-always-compile-module t)
;;   :config
;;   (setq fussy-score-fn 'fussy-fzf-native-score)
;;   (fzf-native-load-own-build-dyn))

(use-package orderless
  :ensure t
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)

         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (setq consult-preview-key "M-.")
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   )
  )


(use-package consult-project-extra
  :ensure t
  :after consult
  :bind
  (("C-c p f" . consult-project-extra-find)
   ("C-c p o" . consult-project-extra-find-other-window)))

(use-package embark
  :defer t
  :ensure t
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-c" . embark-collect)
         ("C-c C-e" . embark-export)))

(use-package embark-consult
  :after embark
  :ensure t)

(use-package wgrep
  :defer t
  :ensure t
  :bind ( :map grep-mode-map
          ("e" . wgrep-change-to-wgrep-mode)
          ("C-x C-q" . wgrep-change-to-wgrep-mode)
          ("C-c C-c" . wgrep-finish-edit)))

;; Configure Tempel
(use-package tempel
  :ensure t
  ;; Require trigger prefix before template name when completing.
  ;; :custom
  ;; (tempel-trigger-prefix "<")
  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert))
  :init
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions)))
  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)

  ;; Optionally make the Tempel templates available to Abbrev,
  ;; either locally or globally. `expand-abbrev' is bound to C-x '.
  ;; (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
  ;; (global-tempel-abbrev-mode)
)

;; Optional: Add tempel-collection.
;; The package is young and doesn't have comprehensive coverage.
(use-package tempel-collection
  :ensure t
  :after tempel)

(use-package laas
  :ensure t
  :hook (org-mode . laas-mode)
  :config ; do whatever here
  (aas-set-snippets 'laas-mode
    ;; set condition!
    :cond #'texmathp ; expand only while in math
    "supp" "\\supp"
    "On" "O(n)"
    "O1" "O(1)"
    "Olog" "O(\\log n)"
    "Olon" "O(n \\log n)"
    ;; bind to functions!
    "Sum" (lambda () (interactive)
            (tempel-insert ("\\sum_{"p"}^{"p"}" p)))

    "Sca" (lambda () (interactive)
            (tempel-insert ("\\langle " p"," p "\\rangle " p)))
    "Span" (lambda () (interactive)
             (tempel-insert ("\\Span("p") " p)))
    ;; add accent snippets
    :cond #'laas-object-on-left-condition
    "qq" (lambda () (interactive) (laas-wrap-previous-object "sqrt"))
    "'e" (lambda () (interactive) (laas-wrap-previous-object "mathbb"))
    ))

(setq org-agenda-files '("~/org/"))
(setq org-directory "~/org/")

(use-package cdlatex
  :ensure t
  :custom
  (cdlatex-math-modify-prefix [f7])
  (cdlatex-math-symbol-prefix [f8])
  :hook (org-mode . org-cdlatex-mode))

(use-package org
  :ensure nil
  :config
  (define-key org-cdlatex-mode-map (kbd "'") nil)
  :bind
  ("C-c a" . org-agenda))

(use-package org-download
  :ensure t
  :hook (org-mode . org-download-enable)
  :config
  (setq org-download-link-format "[[file:%s]]\n"
        org-download-abbreviate-filename-function #'file-relative-name)
  (setq org-download-link-format-function #'org-download-link-format-function-default))


(use-package org-latex-preview
  :defer t
  :hook (org-mode . org-latex-preview-auto-mode)
  :config
  ;; Increase preview width
  (plist-put org-latex-preview-appearance-options
             :page-width 0.8)
  ;; Use dvisvgm to generate previews
  ;; You don't need this, it's the default:
  (setq org-latex-preview-process-default 'dvisvgm)

  ;; Turn on auto-mode, it's built into Org and much faster/more featured than
  ;; org-fragtog. (Remember to turn off/uninstall org-fragtog.)
  ;; (add-hook 'org-mode-hook 'org-latex-preview-auto-mode)

  ;; Block C-n, C-p etc from opening up previews when using auto-mode
  (setq org-latex-preview-auto-ignored-commands
        '(next-line previous-line mwheel-scroll
                    scroll-up-command scroll-down-command))

  ;; Enable consistent equation numbering
  (setq org-latex-preview-numbered t)

  ;; Bonus: Turn on live previews.  This shows you a live preview of a LaTeX
  ;; fragment and updates the preview in real-time as you edit it.
  ;; To preview only environments, set it to '(block edit-special) instead
  (setq org-latex-preview-live t)

  ;; More immediate live-previews -- the default delay is 1 second
  (setq org-latex-preview-live-debounce 0.25))

(use-package ox
  :after ox-latex
  :config
  ;; Add custom LaTeX class
  (add-to-list 'org-latex-classes
                   '("Ausbildungsnachweis" "\\documentclass[a4paper, 12pt]{letter}
[NO-DEFAULT-PACKAGES]
[PACKAGES]
[EXTRA]"
                     ("\\section{%s}" . "\\section*{%s}")
                     ("\\subsection{%s}" . "\\subsection*{%s}")))

  ;; Define the custom backend
  (org-export-define-derived-backend 'ausbildungsnachweis 'latex
    :options-alist
    '((:trainyear "TRAINYEAR" nil nil)          ;; Extract #+FROM: keyword
      (:traino "TRAINNO" nil nil) ;; Extract #+DEPARTMENT: keyword
      (:timeframe "TIMEFRAME" nil nil) ;; Extract #+DEPARTMENT: keyword
      (:institute "INSTITUTE" nil nil)) ;; Extract #+DEPARTMENT: keyword
    :translate-alist '((template . ausbildungsnachweis-template))
    :menu-entry
    '(?A "Export with Ausbildungsnachweis"
         ((?L "As LaTeX buffer" ausbildungsnachweis-export-as-latex)
          (?l "As LaTeX file" ausbildungsnachweis-export-to-latex)
          (?p "As PDF file" ausbildungsnachweis-export-to-pdf)
          (?o "As PDF file and open"
              (lambda (a s v b)
                (if a (ausbildungsnachweis-export-to-pdf t s v b)
                  (org-open-file (ausbildungsnachweis-export-to-pdf nil s v b))))))))

  (defun ausbildungsnachweis-template (contents info)
    "Return complete document string after LaTeX conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
    (let ((title (org-export-data (plist-get info :title) info))
              (spec (org-latex--format-spec info))
          (trainyear(org-export-data (plist-get info :trainyear) info))
          (traino (org-export-data (plist-get info :traino) info))
          (timeframe (org-export-data (plist-get info :timeframe) info))
          (institute (org-export-data (plist-get info :institute) info)))
      (concat
       ;; Timestamp.
       (and (plist-get info :time-stamp-file)
                (format-time-string "%% Created %Y-%m-%d %a %H:%M\n"))
       ;; LaTeX compiler.
       (org-latex--insert-compiler info)
       ;; Document class and packages.
       (org-latex-make-preamble info)
       "
\\usepackage{lmodern}
\\usepackage{fancyhdr}
\\usepackage[stretch=10]{microtype}
\\usepackage{array}
\\usepackage{booktabs}
\\usepackage{tabularx}
\\usepackage{geometry}
\\usepackage{eforms}
\\usepackage[parfill]{parskip}

\\renewcommand{\\baselinestretch}{1.15}
\\geometry{a4paper, margin=1in}
\\pagestyle{fancy}
\\fancyhf{}  % Clear default header/footer
\\fancyhead[C]{Ausbildung Mathematisch-technischer Softwareentwickler an der Universität zu Köln}  % Left header
\\fancyfoot[C]{\\thepage}  % Centered page number in the footer
\\renewcommand{\\arraystretch}{2}

\\makeatletter
\\def\\institute#1{\\gdef\\@institute{#1}}
\\def\\timeframe#1{\\gdef\\@timeframe{#1}}
\\def\\trainno#1{\\gdef\\@trainno{#1}}
\\def\\trainyear#1{\\gdef\\@trainyear{#1}}
\\renewcommand{\\maketitle}{
  \\begin{center} {
    \\Large \\textbf{Ausbildungsnachweis}} \\\\[1em]
  \\end{center} \\vspace{1em}
  \\begin{tabularx}{\\textwidth}{X X }
    \\textbf{Author:} \\@author & \\textbf{Institut:} \\@institute \\\\
    \\textbf{Berichtszeitraum:} \\@timeframe  & \\textbf{Ausbildungsnachweis Nr.:}  \\@trainno \\\\
    \\textbf{Ausbildungsjahr:}  \\@trainyear  &  \\\\
  \\end{tabularx}
\\thispagestyle{fancy}
\\vspace{2em}}
\\makeatother\n
       "
       ;; Possibly limit depth for headline numbering.
       (let ((sec-num (plist-get info :section-numbers)))
         (when (integerp sec-num)
               (format "\\setcounter{secnumdepth}{%d}\n" sec-num)))
       ;; Author.
       (let ((author (and (plist-get info :with-author)
                                          (let ((auth (plist-get info :author)))
                                            (and auth (org-export-data auth info)))))
                 (email (and (plist-get info :with-email)
                                   (org-export-data (plist-get info :email) info))))
         (cond ((and author email (not (string= "" email)))
                    (format "\\author{%s\\thanks{%s}}\n" author email))
                   ((or author email) (format "\\author{%s}\n" (or author email)))))
       "\\trainyear{" trainyear "}\n"
       "\\trainno{" traino "}\n"
       "\\timeframe{" timeframe "}\n"
       "\\institute{" institute "}\n"
       ;; Date.
       ;; LaTeX displays today's date by default. One can override this by
       ;; inserting \date{} for no date, or \date{string} with any other
       ;; string to be displayed as the date.
       (let ((date (and (plist-get info :with-date) (org-export-get-date info))))
         (format "\\date{%s}\n" (org-export-data date info)))
       ;; Title and subtitle.
       (let* ((subtitle (plist-get info :subtitle))
                  (formatted-subtitle
                   (when subtitle
                     (format (plist-get info :latex-subtitle-format)
                                   (org-export-data subtitle info))))
                  (separate (plist-get info :latex-subtitle-separate)))
         (concat
              (format "\\title{%s%s}\n" title
                            (if separate "" (or formatted-subtitle "")))
              (when (and separate subtitle)
                (concat formatted-subtitle "\n"))))
       ;; Hyperref options.
       (let ((template (plist-get info :latex-hyperref-template)))
         (and (stringp template)
              (format-spec template spec)))
       ;; engrave-faces-latex preamble
       (when (and (eq (plist-get info :latex-src-block-backend) 'engraved)
                  (org-element-map (plist-get info :parse-tree)
                      '(src-block inline-src-block) #'identity
                      info t))
         (org-latex-generate-engraved-preamble info))
       ;; Document start.
       "\\begin{document}\n\n"
       ;; Title command.
       (let* ((title-command (plist-get info :latex-title-command))
              (command (and (stringp title-command)
                            (format-spec title-command spec))))
         (org-element-normalize-string
              (cond ((not (plist-get info :with-title)) nil)
                    ((string= "" title) nil)
                    ((not (stringp command)) nil)
                    ((string-match "\\(?:[^%]\\|^\\)%s" command)
                     (format command title))
                    (t command))))
       ;; Table of contents.
       (let ((depth (plist-get info :with-toc)))
         (when depth
               (concat (when (integerp depth)
                               (format "\\setcounter{tocdepth}{%d}\n" depth))
                             (plist-get info :latex-toc-command))))
       ;; Document's body.
       contents
       ;; Creator.
       (and (plist-get info :with-creator)
                (concat (plist-get info :creator) "\n"))
       "
\\vspace{1em}
 \\setlength\\extrarowheight{-3pt}
\\begin{tabularx}{\\textwidth}{X X}
    \\sigField{Auszubildender}{7.5cm}{2cm} & \\sigField{Ausbilder}{7.5cm}{2cm}  \\\\
\\hrulefill & \\hrulefill \\\\
Auszubildender & Ausbilder
\\end{tabularx}
"
       ;; Document end.
       "\\end{document}")))

  ;; Export commands
  (defun ausbildungsnachweis-export-as-latex (&optional async subtreep visible-only body-only ext-plist)
    "Export current buffer Org Ausbildungsnachweis to LaTeX buffer."
    (interactive)
    (org-export-to-buffer 'ausbildungsnachweis "*Org Ausbildungsnachweis Latex Export*"
      async subtreep visible-only body-only ext-plist
      (lambda () (LaTeX-mode))))

  (defun ausbildungsnachweis-export-to-latex (&optional async subtreep visible-only body-only ext-plist)
    "Export current buffer as Simple Memo LaTeX file."
    (interactive)
    (let ((outfile (org-export-output-file-name ".tex" subtreep)))
      (org-export-to-file 'ausbildungsnachweis outfile
        async subtreep visible-only body-only ext-plist)))

  (defun ausbildungsnachweis-export-to-pdf (&optional async subtreep visible-only body-only ext-plist)
    "Export current buffer as Simple Memo PDF file."
    (interactive)
    (let ((file (org-export-output-file-name ".tex" subtreep)))
      (org-export-to-file 'ausbildungsnachweis file
        async subtreep visible-only body-only ext-plist
        (lambda (file) (org-latex-compile file))))) )

(use-package org-noter
  :defer t
  :ensure t)

(use-package math-delimiters
  :ensure
  (:host github :repo "oantolin/math-delimiters")
  :config
  (with-eval-after-load 'org
    (define-key org-mode-map "$" #'math-delimiters-insert))
  (with-eval-after-load 'tex              ; for AUCTeX
    (define-key TeX-mode-map "$" #'math-delimiters-insert))
  (with-eval-after-load 'tex-mode         ; for the built-in TeX/LaTeX modes
    (define-key tex-mode-map "$" #'math-delimiters-insert))
  (with-eval-after-load 'cdlatex
    (define-key cdlatex-mode-map "$" nil)))

(use-package anki-editor
  :defer t
  :ensure
  (:host github :repo "anki-editor/anki-editor")
  :config
  (cl-defun slot/org-new-anki-node (&key type use-deck level)
  "Create a new anki node in any Org file.
If NAME is not specified, use a random 32-bit unsigned int for the
string.  If TYPE is \"Cloze\", insert a cloze deletion; if it is nil,
insert a \"Basic\" card template.  If USE-DECK is a string, use that
string as the deck name; otherwise, query the user.  LEVEL is the level
the headline should be set at; if this is nil, make a guess based on
'org-current-level'."
  (let ((lvl (or level
                 (max 1 (or (when (org-before-first-heading-p)
                              ;; If before any heading, default to level 1
                              1)
                            (progn (anki-editor--goto-nearest-note-type)
                                   (org-current-level))
                            0))))
        (type (or type "Basic"))
        (use-deck (when use-deck
                    (if (stringp use-deck)
                        use-deck
                      (completing-read "Deck: " (anki-editor-api-call-result 'deckNames))))))
    ;; Ensure we are at the correct point:
    (if (org-before-first-heading-p)
        (goto-char (point-max)) ;; Move to the end of the buffer if before first heading
      (if (org-at-heading-p)
          (org-end-of-subtree t t) ;; Move to the end of the current subtree if inside a heading
        (progn
          ;; Otherwise, go to the end of the last heading in the file
          (goto-char (point-max))
          (while (not (org-at-heading-p))
            (previous-line 1))
          (org-end-of-subtree t t)))) ;; Ensure insertion at the end of the last heading

    ;; Now insert the Anki node content
    (insert (concat (make-string lvl ?*) " " (int-to-string (cl-random (1- (expt 2 32))))))
    (insert (format "\n:PROPERTIES:%s\n:ANKI_NOTE_TYPE: %s\n:END:\n"
                    (if use-deck (format "\n:ANKI_DECK: %s" use-deck) "")
                    type))
    (if (string= type "Cloze")
        (insert (concat (make-string (1+ lvl) ?*) " Text"))
      (insert (concat (make-string (1+ lvl) ?*) " Front\n"))
      (insert (concat (make-string (1+ lvl) ?*) " Back\n"))
      (search-backward "Front"))
    (end-of-line)
    (newline)))

  (defun slot/org-new-anki-node-wrapper ()
    "Wrapper for `slot/org-new-anki-node' to make it callable interactively."
    (interactive)
    (slot/org-new-anki-node))

  ;; Key binding in anki-editor-mode-map
  :bind (:map anki-editor-mode-map
              ("C-c n" . slot/org-new-anki-node-wrapper)))

(use-package anki-editor-ui
  :ensure nil
  :defer t
  :after anki-editor
  :bind (:map anki-editor-mode-map
                    ("C-c e" . anki-editor-ui)))

(use-package auctex
  :defer t
  :ensure `(auctex :repo "https://git.savannah.gnu.org/git/auctex.git" :branch "main"
                   :pre-build (("make" "elpa"))
                   :build (:not elpaca--compile-info) ;; Make will take care of this step
                   :files ("*.el" "doc/*.info*" "etc" "images" "latex" "style")
                   :version (lambda (_) (require 'auctex) AUCTeX-version))
  :config
  (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-source-correlate-start-server t)

  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :magic ("%PDF" . pdf-view-mode)
  :defer t
  :ensure t
  :config
  (pdf-loader-install)
  (setq
   pdf-view-use-imagemagick nil)
  (defadvice! +pdf-suppress-large-file-prompts-a (fn size op-type filename &optional offer-raw)
              :around #'abort-if-file-too-large
              (unless (string-match-p "\\.pdf\\'" filename)
                (funcall fn size op-type filename offer-raw))))

(use-package saveplace-pdf-view
  :ensure t
  :after pdf-view)

(use-package sicp
  :ensure t
  :defer t)

(use-package markdown-mode
:ensure t
:mode ("README\\.md\\'" . gfm-mode)
:init (setq markdown-command "multimarkdown"))

(use-package transient
  :ensure t)
(use-package magit
  :ensure t
  :defer t
  :bind ("C-x g" . magit-status))

;; (use-package eglot-booster
;;   :ensure
;;   (eglot-booster :host github :repo "jdtsmith/eglot-booster")
;;    :after eglot
;;    :config
;;   (setq eglot-booster-io-only t)
;;   (eglot-booster-mode))

  (use-package breadcrumb
    :ensure t
    :hook (eglot-managed-mode . breadcrumb-local-mode))

(use-package eglot-java
  :ensure t
  :hook
  ((java-ts-mode java-mode) . eglot-java-mode)
  :bind (:map java-ts-mode-map
  ("C-c l n" . eglot-java-file-new)
  ("C-c l x" . eglot-java-run-main)
  ("C-c l t" . eglot-java-run-test)
  ("C-c l N" . eglot-java-project-new)
  ("C-c l T" . eglot-java-project-build-task)
  ("C-c l R" . eglot-java-project-build-refresh))
  :config
      ;; (setq eglot-java-server-install-dir (no-littering-expand-var-file-name "java/eclipse.jdt.ls/" ))
      ;; (setq eglot-java-eclipse-jdt-config-directory (no-littering-expand-var-file-name "java/eglot-java-eclipse-jdt-config/" ))
      ;; (setq eglot-java-eclipse-jdt-cache-directory (no-littering-expand-var-file-name "java/eglot-java-eclipse-jdt-cache/"))

  (setq eglot-java-user-init-opts-fn 'custom-eglot-java-init-opts)
(defun custom-eglot-java-init-opts ( &optional server eglot-java-eclipse-jdt)
  "Custom options that will be merged with any default settings."
  ;; :bundles ["/home/me/.emacs.d/lsp-bundles/com.microsoft.java.debug.plugin-0.50.0.jar"]
  `(:bundles [,(download-java-debug-plugin)]))

(defun download-java-debug-plugin ()
  (let ((cache-dir (expand-file-name "~/.cache/emacs/"))
        (url "https://repo1.maven.org/maven2/com/microsoft/java/com.microsoft.java.debug.plugin/maven-metadata.xml")
        (version nil)
        (jar-file-name nil)
        (jar-file nil))
    (unless (file-directory-p cache-dir)
      (make-directory cache-dir t))
    (setq jar-file (car (directory-files cache-dir nil "com\\.microsoft\\.java\\.debug\\.plugin-\\([0-9]+\\.[0-9]+\\.[0-9]+\\)\\.jar" t)))
    (if jar-file
        (expand-file-name jar-file cache-dir)
      (with-temp-buffer
        (url-insert-file-contents url)
        (when (re-search-forward "<latest>\\(.*?\\)</latest>" nil t)
          (setq version (match-string 1))
          (setq jar-file-name (format "com.microsoft.java.debug.plugin-%s.jar" version))
          (setq jar-file (expand-file-name jar-file-name cache-dir))
          (unless (file-exists-p jar-file)
            (setq url (format "https://repo1.maven.org/maven2/com/microsoft/java/com.microsoft.java.debug.plugin/%s/%s"
                              version jar-file-name))
            (message url)
            (url-copy-file url jar-file))
          jar-file)))))
  )

(use-package dape
  :ensure t
  :after eglot
  :config
    (setq dape-buffer-window-arrangement 'right)
  ;; (setq dape-buffer-window-arrangement 'gud)
  (setq dape-info-hide-mode-line nil)
  ;; Showing inlay hints
  ;; (setq dape-inlay-hints t)
  ;; Save buffers on startup, useful for interpreted languages
  ;; (add-hook 'dape-start-hook (lambda () (save-some-buffers t t)))
  ;; Kill compile buffer on build success
  ;; (add-hook 'dape-compile-hook 'kill-buffer)
  ;; (setq dape-cwd-function 'projectile-project-root)
(add-to-list 'dape-configs
               `(junit
                 modes (java-mode java-ts-mode)
                 ensure (lambda (config)
                          (save-excursion
                            (unless (eglot-current-server)
                              (user-error "No eglot instance active in buffer %s" (current-buffer)))
                            (when (equal ':json-false
                                         (eglot-execute-command
                                          (eglot-java--find-server)
                                          "java.project.isTestFile"
                                          (vector (eglot--path-to-uri (buffer-file-name)))))
                              (user-error "Not in a java test file"))
                            t))
                 fn (lambda (config)
                      (let ((file (expand-file-name (plist-get config :program)
                                                    (project-root (project-current)))))
                        (with-current-buffer (find-file-noselect file)
                          (save-excursion (eglot-java-run-test t))
                          (thread-first
                            config
                            (plist-put 'hostname "localhost")
                            (plist-put 'port (eglot-execute-command (eglot-current-server)
                                                                    "vscode.java.startDebugSession" nil))
                            (plist-put :projectName (project-name (project-current)))))))
                 :program dape-buffer-default
                 :request "attach"
                 :hostname "localhost"
                 :port 8000))


  )

(use-package repeat
  :config
  (repeat-mode))

(use-package python-isort
  :ensure t)

(use-package ruff-format
  :ensure t)

;; (use-package flymake-ruff
;;   :ensure t
;;   :hook (eglot-managed-mode . flymake-ruff-load))

;; (use-package py-vterm-interaction
;;   :ensure t
;;   :config
;;   (setq py-vterm-interaction-repl-program "ipython")
;;   (setq py-vterm-interaction-silent-cells t))

(use-package pet
  :ensure t
  :config
  (add-hook 'python-ts-mode-hook
            (lambda ()
              ;; (setq-local python-shell-interpreter (pet-executable-find "ipython")
              ;;             python-shell-virtualenv-root (pet-virtualenv-root)
              ;;             python-shell-interpreter-args "-i --simple-prompt")

              (setq-local py-vterm-interaction-repl-program (pet-executable-find "ipython")
                          py-vterm-interaction-context (pet-virtualenv-root)
                          py-vterm-interaction-silent-cells t)
              (py-vterm-interaction-mode)
              (pet-eglot-setup)

              (eglot-ensure)

              (when-let ((ruff-executable (pet-executable-find "ruff")))
                (setq-local ruff-format-command ruff-executable)
                (ruff-format-on-save-mode))
              (when-let ((isort-executable (pet-executable-find "isort")))
                (setq-local python-isort-command isort-executable)
                (python-isort-on-save-mode)))))

(use-package julia-ts-mode
  :ensure t
  :mode "\\.jl$")


(use-package eglot-jl
  :ensure t
  :hook (julia-ts-mode . (lambda ()
                           (eglot-jl-init)
                           (eglot-ensure))))

(use-package julia-snail
  :ensure t
  :hook (julia-ts-mode . julia-snail-mode)
  :custom
  (julia-snail-extensions '(debug))) ;;

(use-package geiser-mit
  :ensure t
  :defer t)

(use-package sly
  :ensure t
  :defer t)

(use-package flymake-flycheck
  :ensure t
  :defer t)

(with-eval-after-load 'flymake
  ;; Provide some flycheck-like bindings in flymake mode to ease transition
  (define-key flymake-mode-map (kbd "C-c ! l") 'flymake-show-buffer-diagnostics)
  (define-key flymake-mode-map (kbd "C-c ! n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-c ! p") 'flymake-goto-prev-error)
  (define-key flymake-mode-map (kbd "C-c ! c") 'flymake-start))

(use-package jinx
:defer t
:ensure t
:bind-keymap (("M-$" . jinx-correct)
       ("C-M-$" . jinx-languages)))

(use-package langtool
  :ensure t
  :init
  (setq langtool-java-classpath
    "/usr/share/languagetool:/usr/share/java/languagetool/*")
  :commands
  (langtool-check))
;; (use-package flymake-languagetool
;;   :ensure t
;;   :defer t
;;   :hook (org-mode . flymake-languagetool-load)
;;   :init
;;   (setq flymake-languagetool-server-jar "~/.local/bin/LanguageTool-6.5/languagetool-server.jar"))

(setq gc-cons-threshold (* 4 1000 1000))
;;END OF INIT FILE
(setq elpaca-after-init-time (or elpaca-after-init-time (current-time)))
(elpaca-wait)
