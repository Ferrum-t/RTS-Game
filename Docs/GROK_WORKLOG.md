# GROK WORKLOG — Nomad Wars

**Official title (EN):** Nomad Wars · technical `NomadWars`  
Ветка: `nomads-wars-grok` *(legacy slug; do not use “Nomads Wars” as product title)*

**Scope:** `Docs/nomad_wars_v1_scope_and_architecture.md`  
**Status:** `Docs/CURRENT_STATE.md`  
**Identity:** `Docs/GAME_DESIGN.md`  
**Tech debt:** `Docs/TECH_DEBT.md`

---

## 2026-09-30 — M23.1 Projectile Combat ACCEPTED

**LOCK:** damage on arrival · arrow 32 · stone 20 · fly clamp 0.12–0.50 · straight · no miss/arc

**IN shipped:**
- `Scripts/Combat/Projectile.gd` + fire from CombatComponent / BuildingCombat / siege path
- Freed-source safe pass to `take_damage`
- Siege attack_range ~9 for visible stones

**Also same day:**
- Camera: start on player TC, dolly zoom (Z), edge-scroll skips UI
- Units face velocity (−Z)
- Repair: `request_repair_tick` path restored
- Idea logged: TD-FIRE-MOVE-01 (ranged on-move; mobile tower fire stays OFF)

**F5 PASS:** visible arrows/stones, on-arrival damage, melee OK, victory, 0 script errors after source fix.

---

## 2026-09-30 — M23 Mergen ACCEPTED

Foot archer Barracks train · shared queue · RANGED stats · no AI Mergen train.

---

## 2026-09-28 — M21.4 AI Food + Yurt ACCEPTED

**LOCK:** Food < 6 · max_yurts 2 · after 1st Barracks · constructed=true placement

**IN shipped:**
- `EconomicAIController` Yurt build + food stock in `[AI_ECO]` print
- `_team_yurt_count` / `_try_build_yurt` / `YurtData.tres`
- Harvest regression fix: original `_pick_resource_for_worker` (`resource_amount`)

**F5 PASS:** AI harvest/deposit, Yurt when Food low, income, train resumes, 0 script errors.

**Also same day:** Manual Unpack default restored; TD-DEPLOY-01 idea logged (auto-unpack toggle later).

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

- Product name: **Nomad Wars** (EN)
