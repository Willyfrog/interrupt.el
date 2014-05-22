;;; interrupt.el --- Add a line to a file especifying who interrupted and why

;; Copyright (C) 2014 Guillermo Vayá Pérez

;; Author   : Guillermo Vaya <guivaya@gmail.com> <@Willyfrog_>
;; URL      : https://github.com/willyfrog/interrupt.el
;; Version  : 0.2
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
;; log it along with the current time.  Point will be set right after the time so
;; an explanation can be written later.

;; Once the interrupt is finished, interrupt-end can be called so it records
;; the time spent.  This can be called multiple times in case the
;; interruptor came back ;)

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

(defun interpt-open-file ()
  "Open or create the file where the log wil occur."
  (let
      ((file-name (interpt-get-file-path)))
    (find-file file-name)))

(defun interpt-list-to-org-tags (x)
  "Given X as a list of strings, make them a list of tags for 'org-mode'."
  (format ":%s:" (mapconcat 'identity x ":")))

(defun interpt-log (who)
  "Log the interruption to a file.
WHO describes the user or group who caused the interruption.  It's a list of strings."
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

(defun interpt-get-last-time-stamp-string ()
  "Find the last timestamp string written by interrupt."
  (interpt-move-to-last-written-line)
  (buffer-substring-no-properties (- (search-forward "<") 1)
                           (search-forward ">")))

(defun interpt-by-minutes (date-string)
  "Given a org-stile DATE-STRING return the number of minutes passed."
  (round (/ (abs (org-time-stamp-to-now date-string t)) 60)))

(defun interpt-delete-end-interrupt ()
  "Delete any interruption-end found on the line."
  (save-restriction
    (narrow-to-region (line-beginning-position) (line-end-position))
    (while (re-search-forward "{[0-9]+ min}" nil t)
      (replace-match "" nil nil))))

(defun interpt-move-to-last-written-line ()
  "Find the last written line."
  (point-max)
  (search-backward-regexp "^*"))

(defun interrupt-end ()
  "End the interruption and log the time."
  (interactive)
  (interpt-open-file)
  (save-excursion
    (let ((time-stamp (interpt-get-last-time-stamp-string)))
      (interpt-delete-end-interrupt)
      (insert (format "{%s min}" (interpt-by-minutes time-stamp))))))

(provide 'interrupt)
;;; interrupt.el ends here

