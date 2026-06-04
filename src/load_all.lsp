;;; load_all.lsp
;;; App-load this file to load the entire technical proof repo.
;;;
;;; Usage inside AutoCAD:
;;; 1. Run APPLOAD.
;;; 2. Select this file.
;;; 3. Type CC_HELP.

(vl-load-com)

(defun cc:loader-root (/ found)
  ;; Resolve the repo path from the location of this file.
  ;; If AutoCAD cannot resolve it, add this folder to the Support File Search Path.
  (setq found (findfile "load_all.lsp"))
  (if found
    (vl-filename-directory found)
    nil
  )
)

(defun cc:load-relative (relativePath / root fullPath)
  ;; Load a file relative to the folder containing load_all.lsp.
  (setq root (cc:loader-root))
  (if root
    (progn
      (setq fullPath (strcat root "\\" relativePath))
      (if (findfile fullPath)
        (load fullPath)
        (princ (strcat "\nMissing file: " fullPath))
      )
    )
    (princ "\nCould not resolve load_all.lsp path. Add repo src folder to AutoCAD support path.")
  )
)

(cc:load-relative "common\\cc_common.lsp")
(cc:load-relative "demo_support\\CC_MAKE_DEMO_BLOCKS.lsp")
(cc:load-relative "single_commands\\CC_HELP.lsp")
(cc:load-relative "single_commands\\CC_MKLAYERS.lsp")
(cc:load-relative "single_commands\\CC_INSERT_ANTENNA.lsp")
(cc:load-relative "single_commands\\CC_SETATTR_SELECTED.lsp")
(cc:load-relative "single_commands\\CC_TITLEBLOCK_SITE.lsp")
(cc:load-relative "single_commands\\CC_CALLOUT.lsp")
(cc:load-relative "single_commands\\CC_REVIEW_FLAG.lsp")
(cc:load-relative "single_commands\\CC_CLEANUP_AUDIT_PURGE.lsp")
(cc:load-relative "single_commands\\CC_PLOT_CURRENT_LAYOUT_PDF.lsp")
(cc:load-relative "single_file_solutions\\CC_SCOPECSV_TO_DRAFT.lsp")
(cc:load-relative "single_file_solutions\\CC_DWG_VALIDATION_REPORT.lsp")
(cc:load-relative "single_file_solutions\\CC_NORMALIZE_LEGACY_DWG.lsp")

(princ "\nCrown Castle AutoLISP technical proof repo loaded. Type CC_HELP.")
(princ)
