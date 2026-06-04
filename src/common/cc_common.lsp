;;; cc_common.lsp
;;; Shared helper functions for the technical proof commands.
;;;
;;; Implementation role:
;;; This file is the small reusable layer. The command files stay readable because
;;; common tasks such as layer creation, attribute updates, review flags, and report
;;; writing live here.

(vl-load-com)

(defun cc:trim (value / text)
  ;; Normalize a value into a trimmed string.
  ;; Scope files and attributes often come in as strings with extra whitespace.
  (cond
    ((null value) "")
    ((= (type value) 'STR) (vl-string-trim " \t\r\n\"" value))
    (T (vl-princ-to-string value))
  )
)

(defun cc:key (value)
  ;; Convert text to an uppercase lookup key.
  ;; This lets us compare tags/layers without case sensitivity problems.
  (strcase (cc:trim value))
)

(defun cc:acad ()
  ;; Root AutoCAD COM object.
  (vlax-get-acad-object)
)

(defun cc:doc ()
  ;; Active document. All commands operate against the current drawing.
  (vla-get-ActiveDocument (cc:acad))
)

(defun cc:ms ()
  ;; Model space collection used by ActiveX add methods.
  (vla-get-ModelSpace (cc:doc))
)

(defun cc:outdir (/ prefix)
  ;; Prefer the drawing folder. If the drawing has not been saved, use temp.
  (setq prefix (getvar "DWGPREFIX"))
  (if (= prefix "")
    (getvar "TEMPPREFIX")
    prefix
  )
)

(defun cc:today ()
  ;; AutoCAD DATE is a Julian-style real. MENUCMD formats it cleanly.
  (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD)")
)

(defun cc:ensure-layer (layerName color /)
  ;; Create a layer only if it does not already exist.
  ;; Production systems should source layer names/colors from a versioned standard.
  (if (not (tblsearch "LAYER" layerName))
    (entmakex
      (list
        '(0 . "LAYER")
        '(100 . "AcDbSymbolTableRecord")
        '(100 . "AcDbLayerTableRecord")
        (cons 2 layerName)
        '(70 . 0)
        (cons 62 color)
        '(6 . "Continuous")
      )
    )
  )
  layerName
)

(defun cc:ensure-standard-layers (/ spec)
  ;; Minimal Crown-style demo layer set.
  ;; The important proof point is deterministic layer ownership.
  (foreach spec
    '(
      ("CROWN-ANTENNA" . 1)
      ("CROWN-RADIO" . 3)
      ("CROWN-MOUNT" . 5)
      ("CROWN-CALLOUT" . 2)
      ("CROWN-REVIEW-FLAG" . 6)
      ("CROWN-TITLE" . 7)
      ("CROWN-AUTO-LOG" . 8)
    )
    (cc:ensure-layer (car spec) (cdr spec))
  )
)

(defun cc:effective-name (ename / obj)
  ;; Dynamic blocks can have anonymous names like *U###.
  ;; EffectiveName gives the authoring block name when available.
  (setq obj (vlax-ename->vla-object ename))
  (if (vlax-property-available-p obj 'EffectiveName)
    (vla-get-EffectiveName obj)
    (vla-get-Name obj)
  )
)

(defun cc:set-attr (ename tag value / obj att found)
  ;; Set one attribute on a block reference by tag name.
  ;; Returns T when the tag was found, nil otherwise.
  (setq found nil)
  (if (and ename (= "INSERT" (cdr (assoc 0 (entget ename)))))
    (progn
      (setq obj (vlax-ename->vla-object ename))
      (if (= (vla-get-HasAttributes obj) :vlax-true)
        (foreach att (vlax-invoke obj 'GetAttributes)
          (if (= (cc:key (vla-get-TagString att)) (cc:key tag))
            (progn
              (vla-put-TextString att (cc:trim value))
              (setq found T)
            )
          )
        )
      )
    )
  )
  found
)

(defun cc:get-attr (ename tag / obj att value)
  ;; Read an attribute value from a block reference by tag name.
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

(defun cc:add-line (layerName fromPt toPt / lineObj)
  ;; Add a line on a controlled layer using ActiveX.
  (cc:ensure-layer layerName 2)
  (setq lineObj (vla-AddLine (cc:ms) (vlax-3d-point fromPt) (vlax-3d-point toPt)))
  (vla-put-Layer lineObj layerName)
  lineObj
)

(defun cc:add-mtext (layerName insertPt width text height / mtextObj)
  ;; Add MTEXT on a controlled layer.
  ;; Width and height are explicit so output does not depend on current text style settings.
  (cc:ensure-layer layerName 2)
  (setq mtextObj (vla-AddMText (cc:ms) (vlax-3d-point insertPt) width text))
  (vla-put-Layer mtextObj layerName)
  (vla-put-Height mtextObj height)
  mtextObj
)

(defun cc:add-review-flag (insertPt message / note)
  ;; Visible flag for missing/conflicting/uncertain engineering data.
  ;; This is central to the proof behavior: flag uncertainty, do not guess.
  (setq note (strcat "REVIEW REQUIRED\\P" message))
  (cc:add-mtext "CROWN-REVIEW-FLAG" insertPt 110.0 note 3.0)
)

(defun cc:write-lines (path lines / f line)
  ;; Write a simple text/CSV report.
  ;; Returns T on success and nil when the file could not be opened.
  (setq f (open path "w"))
  (if f
    (progn
      (foreach line lines
        (write-line line f)
      )
      (close f)
      T
    )
    nil
  )
)

(defun cc:count-selection (ss)
  ;; Small guard around sslength because ssget can return nil.
  (if ss (sslength ss) 0)
)

(princ "\ncc_common.lsp loaded.")
(princ)
