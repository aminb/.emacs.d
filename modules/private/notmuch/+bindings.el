;;; private/notmuch/+bindings.el -*- lexical-binding: t; -*-

(defun aminb-notmuch ()
  "Delete other windows, then launch `notmuch'."
  (interactive)
  (require 'notmuch)
  (delete-other-windows)
  (notmuch))

(map!
 :leader :desc "notmuch" :n "m" #'aminb-notmuch)
