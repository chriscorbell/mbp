# Agent Skills

Skills installed with [skills.sh](https://skills.sh) (`npx skills`). They live in `~/.agents/skills/` and are symlinked into `~/.claude/skills/` and `~/.codex/skills/` by the installer. The lockfile is `~/.agents/.skill-lock.json` (not tracked here).

Restore: for each source repo below, run `npx skills add <source>` and select the listed skills for all agents. Verify with `npx skills list` or by checking the symlinks in `~/.claude/skills/`.

The `supacode-cli` skill is not on this list: Supacode installs it itself into `~/.claude/skills/` and `~/.codex/skills/`.

## Leonxlnx/taste-skill

- design-taste-frontend
- full-output-enforcement
- image-to-code
- industrial-brutalist-ui
- minimalist-ui
- redesign-existing-projects

## anthropics/skills

- frontend-design

## github/awesome-copilot

- create-readme

## mattpocock/skills

- caveman
- diagnose
- grill-me
- grill-with-docs
- handoff
- improve-codebase-architecture
- prototype
- review
- setup-matt-pocock-skills
- tdd
- to-issues
- to-prd
- triage
- write-a-skill
- zoom-out
