;;; consult-omni-gh.el --- Consulting Github Client -*- lexical-binding: t -*-

;; Copyright (C) 2024 Armin Darvish

;; Author: Armin Darvish
;; Maintainer: Armin Darvish
;; Created: 2024
;; Version: 0.1
;; Package-Requires: ((emacs "28.1") (consult "1.4") (consult-omni "0.1") (consult-gh "2.0"))
;; Homepage: https://github.com/armindarvish/consult-omni
;; Keywords: convenience

;;; Commentary:

;;; Code:

(require 'consult-omni)
(require 'consult-gh)

(defun consult-omni--gh-transform (items &optional query)
  "Transforms consult-gh candidates to consult-omni style."
  (remove nil (mapcar (lambda (string)
                        (consult-gh--repo-format string (or query "") t))
                      items)))

(defun consult-omni--gh-preview (cand)
  "Preview for `consult-omni-github'."
  (when-let ((info (text-properties-at 0 (cdr (get-text-property 0 'multi-category cand))))
             (repo (plist-get info :repo))
             (query (plist-get info :query))
             (match-str (consult--build-args query))
             (buffer (get-buffer-create consult-gh-preview-buffer-name)))
    (add-to-list 'consult-gh--preview-buffers-list buffer)
    (consult-gh--repo-view (format "%s" repo) buffer)
    (with-current-buffer buffer
      (if consult-gh-highlight-matches
          (cond
           ((listp match-str)
            (mapcar (lambda (item)
                      (highlight-regexp item 'consult-gh-preview-match-face))
                    match-str))
           ((stringp match-str)
            (highlight-regexp match-str 'consult-gh-preview-match-face)))))
    (funcall (consult--buffer-preview) 'preview
             buffer)))

(defun consult-omni--gh-callback (cand)
  "Callback for `consult-omni-github'."
  (funcall consult-gh-repo-action (cdr (get-text-property 0 'multi-category cand))))

(cl-defun consult-omni--gh-search-repos-builder (input &rest args &key callback &allow-other-keys)
  "Makes builder command line args for “GitHub CLI”."
  (pcase-let* ((`(,query . ,opts) (consult-omni--split-command input (if callback (seq-difference args (list :callback callback)) args)))
               (opts (car-safe opts))
               (count (plist-get opts :count))
               (count (or (and count (integerp (read count)) (string-to-number count))
                          consult-omni-default-count))
               (cmd (consult--build-args '("gh" "search" "repos")))
               (cmd-opts (list "--limit" (format "%s" count)))
               (`(,re . ,hl) (funcall consult--regexp-compiler query 'basic t)))
    (when re
      (cons (append cmd
                    (list (string-join re " "))
                    cmd-opts)
            hl))))

;; Define the GitHub Source
(consult-omni-define-source "GitHub"
                            :narrow-char ?h
                            :type 'async
                            :require-match nil
                            :category 'consult-gh-repos
                            :face 'consult-omni-engine-title-face
                            :request #'consult-omni--gh-search-repos-builder
                            :on-preview #'consult-omni--gh-preview
                            :on-return #'identity
                            :on-callback #'consult-omni--gh-callback
                            :preview-key consult-omni-preview-key
                            :search-hist 'consult-omni--search-history
                            :select-hist 'consult-omni--selection-history
                            :group #'consult-omni--group-function
                            :sort t
                            :interactive consult-omni-intereactive-commands-type
                            :transform #'consult-omni--gh-transform
                            :enabled (lambda () (and (executable-find "gh")
                                                (fboundp 'consult-gh-search-repos)))
                            :annotate nil)

;;; provide `consult-omni-gh' module

(provide 'consult-omni-gh)

(add-to-list 'consult-omni-sources-modules-to-load 'consult-omni-gh)
;;; consult-omni-gh.el ends here
