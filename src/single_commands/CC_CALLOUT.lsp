;;; CC_CALLOUT.lsp
;;; Command: CC_CALLOUT
;;;
;;; Proof point:
;;; Callouts should be deterministic: controlled layer, controlled text size, and
;;; explicit leader geometry instead of relying on the drafter's current settings.

(defun c:CC_CALLOUT (/ fromPt toPt text height width)
  (vl-load-com)

  (setq fromPt (getpoint "\nPick equipment point: "))

  (if fromPt
    (progn
      (setq text   (getstring T "\nCallout text: "))
      (setq toPt   (getpoint fromPt "\nPick callout text point: "))
      (setq height (getreal "\nText height <2.5>: "))

      ;; Default text size keeps the command fast in a technical proof.
      (if (null height) (setq height 2.5))
      (setq width (* height 36.0))

      (if toPt
        (progn
          (cc:ensure-layer "CROWN-CALLOUT" 2)
          (cc:add-line "CROWN-CALLOUT" fromPt toPt)
          (cc:add-mtext "CROWN-CALLOUT" toPt width text height)
          (princ "\nCallout created on CROWN-CALLOUT.")
        )
        (princ "\nNo callout text point selected.")
      )
    )
    (princ "\nNo equipment point selected.")
  )
  (princ)
)
