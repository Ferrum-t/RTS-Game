# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-25

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M20.2 Fog Visual (B2)** |
| **Now** | — open next LOCK |
| **F5** | M20.2 PASS (pixelated world fog = intentional v0) |

### M20.2 accepted scope (do not expand)

- `VisibilityMap` single source of truth
- cell_size = 4 · soft edges = no · nearest filtering
- Minimap fog overlay + world FogOverlay plane
- B2: hide enemy units/buildings outside VISIBLE
- No visual polish inside M20.2 (color/filter/soft-edge → future polish task)

---

## Done chain (recent)

```
M19.1 Training Queue          ✓
M19.2 Remote train Worker/Soldier ✓
M19.3 Quick Select TC/Barracks + left layout ✓
M20   Basic Minimap           ✓
M20.1 VisibilityMap + minimap enemy filter ✓
M20.2 Fog visual + B2 hide 3D ✓ ACCEPTED
```

Construction pending-builder freed fix: shipped; death-ghost targeted F5 = SKIP.
