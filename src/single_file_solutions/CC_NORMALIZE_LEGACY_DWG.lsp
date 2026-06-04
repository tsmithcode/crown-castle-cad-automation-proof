;;; CC_NORMALIZE_LEGACY_DWG.lsp
;;; Command: CC_NORMALIZE_LEGACY
;;;
;;; Self-contained single-file solution.
;;;
;;; Context:
;;; Legacy drawings drift. This command performs a narrow, auditable normalization
;;; pass by moving entities from known legacy layer aliases to approved layers.
;;; Unknown layers are not guessed.

(vl-load-com)

(defun cc:outdir (/ prefix)
  (setq prefix (getvar "DWGPREFIX"))
  (if (= prefix "") (getvar "TEMPPREFIX") prefix)
)

(defun cc:ensure-layer (layerName color /)
  ;; Create standard layer if it does not already exist.
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

(defun cc:make-standard-layers (/)
  ;; Minimal approved target layers.
  (cc:ensure-layer "CROWN-ANTENNA" 1)
  (cc:ensure-layer "CROWN-RADIO" 3)
  (cc:ensure-layer "CROWN-MOUNT" 5)
  (cc:ensure-layer "CROWN-CALLOUT" 2)
  (cc:ensure-layer "CROWN-REVIEW-FLAG" 6)
  (cc:ensure-layer "CROWN-TITLE" 7)
)

(defun cc:layer-map ()
  ;; Source alias -> approved target layer.
  ;; Conservative by design: only known aliases are mapped.
  '(
    ("ANT" . "CROWN-ANTENNA")
    ("ANTENNA" . "CROWN-ANTENNA")
    ("ANTENNAS" . "CROWN-ANTENNA")
    ("EQUIP-ANT" . "CROWN-ANTENNA")
    ("RAD" . "CROWN-RADIO")
    ("RADIO" . "CROWN-RADIO")
    ("RRU" . "CROWN-RADIO")
    ("MNT" . "CROWN-MOUNT")
    ("MOUNT" . "CROWN-MOUNT")
    ("MOUNTS" . "CROWN-MOUNT")
    ("ANNO" . "CROWN-CALLOUT")
    ("TEXT" . "CROWN-CALLOUT")
    ("CALLOUT" . "CROWN-CALLOUT")
    ("TITLE" . "CROWN-TITLE")
  )
)

(defun cc:move-layer-entities (fromLayer toLayer / ss i ename data count)
  ;; Move all entities from one known legacy layer to the approved target layer.
  ;; Returns the number of entities moved.
  (setq count 0)
  (setq ss (ssget "_X" (list (cons 8 fromLayer))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ename (ssname ss i))
        (setq data (entget ename))
        (if (assoc 8 data)
          (progn
            (setq data (subst (cons 8 toLayer) (assoc 8 data) data))
            (entmod data)
            (entupd ename)
            (setq count (1+ count))
          )
        )
        (setq i (1+ i))
      )
    )
  )
  count
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

(defun c:CC_NORMALIZE_LEGACY (/ mapping fromLayer toLayer count lines path oldCmdecho)
  (vl-load-com)

  ;; This command should be run on a copy or in a controlled worker process.
  (cc:make-standard-layers)
  (setq lines (list "action,sourceLayer,targetLayer,count"))

  ;; Apply only known mappings. Unknown layer names remain untouched for human review.
  (foreach mapping (cc:layer-map)
    (setq fromLayer (car mapping))
    (setq toLayer   (cdr mapping))
    (if (tblsearch "LAYER" fromLayer)
      (progn
        (setq count (cc:move-layer-entities fromLayer toLayer))
        (setq lines (append lines (list (strcat "MOVE," fromLayer "," toLayer "," (itoa count)))))
      )
    )
  )

  ;; A small cleanup after layer normalization. Keep this conservative.
  (setq oldCmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "_.-PURGE" "_Regapps" "*" "_N")
  (setvar "CMDECHO" oldCmdecho)

  (setq path (strcat (cc:outdir) (vl-filename-base (getvar "DWGNAME")) "_CC_LAYER_NORMALIZATION_REPORT.csv"))
  (cc:write-lines path lines)

  (command "_.REGENALL")
  (princ (strcat "\nLegacy normalization complete. Report: " path))
  (princ)
)
