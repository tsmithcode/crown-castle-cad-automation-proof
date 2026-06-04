;;; CC_PLOT_CURRENT_LAYOUT_PDF.lsp
;;; Command: CC_PLOT_PDF
;;;
;;; Proof point:
;;; Plotting should use a configured page setup rather than a fragile prompt chain.
;;; This command plots the current layout to a review PDF path.

(defun c:CC_PLOT_PDF (/ acad doc plot outdir pdf result)
  (vl-load-com)

  (setq acad  (vlax-get-acad-object))
  (setq doc   (vla-get-ActiveDocument acad))
  (setq plot  (vla-get-Plot doc))
  (setq outdir (cc:outdir))
  (setq pdf (strcat outdir (vl-filename-base (getvar "DWGNAME")) "_" (getvar "CTAB") "_review.pdf"))

  ;; vla-PlotToFile uses the current layout's page setup.
  ;; A production template should already define plotter, paper size, scale, and style table.
  (setq result (vl-catch-all-apply 'vla-PlotToFile (list plot pdf)))

  (if (vl-catch-all-error-p result)
    (princ "\nPlot failed. Check current layout page setup and PDF plotter configuration.")
    (princ (strcat "\nReview PDF written: " pdf))
  )
  (princ)
)
