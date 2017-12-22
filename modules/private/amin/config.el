;;; private/amin/config.el -*- lexical-binding: t; -*-

(setq auth-sources (list "~/.authinfo.gpg" ))

(map!
 "C-s" #'swiper
 "C-S-l" #'recenter
 "C-x C-b" #'ibuffer
 [C-S-return] #'recompile
 :n "gl" #'recenter
 :n "/" #'swiper
 ;; "C-=" #'count-words-region
 (:leader
   :n "cq" #'fill-paragraph
   :n "ca" #'auto-fill-mode
   :n "cc" #'count-words-region
   )
 (:leader
   :desc "dashboard" :n "d" #'+doom-dashboard/open
   :desc "Centered Window Mode" :n "C" #'centered-window-mode
   (:desc "Dumb Jump" :prefix "j"
     :desc "Go" :n "j" #'dumb-jump-go
     :desc "Back" :n "k" #'dumb-jump-back)))

;; (after! evil-escape
;;   ;; Change the evil escape sequence to fd instead of jk
;;   (setq evil-escape-key-sequence "fd"))

(after! dumb-jump
  (setq dumb-jump-force-searcher 'rg))

(map! :map emmet-mode-keymap
      :i [C-return] #'emmet-expand-yas)

(def-package! magit-svn
  :after magit)

(setq TeX-PDF-mode t                  ; use pdflatex instead of latex
      TeX-engine 'xetex)

;; Support zathura in TeX mode
(setq TeX-view-program-selection
      '(((output-dvi style-pstricks)
         "dvips and gv")
        (output-dvi "xdvi")
        (output-pdf "Zathura")
        (output-html "xdg-open")))
;; (setq TeX-view-program-list
;;       '(("zathura"
;;          ("zathura" (mode-io-correlate "-sync.sh")
;;           " "
;;           (mode-io-correlate "%n:1:%t ")
;;           "%o"))))

(def-package! auctex-latexmk             ; latexmk command for AUCTeX
  :after latex
  :config
  (auctex-latexmk-setup)

  (if (< emacs-major-version 24)
    (defun file-name-base (&optional filename)
      "Return the base name of the FILENAME: no directory, no extension.
FILENAME defaults to `buffer-file-name'."
      (file-name-sans-extension
       (file-name-nondirectory (or filename (buffer-file-name))))))

  ;; Recompile with latexmk -xelatex on save
  ;; (add-hook 'after-save-hook
  ;;           (lambda ()
  ;;             (when (string= major-mode 'latex-mode)
  ;;               (TeX-run-latexmk
  ;;                "LaTeX"
  ;;                (format "latexmk -xelatex %s" (buffer-file-name))
  ;;                (file-name-base (buffer-file-name))))))
  )

(def-package! ripgrep
  :commands ripgrep-regexp)

(def-package! projectile-ripgrep
  :after projectile
  :commands projectile-ripgrep)

;; (def-package! visual-fill-column
;;   :init
;;   (dolist (hook '(prog-mode-hook
;;                   text-mode-hook
;;                   ;; notmuch-show-hook
;;                   ;; haskell-cabal-mode-hook
;;                   ))
;;     (add-hook hook #'visual-fill-column-mode))
;;   :config
;;   ;; Center text by default and move the fringes close to the text.
;;   (setq-default visual-fill-column-center-text t
;;                 visual-fill-column-fringes-outside-margins nil
;;                 ;; take into account the line numbers in Emacs 26
;;                 visual-fill-column-width (+ fill-column 6))
;;   ;; Split windows vertically despite large margins, because Emacs otherwise
;;   ;; refuses to vertically split windows with large margins
;;   (setq split-window-preferred-function
;;         #'visual-fill-column-split-window-sensibly))

(after! org-mode
  (remove-hook 'org-mode-hook #'visual-line-mode))

(after! web-mode
  (defun my-web-mode-hook ()
  "Hook for Web mode."
  (setq web-mode-markup-indent-offset 1
        web-mode-code-indent-offset 1
        web-mode-css-indent-offset 1))
  (add-hook 'web-mode-hook  'my-web-mode-hook))

(add-to-list 'magic-mode-alist '("<!doctype html>" . web-mode))

(setq tramp-default-method "ssh")

(defun haskell-style ()
  "Sets the current buffer to use Haskell Style. Meant to be
  added to `haskell-mode-hook'"
  (interactive)
  (setq tab-width 2
        haskell-indentation-layout-offset 2
        haskell-indentation-left-offset 2
        haskell-indentation-ifte-offset 2))

(add-hook 'haskell-mode-hook 'haskell-style)

;; (after! org
;;   (setq-default org-indent-indentation-per-level 4))

(def-package! exec-path-from-shell
  :defer 1
  :init
  (setq exec-path-from-shell-check-startup-files nil)
  :config
  (exec-path-from-shell-copy-env "SSH_AGENT_PID")
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))

;; (require 'gruvbox-theme)
;; (require 'gruvbox-light-hard-theme)
;; (require 'gruvbox-dark-medium-theme)

;; (require 'tao-theme)
;; (require 'tao-yang-theme)
;; (require 'tao-yin-theme)

;; (require 'flatui-theme)

