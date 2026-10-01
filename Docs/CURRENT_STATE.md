# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-10-01

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M24 Fog Visual Polish** |
| **Now** | idle — next candidate Horse Archer |
| **Next** | Horse Archer (ranged + horses cost) |

### M24 closed (summary)

- World fog: near-black UNEXPLORED, dark EXPLORED, soft GPU edges
- SunLight + lower ambient (form readable for future hand-paint)
- Perf: minimap fog = one texture; VisibilityMap buffer write; 0.5s interval
- VisibilityMap / cell_size / B2 — unchanged
- F5: no hang to VICTORY with large armies

---

## Done chain (recent)

```
M20–M20.2 Minimap + FoW data/visual ✓
M21.x Food / Yurt / AI Yurt         ✓
M22   AI Eco                        ✓
M23   Mergen                        ✓
M23.1 Projectile combat             ✓
M24   Fog visual polish             ✓ ACCEPTED
```

**Parked:** TD-DEPLOY-01 · TD-FIRE-MOVE-01 · TD-FOG soft polish (optional later)
