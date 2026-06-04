;;; CC_DWG_VALIDATION_REPORT.lsp
;;; Command: CC_VALIDATE_DWG
;;;
;;; Self-contained single-file solution.
;;;
;;; Context:
;;; A drafter-ready automation run should produce a validation artifact. This
;;; command scans the active drawing for required layers, scoped equipment blocks,
;;; required attributes, and unresolved review flags.

(vl-load-com)

(defun cc:key (value)
  ;; Normalize values for case-insensitive comparison.
  (if value
    (strcase (vl-string-trim " \t\r\n\"" (vl-princ-to-string value)))
    ""
  )
)

(defun cc:outdir (/ prefix)
  ;; Report folder: drawing directory or temp for unsaved drawings.
  (setq prefix (getvar "DWGPREFIX"))
  (if (= prefix "") (getvar "TEMPPREFIX") prefix)
)

(defun cc:effective-name (ename / obj)
  ;; Dynamic block safe name lookup.
  (setq obj (vlax-ename->vla-object ename))
  (if (vlax-property-available-p obj 'EffectiveName)
    (vla-get-EffectiveName obj)
    (vla-get-Name obj)
  )
)

(defun cc:get-attr (ename tag / obj att value)
  ;; Return attribute text by tag, or nil when missing.
  (setq value nil)
  (if (and ename (= "INSERT" (cdr (assoc 0 (entget ename)))))
    (progn
      (setq obj (vlax-ename->vla-object ename))
      (if (= (vla-get-HasAttributes obj) :vlax-true)
        (foreach att (vlax-invoke obj 'GetAttributes)
          (if (= (cc:key (vla-get-TagString att)) (cc:key tag))
            (setq value (vla-get-TextString att))
          )
        )
      )
    )
  )
  value
)

(defun cc:equipment-block-p (blockName)
  ;; Demo equipment block names. Production code should use a standards table.
  (member (cc:key blockName) '("ANTENNA_STANDARD" "RADIO_STANDARD" "MOUNT_STANDARD"))
)

(defun cc:report-row (severity code subject message)
  ;; Keep report simple and importable.
  (strcat severity "," code "," subject "," message)
)

(defun cc:write-lines (path lines / f line)
  (setq f (open path "w"))
  (if f
    (progn
      (foreach line lines (write-line line f))
      (close f)
      T
    )
    nil
  )
)

(defun cc:check-layer (layerName /)
  ;; Report missing standard layers as errors.
  (if (tblsearch "LAYER" layerName)
    (cc:report-row "INFO" "LAYER_EXISTS" layerName "standard layer exists")
    (cc:report-row "ERROR" "MISSING_LAYER" layerName "standard layer is missing")
  )
)

(defun cc:check-required-attr (ename blockName tag / value subject)
  ;; Required attributes are checked for both missing tag and blank value.
  (setq value (cc:get-attr ename tag))
  (setq subject (strcat blockName ":" tag))
  (cond
    ((null value)
     (cc:report-row "ERROR" "MISSING_ATTRIBUTE_TAG" subject "required attribute tag is missing"))
    ((= (cc:key value) "")
     (cc:report-row "ERROR" "BLANK_ATTRIBUTE_VALUE" subject "required attribute value is blank"))
    (T
     (cc:report-row "INFO" "ATTRIBUTE_OK" subject "required attribute has value"))
  )
)

(defun cc:validate-inserts (/ ss i ename blockName rows tag)
  ;; Validate recognized equipment block references.
  (setq rows '())
  (setq ss (ssget "_X" '((0 . "INSERT"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ename (ssname ss i))
        (setq blockName (cc:effective-name ename))
        (if (cc:equipment-block-p blockName)
          (progn
            (setq rows (append rows (list (cc:report-row "INFO" "EQUIPMENT_BLOCK_FOUND" blockName "recognized equipment block"))))
            (foreach tag '("EQUIPMENT_ID" "EQUIPMENT_TYPE" "SECTOR" "ELEVATION")
              (setq rows (append rows (list (cc:check-required-attr ename blockName tag))))
            )
            ;; Antennas and radios require azimuth for orientation. Mounts may not.
            (if (member (cc:key blockName) '("ANTENNA_STANDARD" "RADIO_STANDARD"))
              (setq rows (append rows (list (cc:check-required-attr ename blockName "AZIMUTH"))))
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
  rows
)

(defun cc:review-flag-count (/ ss)
  ;; Any object on CROWN-REVIEW-FLAG means unresolved review remains.
  (setq ss (ssget "_X" '((8 . "CROWN-REVIEW-FLAG"))))
  (if ss (sslength ss) 0)
)

(defun c:CC_VALIDATE_DWG (/ lines path flagCount insertRows)
  (vl-load-com)

  ;; Header row.
  (setq lines (list "severity,code,subject,message"))

  ;; Validate layers expected by the demo standard.
  (foreach layer '("CROWN-ANTENNA" "CROWN-RADIO" "CROWN-MOUNT" "CROWN-CALLOUT" "CROWN-REVIEW-FLAG" "CROWN-TITLE")
    (setq lines (append lines (list (cc:check-layer layer))))
  )

  ;; Validate recognized equipment block inserts.
  (setq insertRows (cc:validate-inserts))
  (foreach row insertRows
    (setq lines (append lines (list row)))
  )

  ;; Review flags are not failures by themselves. They are unresolved work items.
  (setq flagCount (cc:review-flag-count))
  (if (> flagCount 0)
    (setq lines (append lines (list (cc:report-row "WARN" "UNRESOLVED_REVIEW_FLAGS" "CROWN-REVIEW-FLAG" (strcat (itoa flagCount) " review flag entities remain")))))
    (setq lines (append lines (list (cc:report-row "INFO" "NO_REVIEW_FLAGS" "CROWN-REVIEW-FLAG" "no review flags found"))))
  )

  (setq path (strcat (cc:outdir) (vl-filename-base (getvar "DWGNAME")) "_CC_DWG_VALIDATION_REPORT.csv"))
  (cc:write-lines path lines)

  (princ (strcat "\nValidation rows written: " (itoa (1- (length lines)))))
  (princ (strcat "\nValidation report: " path))
  (princ)
)
