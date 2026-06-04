;;; CC_SCOPECSV_TO_DRAFT.lsp
;;; Command: CC_SCOPECSV2DRAFT
;;;
;;; Self-contained single-file solution.
;;;
;;; Context:
;;; This command demonstrates a drafter-ready automation pattern:
;;; 1. Read structured scope data from CSV.
;;; 2. Validate required engineering fields before placement.
;;; 3. Map equipment types to approved blocks and layers.
;;; 4. Insert only rows that are safe to generate.
;;; 5. Convert missing/invalid/uncertain rows into visible review flags.
;;; 6. Write a CSV report for audit/review.
;;;
;;; Expected CSV header:
;;; siteId,drawingTemplate,equipmentId,equipmentType,sector,azimuth,elevationFeet,mountType,layer,confidence,x,y
;;;
;;; Production note:
;;; In a real enterprise system, schema validation and job orchestration would
;;; usually live in C#/.NET or a service layer. This LISP file is the drawing-local
;;; execution layer.

(vl-load-com)

(defun cc:trim (value /)
  ;; Convert nil to blank and remove common whitespace/quote noise.
  (cond
    ((null value) "")
    ((= (type value) 'STR) (vl-string-trim " \t\r\n\"" value))
    (T (vl-princ-to-string value))
  )
)

(defun cc:key (value)
  ;; Uppercase comparison key.
  (strcase (cc:trim value))
)

(defun cc:outdir (/ prefix)
  ;; Reports go beside the DWG; unsaved drawings use temp.
  (setq prefix (getvar "DWGPREFIX"))
  (if (= prefix "") (getvar "TEMPPREFIX") prefix)
)

(defun cc:ensure-layer (layerName color /)
  ;; Create layer if missing. Existing layers are respected.
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
  ;; Minimal standard layer set for the demo.
  (foreach spec
    '(
      ("CROWN-ANTENNA" . 1)
      ("CROWN-RADIO" . 3)
      ("CROWN-MOUNT" . 5)
      ("CROWN-CALLOUT" . 2)
      ("CROWN-REVIEW-FLAG" . 6)
      ("CROWN-AUTO-LOG" . 8)
    )
    (cc:ensure-layer (car spec) (cdr spec))
  )
)

(defun cc:set-attr (ename tag value / obj att found)
  ;; Set block attribute by tag. Returns T if found.
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

(defun cc:add-mtext (layerName insertPt width text height / acad doc ms obj)
  ;; Add visible text on a controlled layer.
  (cc:ensure-layer layerName 6)
  (setq acad (vlax-get-acad-object))
  (setq doc  (vla-get-ActiveDocument acad))
  (setq ms   (vla-get-ModelSpace doc))
  (setq obj  (vla-AddMText ms (vlax-3d-point insertPt) width text))
  (vla-put-Layer obj layerName)
  (vla-put-Height obj height)
  obj
)

(defun cc:add-line (layerName fromPt toPt / acad doc ms obj)
  ;; Add a simple callout leader line.
  (cc:ensure-layer layerName 2)
  (setq acad (vlax-get-acad-object))
  (setq doc  (vla-get-ActiveDocument acad))
  (setq ms   (vla-get-ModelSpace doc))
  (setq obj  (vla-AddLine ms (vlax-3d-point fromPt) (vlax-3d-point toPt)))
  (vla-put-Layer obj layerName)
  obj
)

(defun cc:add-review-flag (pt message /)
  ;; Missing/conflicting/uncertain data becomes visible in the drawing.
  (cc:add-mtext "CROWN-REVIEW-FLAG" pt 120.0 (strcat "REVIEW REQUIRED\\P" message) 3.0)
)

(defun cc:csv-split (line / i ch inQuote cur out)
  ;; Small CSV parser for normal quoted/unquoted values.
  ;; Good enough for controlled scope exports and this demo sample.
  (setq i 1 inQuote nil cur "" out '())
  (while (<= i (strlen line))
    (setq ch (substr line i 1))
    (cond
      ((= ch "\"")
       ;; Double quote inside quotes becomes one quote.
       (if (and inQuote (< i (strlen line)) (= (substr line (1+ i) 1) "\""))
         (progn
           (setq cur (strcat cur "\""))
           (setq i (1+ i))
         )
         (setq inQuote (not inQuote))
       )
      )
      ((and (= ch ",") (not inQuote))
       (setq out (cons cur out))
       (setq cur "")
      )
      (T
       (setq cur (strcat cur ch))
      )
    )
    (setq i (1+ i))
  )
  (reverse (cons cur out))
)

(defun cc:zip-row (headers values / row)
  ;; Convert header/value lists into an association list.
  ;; Example: (("SITEID" . "ATL-042") ("AZIMUTH" . "30"))
  (setq row '())
  (while headers
    (setq row (cons (cons (cc:key (car headers)) (if values (cc:trim (car values)) "")) row))
    (setq headers (cdr headers))
    (if values (setq values (cdr values)))
  )
  (reverse row)
)

(defun cc:read-csv (path / f line headers rows)
  ;; Read a CSV into a list of row association lists.
  (setq rows '())
  (setq f (open path "r"))
  (if f
    (progn
      (setq line (read-line f))
      (if line
        (progn
          (setq headers (cc:csv-split line))
          (while (setq line (read-line f))
            (if (> (strlen (cc:trim line)) 0)
              (setq rows (cons (cc:zip-row headers (cc:csv-split line)) rows))
            )
          )
        )
      )
      (close f)
      (reverse rows)
    )
    nil
  )
)

(defun cc:get (row key / pair)
  ;; Read one field from a row association list.
  (setq pair (assoc (cc:key key) row))
  (if pair (cdr pair) "")
)

(defun cc:read-number (value / parsed)
  ;; Safely parse a number from a string.
  (if (= (cc:trim value) "")
    nil
    (progn
      (setq parsed (vl-catch-all-apply 'read (list (cc:trim value))))
      (if (or (vl-catch-all-error-p parsed) (not (numberp parsed))) nil parsed)
    )
  )
)

(defun cc:int-or-nil (value / parsed)
  (setq parsed (cc:read-number value))
  (if parsed (fix parsed) nil)
)

(defun cc:real-or-nil (value / parsed)
  (setq parsed (cc:read-number value))
  (if parsed (float parsed) nil)
)

(defun cc:map-layer (rawLayer equipmentType / layer typeKey)
  ;; Map source layer/type into an approved CAD layer.
  ;; Unknown layers return nil so they can be flagged instead of guessed.
  (setq layer   (cc:key rawLayer))
  (setq typeKey (cc:key equipmentType))
  (cond
    ((member layer '("ANT" "ANTENNA" "CROWN-ANTENNA")) "CROWN-ANTENNA")
    ((member layer '("RAD" "RADIO" "RRU" "CROWN-RADIO")) "CROWN-RADIO")
    ((member layer '("MNT" "MOUNT" "CROWN-MOUNT")) "CROWN-MOUNT")
    ((and (= layer "") (= typeKey "ANTENNA")) "CROWN-ANTENNA")
    ((and (= layer "") (= typeKey "RADIO")) "CROWN-RADIO")
    ((and (= layer "") (= typeKey "MOUNT")) "CROWN-MOUNT")
    (T nil)
  )
)

(defun cc:map-block (equipmentType / typeKey)
  ;; Map an equipment type to an approved block name.
  (setq typeKey (cc:key equipmentType))
  (cond
    ((= typeKey "ANTENNA") "ANTENNA_STANDARD")
    ((= typeKey "RADIO") "RADIO_STANDARD")
    ((= typeKey "MOUNT") "MOUNT_STANDARD")
    (T nil)
  )
)

(defun cc:issue (severity code equipmentId message)
  ;; One report row. Messages are kept comma-free for simple CSV output.
  (strcat severity "," code "," equipmentId "," message)
)

(defun cc:has-error-p (issues / hit issue)
  ;; Determine whether a row has blocking errors.
  (setq hit nil)
  (foreach issue issues
    (if (wcmatch issue "ERROR,*")
      (setq hit T)
    )
  )
  hit
)

(defun cc:row-point (row fallbackX / x y)
  ;; Build insertion point from CSV x/y values, or a fallback review location.
  (setq x (cc:real-or-nil (cc:get row "x")))
  (setq y (cc:real-or-nil (cc:get row "y")))
  (if (and x y)
    (list x y 0.0)
    (list fallbackX 0.0 0.0)
  )
)

(defun cc:validate-row (row / issues eq typeKey az elev conf x y layer block)
  ;; Validate only what this drawing command needs to make a safe change.
  ;; A production service would likely run a richer schema/ruleset before AutoCAD.
  (setq issues '())
  (setq eq      (cc:get row "equipmentId"))
  (setq typeKey (cc:key (cc:get row "equipmentType")))
  (setq az      (cc:int-or-nil (cc:get row "azimuth")))
  (setq elev    (cc:real-or-nil (cc:get row "elevationFeet")))
  (setq conf    (cc:real-or-nil (cc:get row "confidence")))
  (setq x       (cc:real-or-nil (cc:get row "x")))
  (setq y       (cc:real-or-nil (cc:get row "y")))
  (setq layer   (cc:map-layer (cc:get row "layer") (cc:get row "equipmentType")))
  (setq block   (cc:map-block (cc:get row "equipmentType")))

  (if (= (cc:get row "siteId") "")
    (setq issues (cons (cc:issue "ERROR" "MISSING_SITE_ID" eq "siteId is required") issues))
  )
  (if (= (cc:get row "drawingTemplate") "")
    (setq issues (cons (cc:issue "ERROR" "MISSING_TEMPLATE" eq "drawingTemplate is required") issues))
  )
  (if (= eq "")
    (setq issues (cons (cc:issue "ERROR" "MISSING_EQUIPMENT_ID" "" "equipmentId is required") issues))
  )
  (if (= typeKey "")
    (setq issues (cons (cc:issue "ERROR" "MISSING_EQUIPMENT_TYPE" eq "equipmentType is required") issues))
  )
  (if (= (cc:get row "sector") "")
    (setq issues (cons (cc:issue "ERROR" "MISSING_SECTOR" eq "sector is required") issues))
  )
  (if (= (cc:get row "mountType") "")
    (setq issues (cons (cc:issue "ERROR" "MISSING_MOUNT_TYPE" eq "mountType is required") issues))
  )
  (if (null layer)
    (setq issues (cons (cc:issue "ERROR" "UNKNOWN_LAYER_MAPPING" eq "layer does not map to approved standard") issues))
  )
  (if (null block)
    (setq issues (cons (cc:issue "ERROR" "UNKNOWN_BLOCK_MAPPING" eq "equipmentType does not map to approved block") issues))
    (if (not (tblsearch "BLOCK" block))
      (setq issues (cons (cc:issue "ERROR" "MISSING_BLOCK_DEFINITION" eq (strcat block " is not loaded in drawing")) issues))
    )
  )
  (if (or (= typeKey "ANTENNA") (= typeKey "RADIO"))
    (if (or (null az) (< az 0) (> az 359))
      (setq issues (cons (cc:issue "ERROR" "INVALID_AZIMUTH" eq "azimuth must be 0 through 359") issues))
    )
  )
  (if (or (null elev) (<= elev 0.0))
    (setq issues (cons (cc:issue "ERROR" "INVALID_ELEVATION" eq "elevationFeet must be positive") issues))
  )
  (if (or (null x) (null y))
    (setq issues (cons (cc:issue "ERROR" "MISSING_LOCATION" eq "x and y insertion coordinates are required") issues))
  )
  (if (and conf (< conf 0.90))
    (setq issues (cons (cc:issue "WARN" "LOW_CONFIDENCE" eq "confidence is below review threshold") issues))
  )

  (reverse issues)
)

(defun cc:place-row (row / layer block pt az oldLayer oldAttreq ename calloutPt)
  ;; Insert one validated row.
  ;; This function assumes blocking validation already passed.
  (setq layer (cc:map-layer (cc:get row "layer") (cc:get row "equipmentType")))
  (setq block (cc:map-block (cc:get row "equipmentType")))
  (setq pt    (cc:row-point row 0.0))
  (setq az    (cc:int-or-nil (cc:get row "azimuth")))
  (if (null az) (setq az 0))

  (cc:ensure-layer layer 1)

  ;; Save and restore AutoCAD state.
  (setq oldLayer  (getvar "CLAYER"))
  (setq oldAttreq (getvar "ATTREQ"))
  (setvar "CLAYER" layer)
  (setvar "ATTREQ" 0)

  ;; The block rotation is driven by the validated azimuth.
  (command "_.-INSERT" block pt 1.0 1.0 az)
  (setq ename (entlast))

  (setvar "ATTREQ" oldAttreq)
  (setvar "CLAYER" oldLayer)

  ;; Populate standard attributes when the block has matching tags.
  (cc:set-attr ename "EQUIPMENT_ID" (cc:get row "equipmentId"))
  (cc:set-attr ename "EQUIPMENT_TYPE" (cc:get row "equipmentType"))
  (cc:set-attr ename "SECTOR" (cc:get row "sector"))
  (cc:set-attr ename "AZIMUTH" (cc:get row "azimuth"))
  (cc:set-attr ename "ELEVATION" (cc:get row "elevationFeet"))
  (cc:set-attr ename "MOUNT_TYPE" (cc:get row "mountType"))

  ;; Add a lightweight callout so reviewers can see what changed.
  (setq calloutPt (list (+ (car pt) 8.0) (+ (cadr pt) 8.0) 0.0))
  (cc:add-line "CROWN-CALLOUT" pt calloutPt)
  (cc:add-mtext
    "CROWN-CALLOUT"
    calloutPt
    95.0
    (strcat (cc:get row "equipmentId") "\\P" (cc:get row "equipmentType") " / Sector " (cc:get row "sector"))
    2.5
  )

  ename
)

(defun cc:write-report (path lines / f line)
  ;; Write report rows in order.
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

(defun c:CC_SCOPECSV2DRAFT (/ csvPath rows row issues allIssues generated skipped reportPath flagX flagPt issue)
  (vl-load-com)

  ;; Ask the user for a CSV file. getfiled gives a normal AutoCAD file picker.
  (setq csvPath (getfiled "Select scope CSV" "" "csv" 0))

  (if (null csvPath)
    (princ "\nNo CSV selected.")
    (progn
      (setq rows (cc:read-csv csvPath))
      (if (null rows)
        (princ "\nCSV could not be read or contains no data rows.")
        (progn
          (cc:ensure-standard-layers)
          (setq allIssues (list "severity,code,equipmentId,message"))
          (setq generated 0)
          (setq skipped 0)
          (setq flagX 0.0)

          ;; Process each row independently so valid items can still be generated.
          (foreach row rows
            (setq issues (cc:validate-row row))
            (foreach issue issues
              (setq allIssues (append allIssues (list issue)))
            )

            (if (cc:has-error-p issues)
              (progn
                ;; Blocking issue: do not place the equipment. Add a review flag instead.
                (setq flagPt (cc:row-point row flagX))
                (foreach issue issues
                  (if (wcmatch issue "ERROR,*")
                    (cc:add-review-flag flagPt issue)
                  )
                )
                (setq skipped (1+ skipped))
                (setq flagX (+ flagX 25.0))
              )
              (progn
                ;; No blocking error: place the item. Warnings remain in the report.
                (cc:place-row row)
                (setq generated (1+ generated))
              )
            )
          )

          (setq reportPath (strcat (cc:outdir) (vl-filename-base csvPath) "_CC_SCOPE_REVIEW_REPORT.csv"))
          (cc:write-report reportPath allIssues)

          (command "_.REGENALL")
          (princ (strcat "\nGenerated valid equipment items: " (itoa generated)))
          (princ (strcat "\nSkipped/flagged rows: " (itoa skipped)))
          (princ (strcat "\nReview report: " reportPath))
        )
      )
    )
  )
  (princ)
)
