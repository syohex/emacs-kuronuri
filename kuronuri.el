;;; kuronuri.el --- Like Japanese secret document

;; Copyright (C) 2016 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/emacs-kuronuri
;; Version: 0.01

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(defsubst kuronuri--current-face ()
  (or (face-at-point) 'default))

(defun kuronuri--face-foreground (face)
  (let ((foreground (face-foreground face)))
    (or foreground
        (let ((inherit (face-attribute face :inherit)))
          (when inherit
            (kuronuri--face-foreground inherit))))))

(defun kuronuri--make-overlay (beg end)
  (save-excursion
    (goto-char beg)
    (let* ((ov (make-overlay beg end))
           (face (kuronuri--current-face))
           (foreground (kuronuri--face-foreground face)))
      (overlay-put ov 'kuronuri t)
      (overlay-put ov 'face `((:background ,foreground))))))

;;;###autoload
(defun kuronuri-region (beg end)
  (interactive "r")
  (save-excursion
    (deactivate-mark t)
    (goto-char beg)
    (let ((prevface (kuronuri--current-face))
          (start beg))
      (while (and (<= (point) end) (not (eobp)))
        (let ((curface (kuronuri--current-face)))
          (when (or (not (eq prevface curface))
                    (looking-at-p "[[:space:]\n\r\v]"))
            (kuronuri--make-overlay start (point))
            (setq prevface curface
                  start (point))))
        (if (looking-at-p "[[:space:]\n\r\v]")
            (progn
              (skip-chars-forward "[:space:]\n\r\v")
              (setq start (point)))
          (forward-char 1)))
      (unless (= start end)
        (kuronuri--make-overlay start (point))))))

;;;###autoload
(defun kuronuri-buffer ()
  (interactive)
  (kuronuri-clean)
  (kuronuri-region (point-min) (point-max)))

;;;###autoload
(defun kuronuri-clean ()
  (interactive)
  (remove-overlays (point-min) (point-max) 'kuronuri t))

(provide 'kuronuri)

;;; kuronuri.el ends here
