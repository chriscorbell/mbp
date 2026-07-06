# AI Agents And Plugins

Coding-agent setup beyond the base app installs. Skills are inventoried separately in `inventory/agent-skills.md`.

## pi + Ollama Local Agent

The pi coding agent (`@earendil-works/pi-coding-agent`) runs against a locally tuned Ollama model. The entire setup — pi settings, system prompt, extensions, MCP servers, the Ollama Modelfile, and the launchd agent that persists Ollama env tuning — lives in its own repo with its own restore instructions:

- Repo: <https://github.com/chriscorbell/pi-coding-agent-config> (also checked out at `~/pi-coding-agent-config`)
- Live install: `~/.pi/`
- LaunchAgent: `~/Library/LaunchAgents/local.ollama-env.plist` (installed from that repo)

Restore: install Ollama (see `docs/manual-setup.md`), clone that repo, and follow its README. It requires `ollama pull qwen3.6:35b-a3b` plus an `ollama create` from the tracked Modelfile, and re-auth of cloud providers inside pi.

## Claude Code Plugins

Two marketplaces and two plugins, user scope:

```sh
claude plugin marketplace add DietrichGebert/ponytail
claude plugin install ponytail@ponytail
claude plugin install swift-lsp@claude-plugins-official
```

The `anthropics/claude-plugins-official` marketplace is available by default; add it explicitly only if `swift-lsp` install fails to resolve.

## Codex

Notable non-default settings in `~/.codex/config.toml` (the file itself is private — auth, project trust list — so it is not tracked here):

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
model = "gpt-5.5"
model_reasoning_effort = "xhigh"
```

Enabled Codex plugins are the OpenAI bundled/curated set (github, documents, spreadsheets, presentations, computer-use, browser, chrome, pdf, template-creator) — enabled through Codex itself, nothing third-party to restore.

`~/.codex/hooks.json` is Supacode-managed (session status hooks). Do not copy it by hand; Supacode recreates it.

## Supacode

Supacode installs its own `supacode-cli` skill into `~/.claude/skills/` and `~/.codex/skills/` and manages the Codex hooks above. Just install and sign into Supacode.
