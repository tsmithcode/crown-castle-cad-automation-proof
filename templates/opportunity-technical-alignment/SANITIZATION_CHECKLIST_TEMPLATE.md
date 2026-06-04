# Sanitization Checklist Template

Use this before sharing any opportunity/project proof publicly or with a client.

## Remove Or Redact

- Raw conversation records.
- Private emails and message bodies.
- Meeting links, meeting IDs, phone numbers, and calendar descriptions.
- Recruiter, evaluator, or internal staff names unless explicitly approved and necessary.
- Compensation, rate, staffing, or internal urgency details unless deliberately intended for the audience.
- Credentials, tokens, cookies, API keys, `.env` files, private keys, and browser profile data.
- Proprietary client drawings, source data, databases, reports, screenshots, and exports.
- Private prep files, scratch notes, and non-shareable AI prompts.
- Local machine paths that expose private folder structure.

## Confirm

- Sample data is synthetic or approved for sharing.
- Public claims are supported by proof files or clearly labeled as estimates.
- Links open correctly.
- Rendered HTML/PDF displays correctly.
- GitHub file view is not used as the main HTML viewing link unless raw source is intended.
- All in-page links are client-safe.
- The repo has no raw zip archives unless intentionally released.
- The final package passes a scan for private terms and known sensitive strings.

## Public-Safe Language

Use:

- "technical discussion"
- "stakeholders"
- "source systems"
- "public-safe proof"
- "estimated implementation path"
- "pilot path"

Avoid:

- Raw quotes.
- Private participant names.
- Internal staffing details.
- Screening or hiring-process language in client-facing proof unless the artifact is explicitly private.
- Self-undermining framing.
