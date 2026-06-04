# Quick Start AutoLISP Syntax Guide

This guide covers the AutoLISP syntax used by the CAD automation proof package.

## 1. Everything is a list-shaped expression

AutoLISP is evaluated from inside parentheses:

```lisp
(function-name argument1 argument2 argument3)
```

Example:

```lisp
(setq layerName "CROWN-ANTENNA")
```

Read it as:

```text
Call setq. Store the string CROWN-ANTENNA in variable layerName.
```

## 2. Comments start with semicolons

```lisp
;;; File/header comment
;;  Explanation comment
;   Small inline note
```

The comments in this repo focus on implementation intent, drawing safety, and operational boundaries.

## 3. Define a function with `defun`

```lisp
(defun cc:add-one (x / result)
  (setq result (+ x 1))
  result
)
```

Important parts:

| Syntax | Meaning |
|---|---|
| `defun` | Defines a function. |
| `cc:add-one` | Function name. Prefixing helpers with `cc:` avoids collisions. |
| `(x / result)` | `x` is an argument; variables after `/` are local variables. |
| Last expression | Return value. AutoLISP returns the last evaluated expression. |

## 4. Create an AutoCAD command with `c:`

A function named `c:COMMANDNAME` becomes a command you can type into AutoCAD.

```lisp
(defun c:CC_MKLAYERS (/)
  (cc:ensure-standard-layers)
  (princ "\nLayers are ready.")
  (princ)
)
```

You run it by typing:

```text
CC_MKLAYERS
```

## 5. Use `setq` for variables

```lisp
(setq siteId "ATL-042")
(setq azimuth 30)
(setq insertPoint (list 0.0 0.0 0.0))
```

AutoLISP variables are dynamically typed. A variable can hold a string, number, list, entity name, selection set, or COM object.

## 6. Strings, numbers, and points

```lisp
"CROWN-ANTENNA"        ; string
30                     ; integer
145.5                  ; real number
'(0.0 0.0 0.0)          ; quoted list, often used as a point
(list 0.0 0.0 0.0)      ; builds the same point dynamically
```

The single quote prevents AutoLISP from evaluating a list as a function call.

```lisp
'(1 2 3)     ; data list
(+ 1 2 3)    ; function call, returns 6
```

## 7. `if`, `cond`, and `progn`

`if` has one test, one true branch, and optionally one false branch.

```lisp
(if (tblsearch "LAYER" "CROWN-ANTENNA")
  (princ "\nLayer exists.")
  (princ "\nLayer is missing.")
)
```

Use `progn` when a branch needs multiple statements.

```lisp
(if point
  (progn
    (setq text "Review required")
    (cc:add-review-flag point text)
  )
)
```

Use `cond` when there are several branches.

```lisp
(cond
  ((= equipmentType "ANTENNA") "ANTENNA_STANDARD")
  ((= equipmentType "RADIO")   "RADIO_STANDARD")
  (T nil)
)
```

`T` is the default/fallback branch.

## 8. Lists, pairs, `assoc`, `car`, and `cdr`

AutoLISP often uses association lists.

```lisp
(setq row '(("SITEID" . "ATL-042") ("AZIMUTH" . "30")))
```

Get a value:

```lisp
(cdr (assoc "AZIMUTH" row))
```

Read it as:

```text
Find the pair whose key is AZIMUTH, then return the value side of the pair.
```

Basic list functions:

| Function | Meaning |
|---|---|
| `car` | First item of a list, or key side of a pair. |
| `cdr` | Rest of list, or value side of a pair. |
| `cons` | Add an item to the front of a list, or build a pair. |
| `foreach` | Iterate through each item in a list. |
| `reverse` | Reverse list order, often after repeatedly using `cons`. |

## 9. Selection sets with `ssget`

`ssget` selects AutoCAD entities.

```lisp
(setq ss (ssget "_X" '((0 . "INSERT"))))
```

Read it as:

```text
Select all entities in the drawing where DXF group code 0 equals INSERT.
```

Common filters:

| DXF code | Meaning |
|---:|---|
| `0` | Entity type, such as `INSERT`, `LINE`, `MTEXT`. |
| `2` | Block name for inserts. |
| `8` | Layer name. |
| `67` | Space flag: `0` model space, `1` paper space. |

Loop through a selection set:

```lisp
(setq i 0)
(while (< i (sslength ss))
  (setq e (ssname ss i))
  ;; Do something with entity e.
  (setq i (1+ i))
)
```

## 10. Entity data with `entget`, `entmod`, and `entmakex`

Get raw DXF-style data:

```lisp
(setq data (entget entityName))
```

Modify entity data:

```lisp
(setq data (subst (cons 8 "CROWN-ANTENNA") (assoc 8 data) data))
(entmod data)
(entupd entityName)
```

Create a new entity:

```lisp
(entmakex
  (list
    '(0 . "LINE")
    '(100 . "AcDbEntity")
    '(8 . "CROWN-CALLOUT")
    '(100 . "AcDbLine")
    (cons 10 '(0.0 0.0 0.0))
    (cons 11 '(10.0 10.0 0.0))
  )
)
```

## 11. Table lookup with `tblsearch`

`tblsearch` checks AutoCAD symbol tables such as layers and blocks.

```lisp
(tblsearch "LAYER" "CROWN-ANTENNA")
(tblsearch "BLOCK" "ANTENNA_STANDARD")
```

It returns data when found and `nil` when missing.

## 12. AutoCAD command automation with `command`

`command` sends command-line input to AutoCAD.

```lisp
(command "_.AUDIT" "_Y")
(command "_.-PURGE" "_Regapps" "*" "_N")
(command "_.REGENALL")
```

Conventions:

| Prefix | Meaning |
|---|---|
| `_` | Use the English command name regardless of localization. |
| `.` | Use the built-in command, bypassing redefinitions. |
| `-` | Use command-line version instead of dialog UI. |

## 13. ActiveX/COM with `vl-load-com`

For attributes, plotting, model space, and object properties, the repo uses Visual LISP ActiveX helpers.

```lisp
(vl-load-com)
(setq obj (vlax-ename->vla-object entityName))
(vla-get-HasAttributes obj)
(vlax-invoke obj 'GetAttributes)
```

Implementation note:

```text
I use raw DXF functions for simple entity creation and ActiveX when object properties or attributes are easier through the AutoCAD object model.
```

## 14. System variables should be restored

Many commands temporarily change AutoCAD state. Capture and restore it.

```lisp
(setq oldLayer (getvar "CLAYER"))
(setvar "CLAYER" "CROWN-ANTENNA")
;; Make drawing changes here.
(setvar "CLAYER" oldLayer)
```

This is a professional habit. It prevents the automation from leaving the drafter in a surprising state.

## 15. End commands cleanly with `princ`

```lisp
(princ "\nDone.")
(princ)
```

The final `(princ)` exits quietly without printing a trailing return value.

## 16. The main pattern in this repo

Most files follow this structure:

```lisp
(vl-load-com)

(defun cc:helper-name (... / localVars)
  ;; Small helper function.
)

(defun c:CC_COMMAND_NAME (... / localVars)
  ;; 1. Prompt or read input.
  ;; 2. Validate input before changing the DWG.
  ;; 3. Create/check layers and blocks.
  ;; 4. Insert/update entities.
  ;; 5. Write report or visible review flag.
  ;; 6. Restore AutoCAD state.
  (princ)
)
```

## 17. AutoLISP role in the system

```text
AutoLISP is excellent for lightweight AutoCAD drawing operations: layer creation, selection sets, block inserts, attribute edits, callouts, cleanup, plotting, and report files. I would not put the entire enterprise workflow inside AutoLISP. I would validate and orchestrate jobs in a service layer, then let AutoLISP or the .NET API execute deterministic drawing changes.
```
