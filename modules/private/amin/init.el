;;; private/amin/init.el -*- lexical-binding: t; -*-

;; This is a special file, unique to private modules, that is loaded after DOOM
;; core but before any module is activated, giving you an opportunity to
;; overwrite variables or settings before initialization.

;; (setq mac-command-modifier 'super
;;       mac-option-modifier 'meta
;;       mac-function-modifier 'hyper)

(setq user-mail-address "amin@aminb.org"
      user-full-name    "Amin Bandali")

(setq +doom-modeline-height 32 ;; 36
      ;; doom-font (font-spec :family "Triplicate T4C" :size 15)
      ;; doom-font (font-spec :family "Ubuntu Mono" :size 15)
      ;; doom-font (font-spec :family "Source Code Pro" :size 14)
      ;; doom-font (font-spec :family "Iosevka" :size 16 :weight 'semi-light)
      ;; doom-font (font-spec :family "Iosevka" :size 16 :weight 'normal)
      ;; doom-font (font-spec :family "Iosevka" :size 15 :weight 'normal)
      ;; doom-font (font-spec :family "Inconsolata" :size 16)
      ;; doom-font (font-spec :family "Ubuntu Mono" :size 16)
      ;; doom-font (font-spec :family "Inconsolata LGC" :size 14)
      doom-variable-pitch-font (font-spec :family "Concourse T4" :size 15)
      ;; doom-variable-pitch-font (font-spec :family "Lato" :size 14)
      doom-unicode-font (font-spec :family "DejaVu Sans Mono" :size 12)
      ;; doom-theme 'doom-one-light
      ;; doom-theme 'doom-tomorrow-night
      ;; doom-theme 'leuven
      ;; doom-theme 'material-light
      ;; doom-theme 'ample-light
      ;; doom-theme 'sanityinc-tomorrow-day
      ;; doom-theme 'flatui
      ;; doom-theme 'minimal
      ;; doom-theme 'minimal-light
      ;; doom-theme 'solarized-light
      ;; doom-theme 'spacemacs-light
      ;; doom-theme 'spacemacs-dark
      ;; doom-theme 'eziam-light
      ;; doom-theme 'nubox-light
      ;; doom-theme 'zerodark
      ;; doom-theme 'gruvbox-dark-medium
      doom-theme 'gruvbox-light-hard
      ;; doom-theme 'gruvbox-light-medium
      text-scale-mode-step 1.05
      ;; nlinum-format "%3d "
      ;; +doom-modeline-buffer-file-name-style 'file-name
      )

(setq-default fill-column 80)

;; (when window-system (set-frame-size (selected-frame) 160 60))
