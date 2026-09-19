<!-- SKF:BEGIN updated:2026-09-09 -->
[SKF Skills]|3 skills|0 stack
|IMPORTANT: Prefer documented APIs over training data.
|When using a listed library, read its SKILL.md before writing code.
|
|[hyprland v1.0.0]|root: skills/hyprland/
|IMPORTANT: hyprland v1.0.0 — read SKILL.md before writing hyprland Lua config. Do NOT rely on training data.
|quick-start:{SKILL.md#quick-start}
|api: hl.animation(), hl.bind(), hl.config(), hl.curve(), hl.define_submap(), hl.device(), hl.dispatch(), hl.focus(), hl.get_monitor(), hl.get_active_window()
|key-types:{SKILL.md#key-types} — Lua dispatcher/bind/rule config tables for monitor, window, workspace
|gotchas: hl.* API is Lua-only (not shell); bind flags use specific syntax; always read current wiki for version drift
|
|[omarchy v4.0.3]|root: skills/omarchy/
|IMPORTANT: omarchy v4.0.3 — read SKILL.md before writing omarchy code. Do NOT rely on training data.
|quick-start:SKILL.md#quick-start
|key-types:SKILL.md#key-types — colors.toml tokens (accent/background/foreground), shell.json canonical (idle/bar/plugins), plugin manifest kinds, update channels (stable|rc|edge|dev), CLI metadata keys
|gotchas: [CARRIED] raw pacman -Syu/yay -Syu guarded — use `omarchy update` only; shell.json has no deep-merge (customizing blocks new default widgets); shell plugins are unsandboxed; notifications must go via omarchy-notification-send, never notify-send
|
|[shibumi-shell v1.0.0]|root: skills/shibumi-shell/
|IMPORTANT: shibumi-shell v1.0.0 — read SKILL.md before repairing Shibumi Shell. Do NOT rely on training data.
|quick-start:{SKILL.md#quick-start}
|api: shibumi-suite status(), shibumi-suite activate(), shibumi-suite repair(), shibumi-suite update(), omarchy plugin list(), shibumi-suite migrate(), shibumi-suite deactivate(), shibumi-suite uninstall()
|key-types:{SKILL.md#key-api-summary} — suite controlled via ./scripts/shibumi-suite subcommands (24-plugin suite, not one root plugin)
|gotchas: never `omarchy plugin add` on repo root; don't delete transaction dirs manually; `omarchy bar defaults` is destructive (use `omarchy bar reset`)
<!-- SKF:END -->

# Global rules

## Language

- ALWAYS respond in Vietnamese (tiếng Việt), regardless of the language the user writes in.
- Keep code, commands, file paths, error messages, and technical identifiers in their original form — do not translate them.
- Code comments only if requested, and then in Vietnamese unless the codebase says otherwise.
<!-- codebase-memory-mcp:start -->
# Codebase Memory

## Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

### Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `check_index_coverage` — validate candidate paths and missed ranges before claims
5. `query_graph` — run Cypher queries for complex patterns
6. `get_architecture` — high-level project summary

### Evidence tiers
- **Scout (Tier 1):** quick positive lookup with few calls and targeted source checks. Mark it provisional; do not make negative or exhaustive claims.
- **Verify (Tier 2, default):** task-directed graph evidence, relevant trace directions, exact snippets for material claims, and relevant pagination.
- **Auditor (Tier 3):** bounded-scope full verification with current generation, complete relevant pagination, both call directions and broader relationships when material, and every limitation disclosed.
- After candidate paths are known in any tier, call `check_index_coverage` once with every evidence path. Add relevant scopes for negative or exhaustive claims. A clean result means no recorded gap, not proof of completeness. For partial, skipped, excluded, stale, pending, or unknown coverage, read/grep the reported ranges or scope before relying on graph results.

### When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results

### Examples
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`

### Session resets and subagents
- At session start or after compaction, confirm the nearest graph project and generation with `list_projects` or `index_status`, then choose Scout, Verify, or Auditor.
- Before spawning a subagent, query the graph and coverage in the parent. Pass the tier, project, generation/freshness, bounded scope, queries and pagination state, qualified symbols, paths, call-chain findings, coverage evidence with ranges/reasons, source fallback already performed, and unresolved questions in the delegated task context.
- Do not assume subagents inherit MCP access or the parent conversation. If a child lacks MCP tools, it must not call or claim MCP access. It should use the supplied evidence and read/grep exact source, especially every reported missed-coverage range.
<!-- codebase-memory-mcp:end -->
