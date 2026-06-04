# Opportunity Technical Alignment Template

Use this template pack to turn any opportunity, client conversation, project discovery call, or technical screen into a public-safe proof artifact.

The goal is to create a shareable brief that shows:

- What problem was heard.
- What system shape is implied.
- What proof files or demos support the claim.
- What architecture would be used.
- What delivery controls reduce risk.
- What follow-up message should be sent.

## Files

| File | Use |
|---|---|
| `TECHNICAL_ALIGNMENT_BRIEF_TEMPLATE.md` | Main reusable brief structure. |
| `TEAMS_OR_EMAIL_SHARE_TEMPLATE.md` | Copy/paste message for a rendered brief and source repo. |
| `SANITIZATION_CHECKLIST_TEMPLATE.md` | Public-safety checklist before sharing. |

## Recommended Workflow

1. Copy this folder into a new opportunity repo or working folder.
2. Replace every `{PLACEHOLDER}` before sharing.
3. Keep private names, raw conversation text, private emails, meeting links, and proprietary files out of public artifacts.
4. Build the actual proof first: code, demo, sample data, architecture map, validation report, or walkthrough.
5. Publish the rendered brief through GitHub Pages, a docs site, or a client-safe PDF.
6. Link the source repo and rendered brief from the share message.

## Public-Safe Rule

Do not publish raw opportunity intelligence. Publish the sanitized technical shape:

```text
problem -> input contract -> architecture -> proof artifact -> validation -> pilot path
```

