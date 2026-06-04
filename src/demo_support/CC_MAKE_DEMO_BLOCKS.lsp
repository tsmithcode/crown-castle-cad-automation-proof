;;; CC_MAKE_DEMO_BLOCKS.lsp
;;; Command: CC_MAKE_DEMO_BLOCKS
;;;
;;; Purpose:
;;; Create simple placeholder block definitions so the repo can be demonstrated in
;;; a blank AutoCAD drawing. In production, these blocks would come from Crown's
;;; approved template/block library.

(vl-load-com)

(defun cc:demo-attdef (tag prompt y /)
  ;; Create one attribute definition inside the current block definition.
  ;; This function is called between BLOCK and ENDBLK records.
  (entmakex
    (list
      '(0 . "ATTDEF")
      '(100 . "AcDbEntity")
      '(8 . "0")
      '(100 . "AcDbText")
      (cons 10 (list 3.0 y 0.0))
      (cons 40 0.8)
      '(1 . "")
      '(50 . 0.0)
      '(7 . "Standard")
      '(72 . 0)
      '(100 . "AcDbAttributeDefinition")
      (cons 3 prompt)
      (cons 2 tag)
      '(70 . 0)
      '(73 . 0)
      '(74 . 0)
      (cons 11 (list 3.0 y 0.0))
    )
  )
)

(defun cc:make-demo-block (blockName radius /)
  ;; Create a small circular symbol with the common equipment attributes.
  ;; Existing blocks are left alone to avoid overwriting a real template standard.
  (if (not (tblsearch "BLOCK" blockName))
    (progn
      (entmakex
        (list
          '(0 . "BLOCK")
          '(100 . "AcDbEntity")
          '(8 . "0")
          '(100 . "AcDbBlockBegin")
          (cons 2 blockName)
          '(70 . 0)
          (cons 10 (list 0.0 0.0 0.0))
        )
      )
      (entmakex
        (list
          '(0 . "CIRCLE")
          '(100 . "AcDbEntity")
          '(8 . "0")
          '(100 . "AcDbCircle")
          (cons 10 (list 0.0 0.0 0.0))
          (cons 40 radius)
        )
      )
      (cc:demo-attdef "EQUIPMENT_ID" "Equipment ID" 2.0)
      (cc:demo-attdef "EQUIPMENT_TYPE" "Equipment Type" 1.0)
      (cc:demo-attdef "SECTOR" "Sector" 0.0)
      (cc:demo-attdef "AZIMUTH" "Azimuth" -1.0)
      (cc:demo-attdef "ELEVATION" "Elevation" -2.0)
      (cc:demo-attdef "MOUNT_TYPE" "Mount Type" -3.0)
      (entmakex '((0 . "ENDBLK") (100 . "AcDbBlockEnd")))
    )
  )
  blockName
)

(defun c:CC_MAKE_DEMO_BLOCKS (/)
  ;; The command creates enough block definitions for the sample CSV demo.
  ;; It intentionally does not redefine existing blocks.
  (vl-load-com)
  (cc:make-demo-block "ANTENNA_STANDARD" 2.0)
  (cc:make-demo-block "RADIO_STANDARD" 1.5)
  (cc:make-demo-block "MOUNT_STANDARD" 2.5)
  (princ "\nDemo block definitions checked/created: ANTENNA_STANDARD, RADIO_STANDARD, MOUNT_STANDARD.")
  (princ)
)
