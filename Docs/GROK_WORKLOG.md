# GROK WORKLOG — Nomad Wars

**Official title (EN):** Nomad Wars · technical `NomadWars`  
Ветка: `nomads-wars-grok` *(legacy slug; do not use “Nomads Wars” as product title)*

**Scope:** `Docs/nomad_wars_v1_scope_and_architecture.md`  
**Status:** `Docs/CURRENT_STATE.md`  
**Identity:** `Docs/GAME_DESIGN.md`  
**Tech debt:** `Docs/TECH_DEBT.md`

---

## 2026-09-25 — M20.2 Fog Visual ACCEPTED (B2)

**LOCK:** B2 · soft edges: no · death-ghost: SKIP

**IN shipped:**
- World `FogOverlay` plane + `Shaders/fog_overlay.gdshader`
- Minimap fog cell overlay (UNEXPLORED / EXPLORED / VISIBLE)
- `VisibilityMap` fog `ImageTexture` + `visibility_updated`
- Enemy 3D `visible` gated by VISIBLE (units + buildings)

**F5 PASS:** vision disk, explored trail, enemy hide 3D + minimap, no script errors.

**Intentional v0 look:** pixelated world fog from cell_size=4 + nearest + no soft edges.  
**Do not** fold color/filter/soft-edge polish into M20.2 — track as future polish only.

Also: ConstructionManager freed `_pending_builder` type-check crash fix (SKIP formal death-ghost F5).

---

## 2026-09-25 — M20 / M20.1

- M20 Basic Minimap (static bg, markers, camera rect, click-pan) CLOSED
- M20.1 VisibilityMap data + hide enemy minimap markers ACCEPTED (functional)

---

## 2026-09-21 — Official title lock

Fixed product naming in GAME_DESIGN / CURRENT_STATE / AI_CONTEXT.  
**Nomad Wars** = EN official. **Not** Nomads Wars. Branch name left as-is (legacy).

---

## 2026-09-19 — Doc sync + M17.0→M17.2

M17.0 / M17.1 / M17.2 Level 1 ACCEPTED (F5). Climate parked.

---

*Older entries — see git history.*
