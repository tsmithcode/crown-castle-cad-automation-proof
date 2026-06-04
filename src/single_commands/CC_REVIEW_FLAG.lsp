;;; CC_REVIEW_FLAG.lsp
;;; Command: CC_REVIEW_FLAG
;;;
;;; Proof point:
;;; This is the business rule in CAD form: uncertain engineering data is made
;;; visible for review instead of being silently inferred.

(defun c:CC_REVIEW_FLAG (/ pt message)
  (vl-load-com)

  (setq pt (getpoint "\nReview flag insertion point: "))
  (if pt
    (progn
      (setq message (getstring T "\nReview message: "))
      (if (= (cc:trim message) "")
        (setq message "Missing or uncertain engineering data. Drafter/engineer review required.")
      )
      (cc:add-review-flag pt message)
      (princ "\nReview flag added on CROWN-REVIEW-FLAG.")
    )
    (princ "\nNo insertion point selected.")
  )
  (princ)
)
