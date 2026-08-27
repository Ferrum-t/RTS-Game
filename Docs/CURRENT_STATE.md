# CURRENT STATE

**Single source of truth:** [`Docs/nomad_wars_v1_scope_and_architecture.md`](nomad_wars_v1_scope_and_architecture.md)

**Branch:** `nomads-wars-grok`  
**Engine:** Godot 4.7  
**Version pointer:** see §0 of the scope doc (do not duplicate status here).

## Snapshot (2026-08-28)

| Item | State |
|------|--------|
| Phase 7 AI waves + match loop | ACCEPTED |
| Polish (hysteresis + RVO) | ACCEPTED |
| Phase 8.0–8.2 Watchtower / MobileTower / DeploymentConfig | ACCEPTED |
| Stuck detection (STUCK stays MOBILE) | ACCEPTED |
| Billboard pack/unpack bar | ACCEPTED |
| **Formation-offsets** (multi-MOBILE RMB grid) | **WAITING F5** |

## Active work

**Formation-offsets** — critical death-spiral fix (log 27).  
Code lives in `InteractionManager._try_move_mobile_buildings` (local grid; `Formation.gd` untouched).  
F5 checklist: §0 of the scope doc.

## Next after F5 accept

1. Environment Zones  
2. Pre-public polish (hide debug keys P/M/U/C/R; readable enemy building names)

## Doc map

| File | Role |
|------|------|
| `nomad_wars_v1_scope_and_architecture.md` | **Only** living scope / status / phase order |
| `TODO.md` | Short operational checklist |
| `GROK_WORKLOG.md` | Session history |
| `MOBILE_SETTLEMENTS.md` | Design philosophy |
| `DESIGN_DEPLOYMENT_EFFICIENCY.md` | Mechanical contract |
| `NOMAD_WORLD_BACKLOG.md` | Future, not current architecture |
| `00_WORLD_FOUNDATION.md` | World philosophy |
| `PROJECT_RULES.md` | Coding / AI rules |

Deleted as obsolete: `ARCHITECTURE.md`, `PROJECT_ROADMAP.md`, `PHASE_8_*`, `SESSION.md`.
