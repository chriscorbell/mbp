# Agent Skills

Skills installed with [skills.sh](https://skills.sh) (`npx skills`). They live in `~/.agents/skills/` and are symlinked into `~/.claude/skills/` and `~/.codex/skills/` by the installer. The lockfile is `~/.agents/.skill-lock.json` (not tracked here).

Restore: for each source repo below, run `npx skills add <source>` and select the listed skills for all agents. Verify with `npx skills list` or by checking the symlinks in `~/.claude/skills/`.

The `supacode-cli` skill is not on this list: Supacode installs it itself into `~/.claude/skills/` and `~/.codex/skills/`.

## Leonxlnx/taste-skill

- brandkit
- design-taste-frontend
- full-output-enforcement
- gpt-taste
- high-end-visual-design
- image-to-code
- imagegen-frontend-mobile
- imagegen-frontend-web
- industrial-brutalist-ui
- minimalist-ui
- redesign-existing-projects
- stitch-design-taste

## anthropics/skills

- frontend-design

## github/awesome-copilot

- create-readme

## mattpocock/skills

- caveman
- design-an-interface
- diagnose
- edit-article
- git-guardrails-claude-code
- grill-me
- grill-with-docs
- handoff
- improve-codebase-architecture
- migrate-to-shoehorn
- obsidian-vault
- prototype
- qa
- request-refactor-plan
- review
- scaffold-exercises
- setup-matt-pocock-skills
- setup-pre-commit
- tdd
- teach
- to-issues
- to-prd
- triage
- ubiquitous-language
- write-a-skill
- writing-beats
- writing-fragments
- writing-shape
- zoom-out
