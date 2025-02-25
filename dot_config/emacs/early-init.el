;; -*- no-byte-compile: t; no-native-compile: t; no-update-autoloads: t; lexical-binding: t -*-
  (setq package-enable-at-startup nil)

  (setq frame-resize-pixelwise t)
  (setq frame-inhibit-implied-resize t)

  (menu-bar-mode -1) ;; disables menubar
  (tool-bar-mode -1) ;; disables toolbar
  (scroll-bar-mode -1) ;; disables scrollbar
  (tooltip-mode -1)
  (push '(menu-bar-lines . 0) default-frame-alist)
  (push '(tool-bar-lines . 0) default-frame-alist)
  (push '(vertical-scroll-bars) default-frame-alist)

(setq scroll-conservatively 1000)

(global-subword-mode 1)

(setq-default sentence-end-double-space nil)

(setq-default vc-follow-symlinks t)

  (recentf-mode 1)
  (electric-pair-mode 1)

  (defun efs/set-font-faces ()
    (message "Setting faces!")
    (set-face-attribute 'default nil :font "Iosevka Comfy" :height 100)

    ;; Set the fixed pitch face
    (set-face-attribute 'fixed-pitch nil :font "Iosevka Comfy" :height 100))

  (if (daemonp)
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (with-selected-frame frame
                    (efs/set-font-faces))))
    (efs/set-font-faces))
    ;;; early-init.el ends here
