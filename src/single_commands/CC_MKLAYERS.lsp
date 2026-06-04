;;; CC_MKLAYERS.lsp
;;; Command: CC_MKLAYERS
;;;
;;; Proof point:
;;; Before automation inserts anything, it should establish known layers.
;;; This prevents legacy drawing state from controlling output quality.

(defun c:CC_MKLAYERS (/ oldLayer)
  (vl-load-com)

  ;; Save the user's current layer so the command can restore or intentionally set state.
  (setq oldLayer (getvar "CLAYER"))

  ;; Create the standard demo layer set from cc_common.lsp.
  (cc:ensure-standard-layers)

  ;; For this demo we intentionally leave CROWN-ANTENNA current because the next
  ;; likely operation is equipment placement. This is also visible to a reviewer.
  (setvar "CLAYER" "CROWN-ANTENNA")

  (princ (strcat "\nStandard layers checked. Previous current layer was: " oldLayer))
  (princ "\nCurrent layer set to CROWN-ANTENNA for equipment placement.")
  (princ)
)
