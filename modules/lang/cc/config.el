;;; lang/cc/config.el --- c, c++, and obj-c -*- lexical-binding: t; -*-

(def-package! cc-mode
  :commands (c-mode c++-mode objc-mode java-mode)
  :mode ("\\.mm" . objc-mode)
  :init
  (setq-default c-basic-offset tab-width)

  (defun +cc--c++-header-file-p ()
    (and buffer-file-name
         (equal (file-name-extension buffer-file-name) "h")
         (or (file-exists-p (expand-file-name
                             (concat (file-name-sans-extension buffer-file-name)
                                     ".cpp")))
             (when-let (file (car-safe (projectile-get-other-files
                                        buffer-file-name
                                        (projectile-current-project-files))))
               (equal (file-name-extension file) "cpp")))))

  (defun +cc--objc-header-file-p ()
    (and buffer-file-name
         (equal (file-name-extension buffer-file-name) "h")
         (re-search-forward "@\\<interface\\>" magic-mode-regexp-match-limit t)))

  ;; Auto-detect C++/Obj-C header files
  (push (cons #'+cc--c++-header-file-p  'c++-mode)  magic-mode-alist)
  (push (cons #'+cc--objc-header-file-p 'objc-mode) magic-mode-alist)

  :config
  (set! :electric '(c-mode c++-mode objc-mode java-mode)
        :chars '(?\n ?\}))
  (set! :company-backend
        '(c-mode c++-mode objc-mode)
        '(company-irony-c-headers company-irony))

  ;;; Style/formatting
  ;; C/C++ style settings
  (c-toggle-electric-state -1)
  (c-toggle-auto-newline -1)
  (c-set-offset 'substatement-open '0) ; brackets should be at same indentation level as the statements they open
  (c-set-offset 'inline-open '+)
  (c-set-offset 'block-open '+)
  (c-set-offset 'brace-list-open '+)   ; all "opens" should be indented by the c-indent-level
  (c-set-offset 'case-label '+)        ; indent case labels by c-indent-level, too
  (c-set-offset 'access-label '-)
  (c-set-offset 'arglist-intro '+)
  (c-set-offset 'arglist-close '0)
  ;; Indent privacy keywords at same level as class properties
  ;; (c-set-offset 'inclass #'+cc-c-lineup-inclass)

  ;;; Better fontification (also see `modern-cpp-font-lock')
  (add-hook 'c-mode-common-hook #'rainbow-delimiters-mode)
  (add-hook! (c-mode c++-mode) #'highlight-numbers-mode)
  (add-hook! (c-mode c++-mode) #'+cc|fontify-constants)

  ;; Improve indentation of inline lambdas in C++11
  (advice-add #'c-lineup-arglist :around #'+cc*align-lambda-arglist)

  ;;; Keybindings
  ;; Completely disable electric keys because it interferes with smartparens and
  ;; custom bindings. We'll do this ourselves.
  (setq c-tab-always-indent nil
        c-electric-flag nil)
  (dolist (key '("#" "{" "}" "/" "*" ";" "," ":" "(" ")"))
    (define-key c-mode-base-map key nil))
  ;; Smartparens and cc-mode both try to autoclose angle-brackets intelligently.
  ;; The result isn't very intelligent (causes redundant characters), so just do
  ;; it ourselves.
  (map! :map c++-mode-map
        "<" nil
        :i ">" #'+cc/autoclose->-maybe)

  ;; ...and leave it to smartparens
  (sp-with-modes '(c-mode c++-mode objc-mode java-mode)
    (sp-local-pair "<" ">" :when '(+cc-sp-point-is-template-p +cc-sp-point-after-include-p))
    (sp-local-pair "/*" "*/" :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
    ;; Doxygen blocks
    (sp-local-pair "/**" "*/" :post-handlers '(("||\n[i]" "RET") ("||\n[i]" "SPC")))
    (sp-local-pair "/*!" "*/" :post-handlers '(("||\n[i]" "RET") ("[d-1]< | " "SPC")))))


(def-package! modern-cpp-font-lock
  :commands modern-c++-font-lock-mode
  :init (add-hook 'c++-mode-hook #'modern-c++-font-lock-mode))


(def-package! irony
  :after cc-mode
  :commands irony-install-server
  :preface
  (setq irony-server-install-prefix (concat doom-etc-dir "irony-server/"))
  :init
  (defun +cc|init-irony-mode ()
    ;; The major-mode check is necessary because some modes derive themselves
    ;; from a c base mode, like java-mode or php-mode.
    (when (and (memq major-mode '(c-mode c++-mode objc-mode))
               (file-directory-p irony-server-install-prefix))
      (irony-mode +1)))
  (add-hook 'c-mode-common-hook #'+cc|init-irony-mode)
  :config
  (make-variable-buffer-local 'irony-additional-clang-options)
  ;; Add nearest include/ path to compiler options
  (add-hook! '(c-mode-hook c++-mode-hook) #'+cc|irony-add-include-paths)
  ;; Use C++11/14 by default
  (add-hook 'c++-mode-hook #'+cc|use-c++11))

(def-package! irony-eldoc
  :after irony
  :config (add-hook 'irony-mode-hook #'irony-eldoc))

(def-package! flycheck-irony
  :when (featurep! :feature syntax-checker)
  :after irony
  :config
  (add-hook 'irony-mode-hook #'flycheck-mode)
  (flycheck-irony-setup))


;;
;; Tools
;;

(def-package! disaster :commands disaster)


;;
;; Major modes
;;

(def-package! cmake-mode
  :mode "CMakeLists\\.txt$"
  :config
  (set! :company-backend 'cmake-mode '(company-cmake company-yasnippet)))

(def-package! cuda-mode :mode "\\.cuh?$")

(def-package! opencl-mode :mode "\\.cl$")

(def-package! demangle-mode
  :commands demangle-mode
  :init (add-hook 'llvm-mode-hook #'demangle-mode))

(def-package! glsl-mode
  :mode "\\.glsl$"
  :mode "\\.vert$"
  :mode "\\.frag$"
  :mode "\\.geom$")


;;
;; Plugins
;;

(when (featurep! :completion company)
  (def-package! company-cmake :after cmake-mode)

  (def-package! company-irony :after irony)

  (def-package! company-irony-c-headers :after company-irony)

  (def-package! company-glsl
    :when (featurep! :completion company)
    :after glsl-mode
    :config
    (if (executable-find "glslangValidator")
        (warn "glsl-mode: couldn't find glslangValidator, disabling company-glsl")
      (set! :company-backend 'glsl-mode '(company-glsl)))))
