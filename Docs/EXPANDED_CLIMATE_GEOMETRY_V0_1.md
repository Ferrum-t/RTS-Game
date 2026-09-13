# Expanded Climate Geometry v0.1

> **Status:** DESIGN SIGNED-OFF (2026-09-13)  
> **Scope:** map geography for future climate presentation — **not yet in runtime code**.  
> **Does not replace** Slice A technical prototype (`EnvironmentZoneService`: 4 regions × radius 14).

---

## Purpose

Record the first expanded layout that matches the original concept-map intent:

```text
several independent ecological regions
+
visible neutral land / corridors between them
```

This is **working expanded geometry**, not final production map content. Later Neutral Camps, Power Sites, extra resources, and aul infrastructure may require content changes *inside* regions without changing the geographic principle.

---

## Invariants (unchanged from Stage 1.5 climate contract)

- Fixed geometry (no motion / velocity / bounce).
- Region boundaries **do not overlap and do not touch**.
- Exactly three gameplay states: `COLD`, `FAVORABLE`, `DRY`.
- `FAVORABLE` is the most advantageous state.
- Season changes **state**, not geometry.
- Neutral land outside regions is **not** a fourth state (multiplier 1.0 when used).
- No overlap priority system.

---

## Signed-off layout — Variant B

| Region | Role | Center (X, Z) | Radius |
|--------|------|---------------|--------|
| **R0** | Player Home | (32, −30) | **21** |
| **R1** | Enemy Home | (−30, 30) | **21** |
| **R2** | East | (77, 0) | **21** |
| **R3** | North-East | (60, 72) | **21** |
| **R4** | North | (−7, 77) | **21** |
| **R5** | North-West | (−72, 60) | **21** |
| **R6** | West | (−77, −7) | **21** |
| **R7** | South | (0, −77) | **21** |

### Geometric checks (design review)

- **MIN_GAP ≈ 9.6** (tightest: R1–R5); target for visual climate separation ≥ ~10.
- All other neighbour gaps ≥ ~10; many corridors wider.
- Player TC `(28, −22)` and starter player resources lie inside **R0**.
- Enemy TC `(−28, 28)` and starter enemy resources lie inside **R1**.
- Existing TC / starter resource positions **not moved**.
- Region discs stay inside playable ≈ `[-100, 100]²` (outer edges near margin; acceptable for v0.1).
- Region area ≈ 28% of that square → majority remains neutral geography, not a full flood.

### Rejected alternative

**Variant A** (same 8 roles, denser centers, MIN_GAP ≈ 3.5) — **rejected**.  
Gaps of 3–6 units are too tight for future FAVORABLE / COLD / DRY world presentation (green / snow / dry grass would visually merge).

---

## Relation to Slice A (code)

| Item | Slice A (current code) | Expanded Geometry v0.1 (this doc) |
|------|------------------------|-----------------------------------|
| Region count | 4 | **8** |
| Radius | 14 | **21** |
| Status | F5-proven **backend prototype** | **Design signed-off only** |
| In `EnvironmentZoneService` | **yes** | **not yet** |

Slice A remains valid proof that fixed regions + season schedules + `get_multiplier_at` work.  
Porting v0.1 layout into code is a **separate, explicit implementation task** — not implied by this sign-off.

---

## Capacity intent (design only)

- **1 region ≈ 1 future aul package** for now (TC + military/economy buildings + later Power Site / Neutral Camp as content).
- “2 auls in one region” remains a **multiplayer reserve**, not current scope.
- Radius 21 is a **working range** so a full aul can fit; not a locked production constant forever.

---

## Explicitly out of scope of this sign-off

- Changing `EnvironmentZoneService.gd`
- Season duration tuning for shipping builds
- Terrain materials / snow / tree swaps (Slice B+)
- Horses / Neutral Camps / Hero / Artifacts / Power Site gameplay
- Moving TC or starter resources
- Economy 1.5 / AI migration / T2

---

## Next decisions (ordered)

1. Keep Slice A code as prototype until an explicit **layout port** task is requested.
2. When porting: swap region table to the Variant B table above; keep API `get_multiplier_at(Vector3)`.
3. Only after geometry is live in-engine: plan **Slice B** environment presentation (world-readable climate, not debug discs alone).

---

*Signed off 2026-09-13 after design review of Variant A vs B. Geometry may be revised later for content fit; the fixed non-overlapping multi-region principle stays.*
