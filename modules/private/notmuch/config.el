;;; private/notmuch/config.el -*- lexical-binding: t; -*-

(load! +bindings)

(defvar maildir "~/mail")

(def-package! smtpmail
  :config
  (setq smtpmail-default-smtp-server "nix.aminb.org"
        smtpmail-local-domain "aminb.org"
        smtpmail-smtp-server "nix.aminb.org"
        smtpmail-stream-type 'starttls
        smtpmail-smtp-service 587))

(def-package! sendmail
  :config
  (setq send-mail-function 'smtpmail-send-it))

(def-package! message
  :config
  (setq message-kill-buffer-on-exit t
        message-directory "drafts"
        message-user-fqdn "aminb.org")
  (add-hook 'message-mode-hook
            '(lambda () (setq fill-column 65))
            'append)
  (add-hook 'message-setup-hook
            #'mml-secure-message-sign-pgpmime))

(after! mml-sec
  (setq mml-secure-openpgp-encrypt-to-self t
        mml-secure-openpgp-sign-with-sender t))

(def-package! notmuch
  :config
  (setq notmuch-hello-sections
        '(notmuch-hello-insert-header
          notmuch-hello-insert-saved-searches
          ;; notmuch-hello-insert-search
          notmuch-hello-insert-alltags)
        notmuch-search-oldest-first nil
        notmuch-show-all-tags-list t
        notmuch-hello-thousands-separator ","
        notmuch-fcc-dirs
        '(("amin@aminb.org" . "amin/Sent")
          ("aminb@gnu.org"  . "gnu/Sent")
          (".*"             . "sent")))
  ;; (set! :popup
  ;;   '("\\`\\*notmuch.*?\\*\\'" :popup t))
  )

(after! notmuch-crypto
  (setq notmuch-crypto-process-mime t))

(after! notmuch-hello
  (define-key notmuch-hello-mode-map "g"
    'notmuch-poll-and-refresh-this-buffer)

  (define-key notmuch-hello-mode-map "i"
    (lambda ()
      "Search for `inbox' tagged messages."
      (interactive)
      (notmuch-hello-search "tag:inbox")))

  (define-key notmuch-hello-mode-map "u"
    (lambda ()
      "Search for `unread' tagged messages."
      (interactive)
      (notmuch-hello-search "tag:unread"))))

(after! notmuch
  (define-key notmuch-search-mode-map "g"
    'notmuch-poll-and-refresh-this-buffer)

  (define-key notmuch-search-mode-map "k"
    (lambda ()
      "Mark message read."
      (interactive)
      (notmuch-search-tag '("-unread"))
      ;; (notmuch-search-archive-thread)
      (notmuch-search-next-thread)))

  (define-key notmuch-search-mode-map "u"
    (lambda ()
      "Mark message unread."
      (interactive)
      (notmuch-search-tag '("+unread"))
      (notmuch-search-next-thread)))

  (define-key notmuch-search-mode-map "K"
    (lambda ()
      "Mark message deleted."
      (interactive)
      (notmuch-search-tag '("-unread" "-inbox" "+deleted"))
      (notmuch-search-archive-thread)))

  (define-key notmuch-search-mode-map "S"
    (lambda ()
      "Mark message as spam"
      (interactive)
      (notmuch-search-tag '("-unread" "-inbox" "+spam"))
      (notmuch-search-archive-thread)))

  (define-key notmuch-tree-mode-map "S"
    (lambda ()
      "Mark message as spam"
      (interactive)
      (notmuch-tree-tag '("-unread" "-inbox" "+spam"))
      (notmuch-tree-archive-thread))))

;; TODO: Additional `notmuch-tree' key bindings

(after! evil
  (mapc (lambda (str) (evil-set-initial-state (car str) (cdr str)))
        '((notmuch-hello-mode . emacs)
          (notmuch-search-mode . emacs)
          (notmuch-tree-mode . emacs))))

(after! recentf
  (add-to-list 'recentf-exclude (expand-file-name maildir)))

;; notmuch's buffers should be real
(defun notmuch-buffer-p (buffer)
  (string-match-p "^\\*notmuch-" (buffer-name buffer)))
(push #'notmuch-buffer-p doom-real-buffer-functions)
