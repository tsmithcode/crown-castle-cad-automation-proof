# Code Walkthrough

## `src/load_all.lsp`

Loads the common helper library, demo block support, single command files, and single-file solution commands. It also defines a small loader helper that resolves paths relative to `load_all.lsp`.

## `src/common/cc_common.lsp`

Shared utility functions:

- string normalization: `cc:trim`, `cc:key`
- AutoCAD object access: `cc:acad`, `cc:doc`, `cc:ms`
- standard layers: `cc:ensure-layer`, `cc:ensure-standard-layers`
- block attributes: `cc:set-attr`, `cc:get-attr`, `cc:effective-name`
- drafting helpers: `cc:add-line`, `cc:add-mtext`, `cc:add-review-flag`
- reporting helpers: `cc:outdir`, `cc:write-lines`

## Single command files

These are short, focused commands. Each file isolates one CAD automation concept.

| File | Core concept |
|---|---|
| `CC_MKLAYERS.lsp` | Create approved layers before drawing changes. |
| `CC_INSERT_ANTENNA.lsp` | Validate prompt input, insert block, set attributes. |
| `CC_SETATTR_SELECTED.lsp` | Modify attributes on a selected block reference. |
| `CC_TITLEBLOCK_SITE.lsp` | Find paper-space title blocks and update known tags. |
| `CC_CALLOUT.lsp` | Create callout line and MTEXT on a controlled layer. |
| `CC_REVIEW_FLAG.lsp` | Add visible review notes instead of making assumptions. |
| `CC_CLEANUP_AUDIT_PURGE.lsp` | Controlled audit/purge cleanup with state restore. |
| `CC_PLOT_CURRENT_LAYOUT_PDF.lsp` | Plot current layout to review PDF using page setup. |

## Single-file solutions

These files are self-contained. They duplicate helper functions intentionally so the file can be shared or loaded by itself.

| File | Core concept |
|---|---|
| `CC_SCOPECSV_TO_DRAFT.lsp` | Reads scope CSV, validates rows, inserts valid equipment, flags invalid rows, writes report. |
| `CC_DWG_VALIDATION_REPORT.lsp` | Scans drawing for required layers, block attributes, and unresolved review flags. |
| `CC_NORMALIZE_LEGACY_DWG.lsp` | Maps known legacy layer aliases to approved layers and writes a normalization report. |

## Why the comments are verbose

The source emphasizes implementation intent. In a production repository, some comments could be shortened after tests and documentation cover the behavior. In this proof package, the comments make the automation pattern explicit:

```text
validate first -> change drawing deterministically -> flag uncertainty -> write a review artifact
```
