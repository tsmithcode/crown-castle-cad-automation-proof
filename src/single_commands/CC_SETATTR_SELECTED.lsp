;;; CC_SETATTR_SELECTED.lsp
;;; Command: CC_SETATTR
;;;
;;; Proof point:
;;; Attribute tags are a practical integration seam. External scope data becomes
;;; reliable CAD metadata only if block tags are known and checked.

(defun c:CC_SETATTR (/ picked ename tag value)
  (vl-load-com)

  ;; Ask the user to select a block reference. entsel returns a pair; car is the entity name.
  (setq picked (entsel "\nSelect equipment/title block insert: "))

  (if picked
    (progn
      (setq ename (car picked))
      (if (/= "INSERT" (cdr (assoc 0 (entget ename))))
        (princ "\nSelected entity is not a block reference.")
        (progn
          (setq tag   (getstring T "\nAttribute tag to update, e.g. SITE_ID or EQUIPMENT_ID: "))
          (setq value (getstring T "\nNew value: "))

          ;; cc:set-attr returns T when the tag exists. That gives useful feedback.
          (if (cc:set-attr ename tag value)
            (princ "\nAttribute updated.")
            (princ "\nTag not found or selected block has no attributes.")
          )
        )
      )
    )
    (princ "\nNothing selected.")
  )
  (princ)
)
