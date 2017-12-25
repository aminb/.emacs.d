;;; private/amin/config.el -*- lexical-binding: t; -*-

;;
;; Global config
;;

(setq epa-file-encrypt-to user-mail-address
      auth-sources (list "~/.authinfo.gpg")
      ;; +doom-modeline-buffer-file-name-style 'file-name
      +doom-modeline-buffer-file-name-style 'relative-from-project
      tramp-default-method "ssh")

(defun +hlissner*no-authinfo-for-tramp (orig-fn &rest args)
  "Don't look into .authinfo for local sudo TRAMP buffers."
  (let ((auth-sources (if (equal tramp-current-method "sudo") nil auth-sources)))
    (apply orig-fn args)))
(advice-add #'tramp-read-passwd :around #'+hlissner*no-authinfo-for-tramp)


;;
;; Keybindings
;;

(map!
 :ne "M-b" #'backward-word
 :ne "M-f" #'forward-word
 :ne "M-q" #'fill-paragraph

 "C-c <left>"  #'winner-undo
 "C-c <right>" #'winner-redo
 "C-s"         #'swiper
 "C-x C-b"     #'ibuffer
 [C-S-return]  #'recompile
 :e "C-S-l"    #'recenter
 :n "/"        #'swiper

 (:leader
   :desc "Dashboard" :n "d" #'+doom-dashboard/open
   :desc "Centered"  :n "C" #'centered-window-mode

   (:desc "buffer" :prefix "b"
     :desc "Ibuffer" :n "i" #'ibuffer)

   (:desc "git" :prefix "g"
     :desc "Git status"          :n "SPC" #'magit-status
     :desc "Git status (prefix)" :n "S"   #'magit-status-prefix
     :desc "Git blame"           :n "B"   #'magit-blame
     :desc "Git clone"           :n "C"   #'magit-clone
     :desc "Git fetch"           :n "f"   #'magit-fetch
     :desc "Git pull"            :n "F"   #'magit-pull
     :desc "Git push"            :n "P"   #'magit-push
     (:desc "Git commit" :prefix "c"
       :desc "commit" :n "c" #'magit-commit
       :desc "amend"  :n "a" #'magit-commit-amend)
     :n "b" nil  ; unbind SPC g b
     (:desc "Git branch" :prefix "b"
       :desc "checkout" :n "b" #'magit-checkout
       :desc "create"   :n "c" #'magit-branch))

   (:desc "project" :prefix "p"
     :desc "Search project with rg" :n "SPC" #'counsel-projectile-rg)

   (:desc "dumb-jump" :prefix "j"
     :desc "Go"   :n "j" #'dumb-jump-go
     :desc "Back" :n "k" #'dumb-jump-back)

   (:desc "app" :prefix "a"
     (:desc "shell" :prefix "s"
       :desc "eshell"     :n "e" #'+eshell:run
       :desc "multi-term" :n "m" #'multi-term))

   :n "cq" #'fill-paragraph
   :n "ca" #'auto-fill-mode
   :n "cc" #'count-words-region)

 (:after ivy
   :map ivy-minibuffer-map
   "TAB" #'ivy-partial-or-done)

 (:after emmet
   (:map emmet-mode-keymap
     :i [C-return] #'emmet-expand-yas)))


;;
;; Modules
;;

(after! smartparens
  ;; Auto-close more conservatively and expand braces on RET
  (let ((unless-list '(sp-point-before-word-p
                       sp-point-after-word-p
                       sp-point-before-same-p)))
    (sp-pair "'"  nil :unless unless-list)
    (sp-pair "\"" nil :unless unless-list))
  (sp-pair "{" nil :post-handlers '(("||\n[i]" "RET") ("| " " "))
           :unless '(sp-point-before-word-p sp-point-before-same-p))
  (sp-pair "(" nil :post-handlers '(("||\n[i]" "RET") ("| " " "))
           :unless '(sp-point-before-word-p sp-point-before-same-p))
  (sp-pair "[" nil :post-handlers '(("| " " "))
           :unless '(sp-point-before-word-p sp-point-before-same-p)))

;; feature/evil
(after! evil-mc
  ;; Make evil-mc resume its cursors when I switch to insert mode
  (add-hook! 'evil-mc-before-cursors-created
    (add-hook 'evil-insert-state-entry-hook #'evil-mc-resume-cursors nil t))
  (add-hook! 'evil-mc-after-cursors-deleted
    (remove-hook 'evil-insert-state-entry-hook #'evil-mc-resume-cursors t)))

;; completion/helm
(after! helm
  ;; Hide header lines in helm
  (set-face-attribute 'helm-source-header nil :height 0.1))

;; lang/org
(after! org-bullets
  ;; The standard unicode characters are usually misaligned depending on the
  ;; font. This bugs me. Personally, markdown #-marks for headlines are more
  ;; elegant, so we use those.
  (setq org-bullets-bullet-list '("#")))

;; core/core-ui -- disable line numbers
(remove-hook! (prog-mode text-mode conf-mode) #'doom|enable-line-numbers)

;; lang/latex
(setq TeX-PDF-mode t     ; use PDFTeX
      TeX-engine 'xetex  ; use pdflatex instead of latex

      TeX-view-program-selection  ; support zathura for TeX view
      '(((output-dvi style-pstricks)
         "dvips and gv")
        (output-dvi "xdvi")
        (output-pdf "Zathura")
        (output-html "xdg-open")))

(def-package! auctex-latexmk  ; latexmk command for AUCTeX
  :after latex
  :config
  (auctex-latexmk-setup)

  (if (< emacs-major-version 24)
    (defun file-name-base (&optional filename)
      "Return the base name of the FILENAME: no directory, no extension.
FILENAME defaults to `buffer-file-name'."
      (file-name-sans-extension
       (file-name-nondirectory (or filename (buffer-file-name))))))

  ;; Recompile with `latexmk -xelatex' on save
  ;; (add-hook 'after-save-hook
  ;;           (lambda ()
  ;;             (when (string= major-mode 'latex-mode)
  ;;               (TeX-run-latexmk
  ;;                "LaTeX"
  ;;                (format "latexmk -xelatex %s" (buffer-file-name))
  ;;                (file-name-base (buffer-file-name))))))
  )

;; feature/jump
(after! dumb-jump
  (setq dumb-jump-force-searcher 'rg))

;; ;; core/core-ui -- distraction-free and centered editing
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

;; lang/org
(after! org-mode
  (remove-hook 'org-mode-hook #'visual-line-mode))

;; (after! org
;;   (setq-default org-indent-indentation-per-level 4))

;; lang/web
(after! web-mode
  (defun my-web-mode-hook ()
  "Hook for Web mode."
  (setq web-mode-markup-indent-offset 1
        web-mode-code-indent-offset 1
        web-mode-css-indent-offset 1))
  (add-hook 'web-mode-hook  'my-web-mode-hook))

(add-to-list 'magic-mode-alist '("<!doctype html>" . web-mode))

;; lang/haskell
(defun haskell-style ()
  "Sets the current buffer to use Haskell Style. Meant to be
  added to `haskell-mode-hook'"
  (interactive)
  (setq tab-width 2
        haskell-indentation-layout-offset 2
        haskell-indentation-left-offset 2
        haskell-indentation-ifte-offset 2))

(add-hook 'haskell-mode-hook #'haskell-style)

;; core/core-os
(def-package! exec-path-from-shell
  :defer 1
  :init
  (setq exec-path-from-shell-check-startup-files nil)
  :config
  (exec-path-from-shell-copy-env "SSH_AGENT_PID")
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))

;; completion/ivy
(after! ivy
  (setq ivy-magic-slash-non-match-action 'ivy-magic-slash-non-match-cd-selected))

;; core/core-ui
(def-package! page-break-lines
  :config (global-page-break-lines-mode))

;; feature/version-control
(def-package! magit
  :commands (magit-clone))

(after! magit
  ;; Set Magit's repo dirs for `magit-status' manually. Remove trailing slashes
  ;; from project directories, because Magit adds trailing slashes again, which
  ;; breaks the presentation in the Magit prompt.
  (setq magit-repository-directories
        '(("~/.emacs.d" . 0)
          ("~/dotfiles" . 0)
          ("~/src"      . 2))))

(defun magit-status-prefix ()
  "Always call `magit-status' with prefix arg. This will cause
magit to ask for a repository even if the current directory is
already a repository. This is handy when wanting to switch over
to another project."
  (interactive)
  (let ((current-prefix-arg t))
    (call-interactively 'magit-status)))


;; lang/nix
(def-package! nix-mode)

(def-package! dired+
  :config (diredp-toggle-find-file-reuse-dir 1))
