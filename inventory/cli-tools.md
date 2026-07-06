# Global CLI Tools

Tools installed outside Homebrew. Install after the Homebrew phase (node, go, and uv come from the formula inventory).

## npm (global)

```sh
npm install -g @aartiq/servicenow-mcp @earendil-works/pi-coding-agent http-server
```

`@earendil-works/pi-coding-agent` is the pi agent itself; its config restores from the pi repo (see `docs/ai-agents.md`).

## uv tools

```sh
uv tool install -p 3.13 serena-agent
```

Also covered by the pi repo's restore steps (Serena MCP); listed here so the audit sees it.

## go

```sh
go install golang.org/x/tools/gopls@latest
```

## rustup

Rust toolchain via rustup (not the Homebrew formula), which owns `~/.cargo/bin`:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```
