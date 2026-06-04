;;; CC_HELP.lsp
;;; Command: CC_HELP
;;;
;;; Lists the technical proof commands at the AutoCAD command line.

(defun c:CC_HELP (/)
  (princ "\n")
  (princ "\nCrown Castle AutoLISP technical proof commands")
  (princ "\n---------------------------------------")
  (princ "\nCC_MAKE_DEMO_BLOCKS  - Create simple placeholder blocks for blank-drawing demos.")
  (princ "\nCC_MKLAYERS          - Create/check standard Crown-style layers.")
  (princ "\nCC_INSERT_ANTENNA    - Insert one antenna block after validating prompt input.")
  (princ "\nCC_SETATTR           - Set one attribute on a selected block.")
  (princ "\nCC_TITLE_SITE        - Update title block site/project fields in paper space.")
  (princ "\nCC_CALLOUT           - Add a callout line plus MTEXT.")
  (princ "\nCC_REVIEW_FLAG       - Add a visible review-required note.")
  (princ "\nCC_SCOPECSV2DRAFT    - Read CSV scope, insert valid items, flag invalid items, write report.")
  (princ "\nCC_VALIDATE_DWG      - Scan drawing and write a validation report.")
  (princ "\nCC_NORMALIZE_LEGACY  - Map known legacy layers to standard layers and write report.")
  (princ "\nCC_CLEANUP           - Run conservative AUDIT/PURGE cleanup.")
  (princ "\nCC_PLOT_PDF          - Plot current layout to PDF using current page setup.")
  (princ "\n")
  (princ)
)
