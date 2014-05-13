(prelude-require-package 'ido-vertical-mode)
(ido-vertical-mode 1)

(setq projectile-switch-project-action 'projectile-dired)
(prelude-require-package 'perspective)
(prelude-require-package 'persp-projectile)
(require 'persp-projectile)
(persp-mode)

(prelude-require-package 'discover)
(global-discover-mode 1)

(prelude-require-package 'keyfreq)
(setq keyfreq-file (expand-file-name "keyfreq" prelude-savefile-dir))
(setq keyfreq-file-lock (expand-file-name "keyfreq-lock" prelude-savefile-dir))
(keyfreq-mode 1)
(keyfreq-autosave-mode 1)
;; follow Steve Yegge's suggestion
(global-set-key (kbd "C-c C-m") 'smex)
(global-set-key (kbd "C-c <RET>") 'smex)

;; eval like Light Table
(global-set-key (kbd "M-<RET>") 'eval-last-sexp)

; no scroll bars
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

; be quiet
(setq ring-bell-function 'ignore)

;;; ISSUE fish Shell separates PATH with whitespace instead of :
;;; https://github.com/purcell/exec-path-from-shell/issues/9
(when (eq system-type 'darwin)
  (exec-path-from-shell-initialize)
  (when (equal (file-name-nondirectory (getenv "SHELL")) "fish")
    (setq exec-path (split-string (car exec-path) " "))
    (let ((fixed-path (mapconcat 'identity (split-string (getenv "PATH") " ") ":")))
         (setenv "PATH" fixed-path)
         (setq eshell-path-env fixed-path))))

(setq mac-option-modifier 'super)
(setq mac-command-modifier 'meta)
(setq ns-function-modifier 'hyper)

;; mac friendly font
(setq ns-use-srgb-colorspace t)

(defconst preferred-monospace-fonts
  `(
    ("Source Code Pro" . ,(if (eq system-type 'darwin) 130 100))
    ("Anonymous Pro" . ,(if (eq system-type 'darwin) 135 110))
    ("Anonymous Pro Minus" . ,(if (eq system-type 'darwin) 135 110))
    ("DejaVu Sans Mono" . 120)
    ("Inconsolata" . ,(if (eq system-type 'darwin) 140 110))
    ("Menlo" . 120)
    ("Consolas" . 130)
    ("Courier New" . 130))
  "Preferred monospace fonts
The `car' of each item is the font family, the `cdr' the preferred font size.")

(defconst preferred-proportional-fonts
  '(("Lucida Grande" . 120)
    ("DejaVu Sans" . 110))
  "Preferred proportional fonts
The `car' of each item is the font family, the `cdr' the preferred font size.")

(defun first-existing-font (fonts)
  "Get the first existing font from FONTS."
  (--first (x-family-fonts (car it)) fonts))

(setq current-monospace-font preferred-monospace-fonts)
(defun cycle-fonts ()
  "Cycle through the monospace fonts"
  (interactive)
  (if (null current-monospace-font)
      (setq current-monospace-font preferred-monospace-fonts)
    (setq current-monospace-font (cdr current-monospace-font)))
  (-when-let (font (first-existing-font current-monospace-font))
    (--each '(default fixed-pitch)
      (set-face-attribute it nil
                          :family (car font) :height (cdr font))
      (message "%S" font))))
(global-set-key [f5] 'cycle-fonts)

(defun choose-best-fonts ()
  "Choose the best fonts."
  (interactive)
  (-when-let (font  (first-existing-font preferred-monospace-fonts))
    (--each '(default fixed-pitch)
      (set-face-attribute it nil
                          :family (car font) :height (cdr font))))
  (-when-let (font (first-existing-font preferred-proportional-fonts))
    (set-face-attribute 'variable-pitch nil
                        :family (car font) :height (cdr font))))

(choose-best-fonts)

(defun pick-color-theme (frame)
  (if (window-system frame)
      (load-theme 'solarized-dark t)
    (load-theme 'solarized-light t)))

(add-hook 'after-make-frame-functions
          (lambda (frame)
            (select-frame frame)
            (pick-color-theme frame)))

;; for direct loading
(pick-color-theme nil)

(setq themes-options (list
       'solarized-dark
       'solarized-light
       'zenburn
))

;; make the modeline high contrast
(setq solarized-high-contrast-mode-line t)

(setq theme-current themes-options)

(defun theme-cycle ()
  (interactive)
  (setq theme-current (cdr theme-current))
  (if (null theme-current)
      (setq theme-current themes-options))
  (load-theme (car theme-current) 'no-confirm)
  (message "%S" (car theme-current)))

(global-set-key [f4] 'theme-cycle)

(require 'setup-evil)
(require 'setup-window)
(require 'setup-org)
(require 'setup-cider)
(require 'setup-magit)
