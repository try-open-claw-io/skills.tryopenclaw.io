# skills.tryopenclaw.io

AI-friendly web home for **Platform Skills** used by OpenClaw use-case bundles.

## Why this repo exists

Platform Skills ship inside every use-case bundle (see `toc-use-cases/use-case/_platform/skills/`). Each skill has a bundled `SKILL.md` that loads into the agent's context — but its **playbooks** (case-specific instructions, schemas, templates) are large and **mutable**: we improve them as we learn.

If playbooks live only in the bundle, every improvement requires re-packaging and re-deploying. Instead:

- `SKILL.md` (bundled) — thin router. Loads on every agent turn. Lists hard rules + STOP criteria + URLs of playbooks.
- This repo (web) — playbooks served as raw markdown. Agents fetch on-demand via `WebFetch` / `curl`. Edits go live immediately.

## URL contract

Base URL (current): `https://raw.githubusercontent.com/try-open-claw-io/skills.tryopenclaw.io/main/`

Future (when DNS lands): `https://skills.tryopenclaw.io/` — same paths, just shorter host.

Indexes:
- Root index: `llms.txt` — lists every skill hosted here.
- Per-skill index: `<skill-name>/llms.txt` — lists every playbook + reference inside that skill.

## AI-friendly URL rules (enforced)

Every file in this repo follows these rules so any agent can `fetch → understand` without help:

1. **Raw markdown / YAML / plain text only** — no HTML wrappers, no JS rendering.
2. **One topic per file** — agents fetch selectively, never pull a 200KB monolith.
3. **Stable paths** — never rename a published file. To replace, write a new file and update the index. Old URL keeps working (or 404s loudly — no silent redirects).
4. **`llms.txt` index per directory** — first line `# <Title>`, then bulleted list `- [Title](path.md) — one-line description`. Agents read this before fetching leaves.
5. **No auth, no JS, no cookies** — `curl <url>` returns content. Tested via `curl -fsSL`.
6. **WHY-only comments inside files** — playbooks include rationale, not narration. A future agent (or human) must understand *why* a step exists, not just *what*.

## Adding a new skill

1. Pick a kebab-case directory name (e.g. `summarize-channel-history`).
2. Create `<skill>/llms.txt` with the skill index.
3. Create the playbooks + schemas inside.
4. Add a line to root `llms.txt` linking to the new skill.
5. Commit + push.

The bundled `SKILL.md` (in `toc-use-cases/use-case/_platform/skills/<skill>/`) is updated separately to point at these URLs.

## `clawexperts-code/` — snapshot, not fetch

`clawexperts-code/` is the knowledge core of ClawExperts Code, one sub-directory per CE Code skill. Unlike
Platform Skills, CE Code does not fetch these at runtime: its Bundle carries a byte-identical copy of
`clawexperts-code/<skill>/` at `skills/<skill>/references/` (and `huong-dan-su-dung.md` is its usage-guide
skill itself). CE Code's plugin refreshes that copy from here — 45 s after the gateway starts, every 6 hours,
and when the user says "cập nhật kỹ năng" — so a pushed edit reaches installed CE Code without re-packaging
(allow a few minutes for the raw CDN cache). It only refreshes `references/` of skills already installed,
skips a package written for a newer OpenClaw than the instance runs, and rejects a package with a playbook
missing its "viết cho OpenClaw" line or an index pointing at an odd file name. The bundled copy lives in
`toc-use-cases/use-case/ws-clawexperts-code/agent-clawexperts-code/skills/`; a test there fails while the two
copies differ — change both in the same sitting.

## License

Internal / use within OpenClaw ecosystem. Public for AI-fetch convenience, not for redistribution.
