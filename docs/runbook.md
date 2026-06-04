# Runbook

This runbook keeps the technical proof easy to open, validate, and package.

## Share Links

Use the rendered GitHub Pages link for normal viewing:

```text
https://tsmithcode.github.io/crown-castle-cad-automation-proof/
```

Use the GitHub repository link when technical staff want to inspect source files:

```text
https://github.com/tsmithcode/crown-castle-cad-automation-proof
```

Normal GitHub file views show HTML source. GitHub Pages renders `index.html` as a web page.

## Review The Proof

1. Open the rendered brief.
2. Use the Quick Access section to open the public repo.
3. Review `README.md` for scope, caveats, and command index.
4. Review `src/load_all.lsp` as the AutoCAD load entry point.
5. Review `src/single_file_solutions/CC_SCOPECSV_TO_DRAFT.lsp` for the CSV-to-draft proof.
6. Review `samples/scope_sample.csv` for synthetic sample input rows.

## AutoCAD Demo Path

Use only a sandbox drawing or a copy of a DWG.

1. Run `APPLOAD`.
2. Load `src/load_all.lsp`.
3. Run `CC_HELP`.
4. Run `CC_MAKE_DEMO_BLOCKS`.
5. Run `CC_MKLAYERS`.
6. Run `CC_SCOPECSV2DRAFT` and select `samples/scope_sample.csv`.
7. Run `CC_VALIDATE_DWG`.

## Pre-Publish Check

Run:

```zsh
python3 scripts/verify_readiness.py
```

Then confirm:

- No private prep-kit content is included.
- No raw source archives are included.
- No `.DS_Store` files are included.
- No credentials, tokens, private keys, browser profiles, or local machine secrets are included.
- The repo and Pages links open publicly.
