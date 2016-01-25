
;;; org-log-util.el --- org-log-util -*- lexical-binding: t -*-

;; Copyright (C) 2016 Parikshit Machwe

;; Author: Parikshit Machwe <pmachwe@gmail.com>
;; Created: 14 Jan 2016
;; Version: 0.0.1
;; Keywords: org, capture, log, util, diff, stack trace
;; X-URL: https://github.com/pmachwe/org-log-util

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This is a collection of functions to capture various work related items
;; using org-capture.

;;; Code:

(require 'org-capture)
(require 'helm-gtags)

(defgroup org-log-util nil
  ""
  :group 'org-log-util)

(defcustom org-log-util-diff-file org-default-notes-file
  "Override this to save file diffs into this file"
  :group 'org-log-util)

(defcustom org-log-util-stack-file org-default-notes-file
  "Override this to save stack traces into this file"
  :group 'org-log-util)

(defun org-log-util-get-buf-str (func-name buf-name)
  "Capture the buffer diff with file and return as string"
  (funcall func-name)
  (with-current-buffer buf-name
    (buffer-string)
    (kill-buffer-and-window)))

(defun org-log-util-get-diff-format-str ()
  "Format the string for org-capture template"
  (format "* DIFF %%?\n %%i\n %%T \n#+begin_src diff\n%s\n#+end_src"  ;; note %% to escape %
          (org-log-util-get-buf-str 'diff-buffer-with-file "*Diff*")))

(defun org-log-util-get-stack-format-str ()
  "Format the string for org-capture template"
  (format "* STACK %%?\n %%i\n %%T \n %%a \n#+begin_src diff\n%s\n#+end_src"  ;; note %% to escape %
          (org-log-util-get-buf-str 'helm-gtags-show-stack "*Helm Gtags*")))

;; For some reason, org-capture-templates comes out as nil
;; and hence the default TODO template get lost. Hence,
;; setting the default ones here
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
        "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

(setq org-capture-templates
      (append '(("d"
                 "File Diffs"
                 entry
                 (file+headline org-log-util-diff-file "File Diffs")
                 (function org-log-util-get-diff-format-str)
                 :empty-lines 1)
                ("c"
                 "Stack Traces"
                 entry
                 (file+headline org-log-util-stack-file "Stack Traces")
                 (function org-log-util-get-stack-format-str)
                 :empty-lines 1))
              org-capture-templates))

(provide 'org-log-util)

;; test: stack trace

;;; org-log-util.el ends here
