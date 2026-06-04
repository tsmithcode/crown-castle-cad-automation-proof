# Crown Castle CAD Automation Technical Alignment Proof

Prepared by CAD Guardian LLC as a public technical alignment proof for Crown Castle CAD automation.

This package estimates a practical implementation path for drafter-ready CAD automation:

```text
validated scope data -> controlled AutoCAD execution -> DWG/PDF/report review package
```

It includes a rendered technical brief, a compact AutoLISP proof, sample scope data, and documentation for the automation boundary between drawing-local commands and a larger enterprise service layer.

## Quick Links

- Rendered brief: <https://tsmithcode.github.io/crown-castle-cad-automation-proof/>
- GitHub repo: <https://github.com/tsmithcode/crown-castle-cad-automation-proof>
- Public HTML file: [`client-brief/CrownCastle_CAD_Automation_Technical_Alignment_Brief.html`](client-brief/CrownCastle_CAD_Automation_Technical_Alignment_Brief.html)
- AWS architecture addendum: [`docs/AWS_ARCHITECTURE.md`](docs/AWS_ARCHITECTURE.md)
- AutoLISP loader: [`src/load_all.lsp`](src/load_all.lsp)
- Sample scope data: [`samples/scope_sample.csv`](samples/scope_sample.csv)

## Package Context

- Prepared by: CAD Guardian LLC
- Alignment context: Crown Castle CAD automation technical proof
- Primary audience: Crown Castle technical stakeholders and engineering staff

The person and recipient details above are package context provided for this proof. Public Crown Castle company context in the HTML brief is sourced from public Crown Castle pages and releases.

## What This Demonstrates

- Creating and checking standard CAD layers.
- Inserting scoped equipment blocks onto approved layers.
- Updating block attributes from normalized scope data.
- Adding callouts and explicit review flags.
- Producing validation reports instead of hiding uncertainty.
- Cleaning legacy drawings conservatively.
- Drawing the line between AutoLISP and a larger C#/.NET/API/AWS service layer.
- Mapping an AWS-native architecture for API Gateway, S3, Step Functions, SQS, CAD workers, CloudWatch, CloudTrail, KMS, and Secrets Manager.

## Repo Structure

```text
.
|-- index.html
|-- client-brief/
|   `-- CrownCastle_CAD_Automation_Technical_Alignment_Brief.html
|-- docs/
|   |-- CODE_WALKTHROUGH.md
|   |-- TECHNICAL_ALIGNMENT_NOTES.md
|   |-- runbook.md
|   `-- sanitization-checklist.md
|-- samples/
|   `-- scope_sample.csv
|-- scripts/
|   `-- verify_readiness.py
`-- src/
    |-- load_all.lsp
    |-- common/
    |-- demo_support/
    |-- single_commands/
    `-- single_file_solutions/
```

## Quick Start In AutoCAD

Use a sandbox drawing or a copy of a DWG. Do not run cleanup or normalization directly against a production source drawing.

1. Open AutoCAD.
2. Open a blank drawing or a copy of an existing drawing.
3. Run `APPLOAD`.
4. Load `src/load_all.lsp`.
5. Run `CC_HELP`.
6. For a blank drawing demo, run `CC_MAKE_DEMO_BLOCKS`.
7. Create or check layers with `CC_MKLAYERS`.
8. Run `CC_SCOPECSV2DRAFT` and select `samples/scope_sample.csv`.
9. Validate the drawing with `CC_VALIDATE_DWG`.

The sample CSV intentionally includes invalid rows. The point is not to automate blindly; it is to place valid scoped items and flag missing, conflicting, or uncertain fields for drafter review.

## Command Index

| Command | File | Technical proof point |
|---|---|---|
| `CC_HELP` | [`src/single_commands/CC_HELP.lsp`](src/single_commands/CC_HELP.lsp) | Lists the command surface inside AutoCAD. |
| `CC_MAKE_DEMO_BLOCKS` | [`src/demo_support/CC_MAKE_DEMO_BLOCKS.lsp`](src/demo_support/CC_MAKE_DEMO_BLOCKS.lsp) | Creates simple demo blocks when no production template is available. |
| `CC_MKLAYERS` | [`src/single_commands/CC_MKLAYERS.lsp`](src/single_commands/CC_MKLAYERS.lsp) | Standardizes layers before placing entities. |
| `CC_INSERT_ANTENNA` | [`src/single_commands/CC_INSERT_ANTENNA.lsp`](src/single_commands/CC_INSERT_ANTENNA.lsp) | Places one antenna with validated azimuth/elevation. |
| `CC_SETATTR` | [`src/single_commands/CC_SETATTR_SELECTED.lsp`](src/single_commands/CC_SETATTR_SELECTED.lsp) | Updates a selected block attribute. |
| `CC_TITLE_SITE` | [`src/single_commands/CC_TITLEBLOCK_SITE.lsp`](src/single_commands/CC_TITLEBLOCK_SITE.lsp) | Bulk-updates title block fields in paper space. |
| `CC_CALLOUT` | [`src/single_commands/CC_CALLOUT.lsp`](src/single_commands/CC_CALLOUT.lsp) | Adds a deterministic leader/callout pair. |
| `CC_REVIEW_FLAG` | [`src/single_commands/CC_REVIEW_FLAG.lsp`](src/single_commands/CC_REVIEW_FLAG.lsp) | Adds a visible review flag for unresolved engineering data. |
| `CC_CLEANUP` | [`src/single_commands/CC_CLEANUP_AUDIT_PURGE.lsp`](src/single_commands/CC_CLEANUP_AUDIT_PURGE.lsp) | Runs a conservative audit/purge cleanup pass. |
| `CC_PLOT_PDF` | [`src/single_commands/CC_PLOT_CURRENT_LAYOUT_PDF.lsp`](src/single_commands/CC_PLOT_CURRENT_LAYOUT_PDF.lsp) | Plots the current layout using its page setup. |
| `CC_SCOPECSV2DRAFT` | [`src/single_file_solutions/CC_SCOPECSV_TO_DRAFT.lsp`](src/single_file_solutions/CC_SCOPECSV_TO_DRAFT.lsp) | Ingests scope CSV, validates rows, places valid items, flags issues, and writes a report. |
| `CC_VALIDATE_DWG` | [`src/single_file_solutions/CC_DWG_VALIDATION_REPORT.lsp`](src/single_file_solutions/CC_DWG_VALIDATION_REPORT.lsp) | Writes a standards, attribute, and review-flag validation report. |
| `CC_NORMALIZE_LEGACY` | [`src/single_file_solutions/CC_NORMALIZE_LEGACY_DWG.lsp`](src/single_file_solutions/CC_NORMALIZE_LEGACY_DWG.lsp) | Performs auditable legacy layer normalization. |

## AWS Architecture Addendum

The technical discussion clarified that the service-level cloud map matters as much as the AutoLISP proof. The AWS reference flow is:

```text
Internal UI -> API Gateway / API service -> job record -> S3 input package -> Step Functions + SQS -> CAD worker -> S3 output package -> review UI / notification -> CloudWatch + CloudTrail audit trail
```

See [`docs/AWS_ARCHITECTURE.md`](docs/AWS_ARCHITECTURE.md) for the concise service map, worker-runtime decision matrix, and early qualification questions.

## Core Technical Stance

AutoLISP is the drawing-local execution layer. It is useful for layer checks, block insertion, attribute updates, callouts, cleanup, plotting, and reporting inside AutoCAD. Production orchestration should keep validation contracts, queues, authentication, persistence, versioned rules, retries, and integration logic in a service layer such as C#/.NET, Java, Node.js, or an internal platform standard.

The automation should accelerate drafting, not hide uncertainty. Missing, conflicting, or uncertain engineering data should become a visible review flag and a report item.

## Production Caveats

This is a sample technical proof, not an official Crown Castle production standard. In production, I would add:

- Versioned drawing templates and block libraries.
- Stronger schema validation outside AutoCAD.
- Transaction boundaries through the AutoCAD .NET API where appropriate.
- Centralized logs, job IDs, access control, and retention policies.
- Regression test drawings based on drafter corrections.
- CI checks for LISP load/syntax plus sandbox AutoCAD smoke tests.

## Legal And Privacy Notes

This repository and rendered brief are unofficial technical alignment artifacts prepared by CAD Guardian LLC. They are not official Crown Castle documents. The sample files use synthetic demonstration data and do not include proprietary Crown Castle project drawings, credentials, private systems, or confidential source data. The HTML brief does not include analytics or tracking. Any session notes typed into the brief are stored only in the viewer's browser through `localStorage` and are not committed back to this repository.
