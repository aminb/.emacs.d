;;; private/amin/init.el -*- lexical-binding: t; -*-

;; This is a special file, unique to private modules, that is loaded after DOOM
;; core but before any module is activated, giving you an opportunity to
;; overwrite variables or settings before initialization.

;; An extra measure to prevent the flash of unstyled mode-line while Emacs is
;; booting up (when Doom is byte-compiled).
(setq-default mode-line-format nil)

(setq user-mail-address "amin@aminb.org"
      user-full-name    "Amin Bandali")

(setq +doom-modeline-height 36 ;; 32
      doom-font (font-spec :family "Hack" :size 14)
      doom-variable-pitch-font (font-spec :family "Concourse T4" :size 15)
      doom-unicode-font (font-spec :family "Hack" :size 14)
      ;; doom-theme 'gruvbox-dark-medium
      ;; doom-theme 'gruvbox-light-hard
      ;; doom-theme 'tao-yang
      ;; doom-theme 'tao-yin
      ;; doom-theme 'flatui
      doom-theme 'doom-one-light
      text-scale-mode-step 1.05
      org-ellipsis "  "
      )

(setq-default fill-column 80
              ;; bidi-display-reordering t
              frame-inhibit-implied-resize nil)

