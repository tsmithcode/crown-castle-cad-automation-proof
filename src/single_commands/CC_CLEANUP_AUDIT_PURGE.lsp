;;; CC_CLEANUP_AUDIT_PURGE.lsp
;;; Command: CC_CLEANUP
;;;
;;; Proof point:
;;; Legacy cleanup should be controlled and auditable. This command does not try
;;; to fix unknown standards; it performs a conservative AUDIT/PURGE pass.

(defun c:CC_CLEANUP (/ oldCmdecho)
  (vl-load-com)

  ;; Hide command echo noise, but restore it after the cleanup.
  (setq oldCmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  ;; AUDIT first so AutoCAD checks the database before purge operations.
  (command "_.AUDIT" "_Y")

  ;; Regapps often accumulate in legacy drawings.
  (command "_.-PURGE" "_Regapps" "*" "_N")

  ;; Conservative one-pass purge of unused items.
  ;; In production, this should be controlled by policy and run on a copy.
  (command "_.-PURGE" "_All" "*" "_N")

  (command "_.ZOOM" "_Extents")
  (setvar "CMDECHO" oldCmdecho)

  (princ "\nCleanup complete. Review command history for AUDIT results.")
  (princ)
)
