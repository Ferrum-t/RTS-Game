# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok`

**Scope:** `Docs/nomad_wars_v1_scope_and_architecture.md`  
**Status:** `Docs/CURRENT_STATE.md`  
**Tech debt:** `Docs/TECH_DEBT.md`

---

## 2026-09-19 — Doc sync + M17.0 scope lock

### Problem

Status docs still said Stage 1.5 climate was next (Slice A only / 8×r21 «not in code»).  
Git already had:

- Climate geometry port 8×r21 + Seasonal Front v0 (mid-September)
- Player **M10–M16** (construction, CommandBar, repair, deposit constructed, IDLE acquire, WT UI)

AI still single-TC Stage-1 cell → product gap vs player multi-base.

### Doc action

Synced `CURRENT_STATE`, `TODO`, scope §0, `ROADMAP`. Climate **parked**. Active = **M17.0 Variant C** (minimal 2nd TC).

### M17.0 lock (not coded yet)

Instant 2nd AI TC at resource threshold; `max_ai_tc=2`; train workers from any alive team TC; no AI pack/repair/construction-site; EnemyAI unchanged.

---

## 2026-08-31 — Stage 1 F5 + full GPT audit documented

Rally, attack-once, dual-floor harvest. TD-01…TD-04 recorded. Stage 1 practically confirmed.

---

## 2026-08-28 — Formation-offsets ACCEPTED + docs cleanup

Formation-offsets ACCEPTED. Deleted parallel roadmaps / PHASE_8_* archives.

---

*Older: Phase 7–8.2, polish — see git history.*
