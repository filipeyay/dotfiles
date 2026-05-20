;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "BlexMono Nerd Font Mono" :size 19)
      doom-variable-pitch-font (font-spec :family "BlexMono Nerd Font Mono" :size 19)
      doom-big-font (font-spec :family "BlexMono Nerd Font Mono" :size 24))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

(add-to-list 'custom-theme-load-path (expand-file-name "themes/" doom-private-dir))
(setq doom-theme 'kanagawa-dragon)
(setq doom-themes-enable-italic nil)

(defun my-disable-italics-h ()
  (interactive)
  (mapc (lambda (face)
          (when (not (keywordp face))
            (condition-case nil
                (when (eq (face-attribute face :slant) 'italic)
                  (set-face-attribute face nil :slant 'normal))
              (error nil))))
        (face-list)))

(add-hook 'doom-load-theme-hook #'my-disable-italics-h)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documentos/Notas/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Python Setup ;;
;;
;; Auto format
(after! python
  (setq-hook! 'python-mode-hook +format-with 'black))

;; LSP
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting t
        lsp-enable-snippet t
        lsp-headerline-breadcrumb-enable t))

(after! lsp-mode
  (setq lsp-idle-delay 0.6))

;; Company Setup ;;
(after! company
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 1))

;; Auto pairing ;;
(smartparens-global-mode 1)
(electric-pair-mode 1)

;; Force Python mode hook
(add-hook 'python-mode-hook #'lsp-deferred)

;; Prettier
(after! prettier
  (setq prettier-js-args '("--single-quote" "--trailing-comma" "all")))

;; Emmet
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'css-mode-hook 'emmet-mode)

;; Web Mode
(setq web-mode-enable-auto-quoting t
      web-mode-enable-auto-closing t
      web-mode-enable-auto-pairing t
      web-mode-enable-current-element-highlight t)

;; Default browser
(setq browse-url-browser-function 'browse-url-firefox)

;; Dashboard
;;(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-banner)
(after! doom-dashboard
  (remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-banner)
  )

(setq fancy-splash-image "~/.config/doom/img/avatar_vector_emacs.png")

;; Fullscreen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; TabOut
(after! smartparens
  (define-key smartparens-mode-map (kbd "M-l")
              #'sp-forward-sexp))
