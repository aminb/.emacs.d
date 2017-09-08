;;; private/amin/init.el -*- lexical-binding: t; -*-

;; This is a special file, unique to private modules, that is loaded after DOOM
;; core but before any module is activated, giving you an opportunity to
;; overwrite variables or settings before initialization.

(setq user-mail-address "amin@aminb.org"
      user-full-name    "Amin Bandali")

(setq +doom-modeline-height 32 ;; 36
      doom-variable-pitch-font (font-spec :family "Concourse T4" :size 15)
      doom-unicode-font (font-spec :family "DejaVu Sans Mono" :size 12)
      ;; doom-theme 'gruvbox-dark-medium
      doom-theme 'gruvbox-light-hard
      text-scale-mode-step 1.05
      ;; +doom-modeline-buffer-file-name-style 'file-name
      )

(setq-default fill-column 80
              ;; bidi-display-reordering t
              frame-inhibit-implied-resize nil)

