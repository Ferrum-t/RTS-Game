# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-30

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M23.1 Projectile Combat** |
| **Now** | **M24 Fog Visual Polish** — shipped, **F5 pending** |
| **Next** | Horse Archer (after M24 ACCEPTED) |

### M24 scope (visual only)

- World shader: `filter_linear` + `smoothstep`, near-black fog
- `unexplored_alpha ≈ 0.96`, `explored_alpha ≈ 0.60`
- Minimap fog darker (UNEXPLORED 0.94 / EXPLORED 0.58)
- VisibilityMap / cell_size / B2 — unchanged

---

## Done chain (recent)

```
M20–M20.2 Minimap + FoW data/visual ✓
M21.x Food / Yurt / AI Yurt         ✓
M22   AI Eco                        ✓
M23   Mergen                        ✓
M23.1 Projectile combat             ✓ ACCEPTED
M24   Fog visual polish             shipped / F5
```

**Parked:** TD-DEPLOY-01 · TD-FIRE-MOVE-01
