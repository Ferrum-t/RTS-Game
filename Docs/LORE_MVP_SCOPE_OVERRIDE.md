# LORE MVP SCOPE OVERRIDE (binding)

> **This note overrides ANY document under `Docs/`** if it lists something as
> MVP-required that `nomad_wars_v1_scope_and_architecture.md` §1 / §2 places
> outside v1.0 or in backlog after v1.0.
>
> **Gameplay scope authority:** `nomad_wars_v1_scope_and_architecture.md` **only**.
> World lore files remain canon for fiction; they do not expand implementation scope.

---

## Currently known conflicts

| Document | Section | Conflict |
|----------|---------|----------|
| `05_FACTIONS.md` | §37 (or equivalent MVP proof list) | Hero listed as MVP-required |
| `09_MILITARY_PHILOSOPHY.md` | §32 MVP MILITARY PHILOSOPHY | `HERO` in MVP proof list |

If a future lore doc adds heroes, multi-faction play, full magic, flying armies, etc. into an "MVP must prove" list — this override applies without a new per-file patch.

---

## MVP proof list (Turan) — v1.0 implementation

What code **may** treat as in-scope for v1.0 (see also scope §1):

* mobile Town Center
* mobile settlement (DEPLOYED / PACKING / MOBILE / UNPACKING)
* migration / caravan move (Raise Entire Settlement + selection-aware control)
* changing environmental zones (**v1.0:** blobs + harvest multiplier — **DONE**)
* resource redistribution via zones (harvest mult only in v1.0)
* horse capture / horses as resource
* basic nomadic economy (Wood, Stone, Horses; gold as present in code)
* basic military (Worker, Soldier, Cavalry, Siege) — **no hero unit**
* raiding / plunder foundation (damage→loot siphon)
* basic mobile defensive structure (Watchtower)
* selection-aware pack / move / unpack (per-building **or** entire caravan)

---

## Explicitly NOT v1.0

* **Hero system** (XP, abilities, auras, inventory, hero unit on map) — backlog after v1.0  
  Even if any lore file lists HERO in an MVP proof list.
* Other three playable factions
* Raise Settlement (TC only) as a *separate named command* — backlog  
  (code today = dual-mode: selected mobile buildings **or** all team-0 MOBILE)
* Zones v1.1 seasonal / frontal pressure — candidate after balance pass
* Flying units, advanced magic combat, full livestock-capture loop, multiplayer, campaign

---

## How to use this file

1. When a lore doc and the scope doc disagree on **what to implement now** → follow **scope**.
2. Do **not** start hero (or other backlog) work because a worldbuilding § "MVP list" mentions it.
3. Prefer updating this single override when a new conflict appears; avoid one-off `05_*_OVERRIDE` files per document.

---

## Note

`05_FACTIONS_MVP_OVERRIDE.md` is retained as a **pointer** to this file for old links.
