;;; private/amin/config.el -*- lexical-binding: t; -*-

(load! +bindings) ; my key bindings
(load! +commands) ; my custom ex commands (with much inspiration from hlissner)


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

;; feature/snippets
(defvar +amin-dir (file-name-directory load-file-name))
(defvar +amin-snippets-dir (expand-file-name "snippets/" +amin-dir))
(after! yasnippet
  ;; Don't use default snippets, use mine
  (setq yas-snippet-dirs
        (append (list '+amin-snippets-dir)
                (delq 'yas-installed-snippets-dir yas-snippet-dirs))))

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

;; core/core-ui -- distraction-free and centered editing
(def-package! visual-fill-column
  :init
  (dolist (hook '(prog-mode-hook
                  text-mode-hook
                  ;; notmuch-show-hook
                  ;; haskell-cabal-mode-hook
                  ))
    (add-hook hook #'visual-fill-column-mode))
  :config
  ;; Center text by default and move the fringes close to the text.
  (setq-default visual-fill-column-center-text t
                visual-fill-column-fringes-outside-margins nil
                ;; take into account the line numbers in Emacs 26
                visual-fill-column-width (+ fill-column 6))
  ;; Split windows vertically despite large margins, because Emacs otherwise
  ;; refuses to vertically split windows with large margins
  (setq split-window-preferred-function
        #'visual-fill-column-split-window-sensibly))

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

(after! magit
  ;; Set Magit's repo dirs for `magit-status' from Projectile's known projects.
  ;; Initialize the `magit-repository-directories' immediately after Projectile
  ;; was loaded, and update it every time we switch projects, because the new
  ;; project might have been unknown before.
  (defun magit-set-repo-dirs-from-projectile ()
    "Set `magit-repo-dirs' from known Projectile projects."
    (let ((project-dirs (bound-and-true-p projectile-known-projects)))
      ;; Remove trailing slashes from project directories, because
      ;; Magit adds trailing slashes again, which breaks the
      ;; presentation in the Magit prompt.
      (setq magit-repository-directories
            (mapcar #'directory-file-name project-dirs))))

  (with-eval-after-load 'projectile
    (magit-set-repo-dirs-from-projectile))

  (add-hook 'projectile-switch-project-hook
            #'magit-set-repo-dirs-from-projectile))
