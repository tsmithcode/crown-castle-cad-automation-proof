;;; CC_INSERT_ANTENNA.lsp
;;; Command: CC_INSERT_ANTENNA
;;;
;;; Proof point:
;;; This is a small drawing-local operation: validate simple input, insert a known
;;; block, put it on the correct layer, and populate attributes. Larger validation
;;; and job orchestration should live outside AutoLISP.

(defun c:CC_INSERT_ANTENNA (/ oldAttreq oldLayer pt equipmentId sector az elev ent)
  (vl-load-com)

  ;; Production drawings should already have approved blocks loaded from a template.
  ;; For a blank-drawing demo, run CC_MAKE_DEMO_BLOCKS first.
  (if (not (tblsearch "BLOCK" "ANTENNA_STANDARD"))
    (princ "\nMissing block definition: ANTENNA_STANDARD. Run CC_MAKE_DEMO_BLOCKS or load the standard template.")
    (progn
      ;; Prompt for the minimal fields that would usually come from normalized scope data.
      (setq equipmentId (getstring T "\nEquipment ID, e.g. ANT-001: "))
      (setq sector      (getstring T "\nSector, e.g. A/B/C: "))
      (setq az          (getint "\nAzimuth 0-359 degrees: "))
      (setq elev        (getreal "\nElevation feet: "))
      (setq pt          (getpoint "\nInsertion point: "))

      ;; Guard clause: do not change the drawing when required engineering data is invalid.
      (if (or (= (cc:trim equipmentId) "")
              (= (cc:trim sector) "")
              (null az)
              (< az 0)
              (> az 359)
              (null elev)
              (<= elev 0.0)
              (null pt))
        (princ "\nInvalid or incomplete input. Command cancelled before changing drawing.")
        (progn
          (cc:ensure-standard-layers)

          ;; Save user state. Commands should not leave surprising settings behind.
          (setq oldAttreq (getvar "ATTREQ"))
          (setq oldLayer  (getvar "CLAYER"))

          ;; ATTREQ=0 prevents AutoCAD from stopping at attribute prompts during insert.
          ;; We set attributes programmatically after insertion.
          (setvar "CLAYER" "CROWN-ANTENNA")
          (setvar "ATTREQ" 0)
          (command "_.-INSERT" "ANTENNA_STANDARD" pt 1.0 1.0 az)
          (setq ent (entlast))

          ;; Restore user state immediately after the insert.
          (setvar "ATTREQ" oldAttreq)
          (setvar "CLAYER" oldLayer)

          ;; Attribute tags are the contract between scope data and the CAD block.
          (cc:set-attr ent "EQUIPMENT_ID" equipmentId)
          (cc:set-attr ent "EQUIPMENT_TYPE" "ANTENNA")
          (cc:set-attr ent "SECTOR" sector)
          (cc:set-attr ent "AZIMUTH" (itoa az))
          (cc:set-attr ent "ELEVATION" (rtos elev 2 2))

          (princ "\nAntenna inserted on CROWN-ANTENNA and attributes populated.")
        )
      )
    )
  )
  (princ)
)
