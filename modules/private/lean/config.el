;;; private/lean/config.el -*- lexical-binding: t; -*-

;; (load! +bindings)

(def-package! company-lean)
(def-package! lean-mode)
(def-package! helm-lean)

(defun unlines (lns)
  (mapconcat 'identity lns "\n"))

(defun keep-errors-only (proc string)
  (interactive)
  (let* ((lines (split-string string "\n"))
	     (new-string (seq-filter (lambda (x) (cl-search "error" x)) lines)))
    (if (not (null new-string))
	    (when (buffer-live-p (process-buffer proc))
	      (with-current-buffer (process-buffer proc)
	        (let ((moving (= (point) (process-mark proc))))
	          (save-excursion
		        ;; Insert the text, advancing the process marker.
		        (goto-char (process-mark proc))
		        (insert (unlines new-string))
		        (set-marker (process-mark proc) (point)))
	          (if moving (goto-char (process-mark proc)))
	          (delete-process proc)))))))

(defun lean-leanpkg-run-quiet (cmd &optional restart-lean-server)
  "Call `leanpkg $cmd`"
  (let ((dir (file-name-as-directory (lean-leanpkg-find-dir-safe)))
        (orig-buf (current-buffer)))
    (with-current-buffer (get-buffer-create "*leanpkg*")
      (setq buffer-read-only nil)
      (erase-buffer)
      (switch-to-buffer-other-window (current-buffer))
      (redisplay)
      (insert (format "> leanpkg %s\n" cmd))
      (setq lean-leanpkg-running t)
      (let* ((default-directory dir)
             (out-buf (current-buffer))
             (proc (make-process :name "leanpkg"
				                 :buffer (current-buffer)
				                 :filter 'keep-errors-only
                                 :command (list (lean-leanpkg-executable) cmd))))
        (set-process-sentinel
         proc (lambda (_p _e)
                (setq lean-leanpkg-running nil)
		        (if restart-lean-server
		            (progn
		              (with-current-buffer out-buf
			            (insert "; restarting lean server\n"))
		              (with-current-buffer orig-buf
			            (lean-server-restart)))
		          (progn
		            (with-current-buffer out-buf
			          (insert "; (done)\n"))))))))))

(defun lean-leanpkg-build-quiet ()
  "Call leanpkg build (quiet)"
  (interactive)
  (lean-leanpkg-run-quiet "build"))

(defun lean-leanpkg-test-quiet ()
  "Call leanpkg build (quiet)"
  (interactive)
  (lean-leanpkg-run-quiet "test"))
