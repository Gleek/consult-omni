;;; consult-omni-locate.el --- Consulting Locate Command -*- lexical-binding: t -*-

;; Copyright (C) 2024 Armin Darvish

;; Author: Armin Darvish
;; Maintainer: Armin Darvish
;; Created: 2024
;; Version: 0.1
;; Package-Requires: ((emacs "28.1") (consult "1.1") (consult-omni "0.2"))
;; Homepage: https://github.com/armindarvish/consult-omni
;; Keywords: convenience

;;; Commentary:

;;; Code:

(require 'consult-omni)

(defcustom consult-omni-locate-limit consult-omni-default-count
  "Max number results for `consult-omni-locate'

This is passes to “-l” command line argument.
"
  :type 'integer)

(defcustom consult-omni-locate-args "locate -i"
"Command line arguments for locate.

Similar to `consult-locate-args' bur for consult-omni."
  :type '(choice string (repeat (choice string sexp))))

(defun consult-omni--locate-preview (cand)
  "Grep preview function."
(funcall (consult--file-preview) 'preview cand))

(defun consult-omni--locate-callback (cand)
  "Find callback function."
  (consult--file-action cand)
  )

(defun consult-omni--find-transform (candidates &optional query)
  "Formats consult-omni-find candidates.
"
  (mapcar (lambda (candidate)
           (string-remove-prefix (file-truename default-directory) candidate))
          candidates))

(defun consult-omni--locate-filter (candidates &optional query)
  "Formats consult-omni-find candidates.
"
  (seq-filter (lambda (candidate) (not (string-match "^locate:.*$" candidate nil nil))) candidates))

(cl-defun consult-omni--locate-builder (input &rest args &key callback &allow-other-keys)
  "makes builder command line args for “locate”.
"
  (pcase-let* ((`(,query . ,opts) (consult-omni--split-command input args))
               (opts (car-safe opts))
               (count (plist-get opts :count))
               (dir (plist-get opts :dir))
               (dir (if dir (file-truename (format "%s" dir))))
               (count (or (and (integerp count) count)
                          (and count (string-to-number (format "%s" count)))
                          consult-omni-locate-limit))
               (default-directory (or dir default-directory))
               (consult-locate-args (concat consult-omni-locate-args
                                            (if count (format " -l %s" count))))
               )

   (funcall #'consult--locate-builder query)
            ))

(consult-omni-define-source "locate"
                           :narrow-char ?f
                           :category 'file
                           :type 'async
                           :face 'consult-omni-engine-source-face
                           :request #'consult-omni--locate-builder
                           ;; :transform nil
                           :filter #'consult-omni--locate-filter
                           :on-preview #'consult-omni--locate-preview
                           :on-return #'identity
                           :on-callback #'consult-omni--locate-callback
                           :preview-key consult-omni-preview-key
                           :search-history 'consult-omni--search-history
                           :selection-history 'consult-omni--selection-history
                           :group #'consult-omni--group-function
                           :enabled (lambda () (if (executable-find "locate") t nil))
                           :sort t
                           :static 'both
                           :annotate nil
                           )

;;; provide `consult-omni-locate' module

(provide 'consult-omni-locate)

(add-to-list 'consult-omni-sources-modules-to-load 'consult-omni-locate)
;;; consult-omni-locate.el ends here

;;; consult-omni-mdfind.el --- Consulting mdfind Command -*- lexical-binding: t -*-

;; Copyright (C) 2024 Armin Darvish

;; Author: Armin Darvish
;; Maintainer: Armin Darvish
;; Created: 2024
;; Version: 0.1
;; Package-Requires: ((emacs "28.1") (consult "1.1") (consult-omni "0.2"))
;; Homepage: https://github.com/armindarvish/consult-omni
;; Keywords: convenience

;;; Commentary:

;;; Code:

(require 'consult-omni)

(defcustom consult-omni-mdfind-interpret t
  "Whether to use the toggle -interpret in mdfind.
See mdfind documents (e.g. “man mdfind”) for more details.
"
  :type 'boolean)

(defcustom consult-omni-mdfind-args "mdfind"
"Command line arguments for mdfind.

Similar to other command line args for consult but for mdfind.
See `consult-locate-args' for example."
  :type '(choice string (repeat (choice string sexp))))

(defun consult-omni--mdfind-preview (cand)
  "Mdfind preview function."
(funcall (consult--file-preview) 'preview cand))

(defun consult-omni--mdfind-callback (cand)
  "Mdfind callback function."
  (consult--file-action cand)
  )

(defun consult-omni--find-transform (candidates &optional query)
  "Formats consult-omni-mdfind candidates.
"
  (mapcar (lambda (candidate)
           (string-remove-prefix (file-truename default-directory) candidate))
          candidates))

(defun consult-omni--mdfind-filter (candidates &optional query)
  "Formats `consult-omni-mdfind' candidates.
"
  ;; (seq-filter (lambda (candidate) (not (string-match "^mdfind:.*$" candidate nil nil))) candidates)
)

(cl-defun consult-omni--mdfind-builder (input &rest args &key callback &allow-other-keys)
  "makes builder command line args for “mdfind”.
"
  (pcase-let* ((`(,query . ,opts) (consult-omni--split-command input args))
               (opts (car-safe opts))
               (count (plist-get opts :count))
               (dir (plist-get opts :dir))
               (dir (if dir (file-truename (format "%s" dir))))
               (count (or (and (integerp count) count)
                          (and count (string-to-number (format "%s" count)))
                          consult-omni-default-count))
               (default-directory (or dir default-directory))
               (consult-locate-args (concat consult-omni-mdfind-args
                                            (if consult-omni-mdfind-interpret " -interpret")
(if dir (format " -onlyin %s" dir)))))
   (funcall #'consult--locate-builder query)
            ))

(consult-omni-define-source "mdfind"
                           :narrow-char ?f
                           :category 'file
                           :type 'async
                           :face 'consult-omni-engine-source-face
                           :request #'consult-omni--mdfind-builder
                           ;; :transform nil
                           ;; :filter #'consult-omni--mdfind-filter
                           :on-preview #'consult-omni--mdfind-preview
                           :on-return #'identity
                           :on-callback #'consult-omni--mdfind-callback
                           :preview-key consult-omni-preview-key
                           :search-history 'consult-omni--search-history
                           :selection-history 'consult-omni--selection-history
                           :group #'consult-omni--group-function
                           :enabled (lambda () (if (executable-find "mdfind") t nil))
                           :sort t
                           :static 'both
                           :annotate nil
                           )

;;; provide `consult-omni-mdfind' module

(provide 'consult-omni-mdfind)

(add-to-list 'consult-omni-sources-modules-to-load 'consult-omni-mdfind)
;;; consult-omni-mdfind.el ends here