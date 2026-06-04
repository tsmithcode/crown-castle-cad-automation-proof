# Technical Alignment Notes

These notes document the implementation boundary behind the AutoLISP files and rendered HTML brief.

## System Boundary

This repo shows AutoLISP as the drawing execution layer. The LISP commands create standard layers, insert approved equipment blocks, set attributes, add callouts, write review flags, and generate reports. A larger production system should keep validation rules, queueing, APIs, storage, authentication, audit history, and retry behavior outside AutoCAD.

## Proof Workflow

```text
Load src/load_all.lsp into a sandbox drawing. CC_HELP shows the command surface. CC_MAKE_DEMO_BLOCKS creates placeholder blocks because this is not a production Crown Castle template. CC_MKLAYERS creates the standard demo layers. CC_SCOPECSV2DRAFT reads the sample CSV and inserts valid rows as block references with attributes and callouts. Invalid rows, such as missing azimuth or unknown layer mapping, are not guessed; they create visible review flags and report rows. CC_VALIDATE_DWG scans the drawing and writes a CSV report that a drafter or workflow service can review.
```

## Core Principle

```text
The automation should accelerate drafting, not hide uncertainty. Missing, conflicting, or uncertain engineering data should become a visible review flag and a report item, not a silent assumption.
```

## AutoLISP vs. Service Boundary

| Layer | Use it for |
|---|---|
| AutoLISP | Lightweight drawing-local automation: layers, blocks, attributes, callouts, cleanup, plotting. |
| AutoCAD .NET API | Larger plugins, transactions, object model control, type safety, deeper CAD operations. |
| Service/API layer | Job intake, validation contracts, queueing, storage, audit trail, enterprise integrations, callbacks. |

## AWS Service-Level Architecture

```text
Internal UI -> API Gateway / API service -> job record -> S3 input package -> Step Functions + SQS -> CAD worker -> S3 output package -> review UI / notification -> CloudWatch + CloudTrail audit trail
```

Use API Gateway for job submission and status endpoints, S3 for versioned input/output drawing packages, Step Functions for multi-stage orchestration, SQS for the service-bus-style worker queue, CloudWatch for logs/metrics/alarms, and CloudTrail for audit evidence. Keep heavy CAD execution outside Lambda unless the operation is very small and runtime-safe. The CAD worker choice should be spiked early: Windows EC2 worker, ECS/Fargate, EKS, Autodesk Platform Services, or hybrid.

## Target Cloud Use Case

The user-facing action should be simple: enter an order number and receive a generated review package. The platform should gather or receive the approved input bundle before CAD execution:

- Template DWG.
- Source DWGs.
- PDF references.
- JSON metadata.
- Statement of work or normalized rule set.
- Versioned template/rule/input identifiers.

The automation worker then inserts source DWGs into the template, loads JSON into DWG properties and title blocks, applies SOW-driven mutations, plots a PDF preview, and returns a DWG/PDF/report/log bundle.

## Confidence-Aware Drawing Output

The most important drawing quality rule is to avoid hidden guesses. Every generated element should be explainable as one of the following:

- Source-of-truth driven.
- Rule-derived.
- Assumed.
- Conflicting.
- Missing data.
- Blocked pending human judgment.

Examples that should produce explicit review evidence include ambiguous tower face/position, undefined antenna position semantics, incomplete ground-equipment data, or legacy template variation that breaks a rule.

## Delivery, CI/CD, And Observability

For a tight small-team timeline, use thin PRs and ownership boundaries by module, namespace, API boundary, and CAD command surface. CI/CD should include lint/static checks, unit tests for parsing and validation logic, regression tests from drafter corrections, and an integration smoke test that verifies DWG/PDF/report/log artifacts.

Structured logs should include job ID, order number, input hash, template version, rule version, worker version, artifact links, error category, retry count, runtime, and confidence flag counts. CloudWatch should expose queue age, worker failures, validation failures, artifact packaging errors, and runtime trends. CloudTrail should preserve API activity and access evidence.

## AI Governance

AI can help draft tests, summarize approved requirements, generate synthetic sample data, and compare validation reports. It should not receive proprietary drawings, private source-system data, credentials, or client files through public AI tools. AI-assisted code should still pass normal PR review, dependency review, tests, and security gates.

## Requirements To Confirm Before Production

1. What are the canonical templates, block names, layer names, and attribute tags?
2. Which fields are required, optional, uncertain, or engineering-controlled?
3. What should happen on partial failure: block the whole drawing or generate valid items and flag invalid ones?
4. What artifacts are required: DWG, PDF, validation report, change summary, logs?
5. Who signs off on standards updates when legacy drawings drift?
6. Which CAD execution environment is acceptable: desktop AutoCAD worker, AutoCAD .NET plugin, APS Design Automation, or hybrid?

## Production Readiness Caveat

This proof is intentionally compact. It is designed to show the drawing execution pattern and review discipline. Production readiness would require versioned templates, real validation contracts, test drawings, job IDs, structured logs, access controls, and drafter correction feedback loops.
