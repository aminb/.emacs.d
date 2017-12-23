;; -*- no-byte-compile: t; -*-
;;; private/amin/packages.el

(package! emacs-snippets
  :recipe (:fetcher github
           :repo "hlissner/emacs-snippets"
           :files ("*")))

(package! magit-svn)
(package! auctex-latexmk)
;; (package! gruvbox-theme)
;; (package! tao-theme)
;; (package! flatui-theme)

(package! visual-fill-column)

(package! exec-path-from-shell)

(package! page-break-lines)
