# {CLIENT_OR_PROJECT_NAME} Technical Alignment Brief

Prepared by: {YOUR_NAME_OR_COMPANY}

Audience: {CLIENT_TEAM_OR_STAKEHOLDERS}

Rendered brief: {RENDERED_BRIEF_URL}

Source proof: {GITHUB_REPO_URL}

Status: {DRAFT | CLIENT-SAFE | PUBLIC-SAFE}

## One-Line Summary

{CLIENT_OR_PROJECT_NAME} appears to need {CORE_OUTCOME} by connecting {INPUTS} to {AUTOMATION_OR_DELIVERY_SYSTEM} with {VALIDATION_OR_REVIEW_MODEL}.

Example shape:

```text
intake -> validated inputs -> async workflow -> worker/runtime -> generated artifacts -> validation report -> human review -> release/pilot path
```

## What The Discussion Clarified

- Current workflow: {CURRENT_WORKFLOW}
- Primary pain: {PRIMARY_PAIN}
- Business driver: {BUSINESS_DRIVER}
- Technical driver: {TECHNICAL_DRIVER}
- Trust or risk issue: {TRUST_OR_RISK_ISSUE}
- Urgency or timing: {URGENCY}

Public-safe wording tip: write "the technical discussion clarified" instead of naming private participants or quoting raw conversation text.

## Target Use Case

User action:

```text
{USER_ACTION}
```

Input package:

- {INPUT_1}
- {INPUT_2}
- {INPUT_3}
- {INPUT_4}
- {INPUT_5}

Expected output package:

- {OUTPUT_1}
- {OUTPUT_2}
- {OUTPUT_3}
- {OUTPUT_4}
- {OUTPUT_5}

## Architecture Map

```text
{FRONTEND_OR_UI} -> {API_LAYER} -> {JOB_RECORD_OR_STATE} -> {STORAGE_INPUT} -> {ORCHESTRATION_AND_QUEUE} -> {WORKER_OR_RUNTIME} -> {STORAGE_OUTPUT} -> {REVIEW_OR_NOTIFICATION} -> {OBSERVABILITY_AND_AUDIT}
```

## Expected Services And Why

| Layer | Service or technology | Why |
|---|---|---|
| UI | {UI_SERVICE} | {UI_REASON} |
| API | {API_SERVICE} | {API_REASON} |
| State | {STATE_SERVICE} | {STATE_REASON} |
| Storage | {STORAGE_SERVICE} | {STORAGE_REASON} |
| Orchestration | {ORCHESTRATION_SERVICE} | {ORCHESTRATION_REASON} |
| Queue/broker | {QUEUE_SERVICE} | {QUEUE_REASON} |
| Worker/runtime | {WORKER_SERVICE} | {WORKER_REASON} |
| Logs/metrics | {OBSERVABILITY_SERVICE} | {OBSERVABILITY_REASON} |
| Audit/security | {AUDIT_SECURITY_SERVICE} | {AUDIT_SECURITY_REASON} |

## Worker Or Runtime Decision

| Option | Use when | Spike question |
|---|---|---|
| {OPTION_1} | {WHEN_1} | {SPIKE_QUESTION_1} |
| {OPTION_2} | {WHEN_2} | {SPIKE_QUESTION_2} |
| {OPTION_3} | {WHEN_3} | {SPIKE_QUESTION_3} |
| Hybrid | A specialized runtime is required but the platform still owns intake, storage, orchestration, and audit. | Which layer owns retries, cleanup, and failure evidence? |

## Confidence And Review Model

Every generated artifact should be explainable as:

- Source-of-truth driven.
- Rule-derived.
- Assumed.
- Conflicting.
- Missing data.
- Blocked pending human judgment.

Reviewer evidence should include:

- Input version.
- Rule version.
- Template or configuration version.
- Generated artifact links.
- Warnings and failures.
- What changed, what was skipped, and why.

## Proof Files

| Proof file | What it demonstrates |
|---|---|
| `{PROOF_FILE_1}` | {PROOF_POINT_1} |
| `{PROOF_FILE_2}` | {PROOF_POINT_2} |
| `{PROOF_FILE_3}` | {PROOF_POINT_3} |
| `{PROOF_FILE_4}` | {PROOF_POINT_4} |

## Delivery Readiness

Small-team operating model:

- Ownership by module, route, namespace, workflow stage, or runtime boundary.
- Small PRs with obvious file scope.
- Short checkpoints around blockers, assumptions, and acceptance evidence.
- Release notes tied to proof artifacts and validation results.

Quality gates:

- Lint/static checks.
- Unit tests for parsing, rules, and validation.
- Regression tests from reviewer corrections.
- Integration smoke test for the main workflow.
- Artifact validation before release.

Observability:

- Job ID or request ID.
- Input hash/version.
- Rule/config version.
- Runtime/worker version.
- Output artifact links.
- Error category and retry count.
- Runtime duration and queue age.

## AI Governance

Good uses:

- Drafting test cases.
- Summarizing approved requirements.
- Generating synthetic sample data.
- Creating checklists.
- Comparing validation reports.

Guardrails:

- No proprietary files, credentials, private emails, meeting links, or confidential source-system data in public AI tools.
- No AI-generated technical claims without proof.
- No AI-written code bypassing tests, review, dependency checks, or security gates.
- Keep assumptions visible.

## Pilot Plan

| Phase | Activities | Deliverable |
|---|---|---|
| Days 1-2 | Confirm one workflow, sample files, acceptance criteria, and review owner. | Scope contract and pass/warn/fail criteria. |
| Days 3-6 | Build intake, validation, prototype worker/runtime, and artifact generation. | Working proof path. |
| Days 7-9 | Run sample set, capture reviewer feedback, convert defects into regression cases. | Defect log and regression set. |
| Days 10-14 | Stabilize status, logging, retry behavior, and demo path. | Pilot review with risks, metrics, and expansion plan. |

## Open Questions

1. {QUESTION_1}
2. {QUESTION_2}
3. {QUESTION_3}
4. {QUESTION_4}
5. {QUESTION_5}

## Share Links

- Rendered brief: {RENDERED_BRIEF_URL}
- Source repo: {GITHUB_REPO_URL}
- Key proof file: {KEY_PROOF_FILE_URL}
- Architecture addendum: {ARCHITECTURE_DOC_URL}

