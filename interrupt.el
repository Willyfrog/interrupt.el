;;; interrupt.el --- Add a line to a file especifying who interrupted and why

;; Copyright (C) 2014 Guillermo Vayá Pérez

;; Author   : Guillermo Vaya <guivaya@gmail.com>
;; URL      : https://github.com/willyfrog/interrupt.el
;; Version  : 0.1
;; Keywords : interruption, org-mode

;; The MIT License (MIT)

;; Permission is hereby granted, free of charge, to any person obtaining a copy of
;; this software and associated documentation files (the "Software"), to deal in
;; the Software without restriction, including without limitation the rights to
;; use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
;; the Software, and to permit persons to whom the Software is furnished to do so,
;; subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
;; FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
;; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
;; IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Commentary:

;;; Introduction

;; This is a simple function to keep track of the interruptions of your
;; coding session/work.

;;; Usage

;; Bind to an easy-access key chore so you can leave almost instantly
;; to the source of interruption.
;; 
;; After calling INTERRUPT the system will ask who interrupted and will
;; log it along with the time.  Point will be set right after the time so
;; an explanation can be written later.

;;; Todo

;; add another function so it can compare to the last
;;  entry and annotate the time spent on the interruption

;;; Code:

(require 'org)

(defcustom distraction-dir
    "~/org/trabajo/distracciones"
    "Where should the distraction logs be stored."
    :type 'directory
    :group 'interrupt)

(defcustom ask-for-user
    "who dares?"
    "Question to be asked whenever someone disturbs you."
    :type 'string
    :group 'interrupt)

(defun interpt-get-file-path ()
  "String representing the final dir where to store each file."
  (format "%s%s.org" distraction-dir (format-time-string "/%Y/%m/%d" )))

;;; TODO:
;; * if the file has been already open, just load the buffer,
;;   if not add a header with info
(defun interpt-open-file ()
  "Open or create the file where the log wil occur."
  (let
      ((file-name (interpt-get-file-path)))
    (find-file file-name)))

(defun interpt-list-to-org-tags (x)
  "given a list of strings, make them a list of tags for org-mode"
  (format ":%s:" (mapconcat 'identity x ":")))

(defun interpt-log (who)
  "Log the interruption to a file.
WHO describes the user or group who caused the interruption. It's a list of strings"
  (interpt-open-file)
  (goto-char (point-max))
  (org-insert-heading)
  (org-insert-time-stamp (org-read-date nil t "now") t)
  (insert " ")
  (save-excursion
    (org-set-tags-to (interpt-list-to-org-tags who))))

;; TODO accept multiple interrupters
(defun interrupt (who)
  "Prompt the user WHO dared to interrupt and log it."
  (interactive (list (read-string (format "%s:" ask-for-user))))
  (interpt-log (split-string who)))

(provide 'interrupt.el)
;;; interrupt.el ends here

