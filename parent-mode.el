;;; parent-mode.el --- get major mode's parent modes  -*- lexical-binding: t -*-

;; Author: Fanael Linithien <fanael4@gmail.com>
;; URL: https://github.com/Fanael/parent-mode
;; Version: 1.0
;; Package-Requires: ((emacs "24"))

;; This file is NOT part of GNU Emacs.

;; Copyright (c) 2014, Fanael Linithien
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;;
;;   * Redistributions of source code must retain the above copyright
;;     notice, this list of conditions and the following disclaimer.
;;   * Redistributions in binary form must reproduce the above copyright
;;     notice, this list of conditions and the following disclaimer in the
;;     documentation and/or other materials provided with the distribution.
;;   * Neither the name of the copyright holder(s) nor the names of any
;;     contributors may be used to endorse or promote products derived from
;;     this software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;; IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
;; TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
;; PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
;; OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;;; Code:

(defun parent-mode-map (mode func)
  "For MODE and all its parent modes, call FUNC.

FUNC is first called for MODE, then for its parent, then for the parent's
parent, and so on.

MODE shall be a symbol.
FUNC shall be a function taking one argument."
  (funcall func mode)
  (let ((nextmode (get mode 'derived-mode-parent)))
    (while nextmode
      ;; Hande all the modes that use (defalias 'foo-parent-mode (stuff)) as
      ;; their parent
      (while (symbolp (symbol-function nextmode))
        (funcall func nextmode)
        (setq nextmode (symbol-function nextmode)))
      (funcall func nextmode)
      (setq nextmode (get nextmode 'derived-mode-parent)))))

(defun parent-mode-list (mode)
  "Return a list of MODE and all its parent modes.

The returned list starts with the parent-most mode and ends with MODE."
  (let ((result ()))
    (parent-mode-map mode (lambda (mode)
                            (push mode result)))
    result))

(defun parent-mode-is-derived-p (mode parent)
  "Non-nil iff MODE is a major mode derived from PARENT.

Both MODE and PARENT shall be symbols."
  (catch 'parent-mode-is-derived-p
    (parent-mode-map mode (lambda (m)
                            (when (eq m parent)
                              (throw 'parent-mode-is-derived-p t))))
    nil))

(provide 'parent-mode)
;;; parent-mode.el ends here
