# GROK WORKLOG — Nomad Wars

Ветка: `nomads-wars-grok`

**Scope:** только `Docs/nomad_wars_v1_scope_and_architecture.md`

---

## 2026-08-28 — Formation-offsets ACCEPTED + billboard fix

### F5 formation-offsets (user log)

- `slot 0/2` / `slot 1/2` `spacing=6.3` — разные dest
- оба ARRIVED; Watchtower → DEPLOYED; TC → DEPLOYED
- ноль `footprint overlaps`
- `Watchtower cannot unpack` после уже DEPLOYED — ожидаемо (повторный U)

**ACCEPTED.** Death spiral log 27 закрыт.

### Billboard

Progress bar использовал только yaw `look_at` → с высокого угла «3D-палочка».  
Исправлено как HealthBar3D: `global_transform.basis = cam.global_transform.basis`.

### Collision MOBILE

Юниты проходят сквозь MOBILE-здания: nav footprint снят + unit physics не блокирует building. Не блокер; tech debt.

### Next

Environment Zones.

---

## 2026-08-28 earlier — Docs cleanup (Claude audit)

Deleted ARCHITECTURE, PROJECT_ROADMAP, PHASE_8_*, SESSION. Pointers synced.

---

*Older: Phase 7–8.2, polish — see git history.*
