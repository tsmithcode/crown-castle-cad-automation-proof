;;; CC_TITLEBLOCK_SITE.lsp
;;; Command: CC_TITLE_SITE
;;;
;;; Proof point:
;;; Title block updates are a common automation win: project metadata can be
;;; applied consistently across layouts without manual retyping.

(defun c:CC_TITLE_SITE (/ ss i ename blockName siteId project updated)
  (vl-load-com)

  (setq siteId  (getstring T "\nSite ID, e.g. ATL-042: "))
  (setq project (getstring T "\nProject name/number: "))
  (setq updated 0)

  ;; Select paper-space block inserts only. DXF group 67 = 1 means paper space.
  (setq ss (ssget "_X" '((0 . "INSERT") (67 . 1))))

  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ename (ssname ss i))
        (setq blockName (cc:key (cc:effective-name ename)))

        ;; Match common title block naming conventions without touching every insert.
        (if (wcmatch blockName "*TITLE*,*TBLOCK*,CROWN_TITLE")
          (progn
            ;; Only matching tags are changed. Missing tags are not treated as fatal here.
            (cc:set-attr ename "SITE_ID" siteId)
            (cc:set-attr ename "PROJECT" project)
            (cc:set-attr ename "DATE" (cc:today))
            (cc:set-attr ename "AUTOMATION_STATUS" "DRAFTER REVIEW REQUIRED")
            (setq updated (1+ updated))
          )
        )
        (setq i (1+ i))
      )
    )
  )

  (princ (strcat "\nTitle block inserts updated: " (itoa updated)))
  (princ)
)
