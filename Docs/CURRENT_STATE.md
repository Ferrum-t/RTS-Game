# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-28

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M21.4 AI Food + Yurt** |
| **Now** | — open next LOCK |
| **F5** | M21.4 PASS (AI Yurt + harvest regression fixed) |

### M21.4 accepted scope (do not expand)

- AI builds Yurt when Food < 6 and can_afford (max 2)
- Priority: after 1st Barracks, before expand / 2nd Barracks / Watchtower
- `place_building_for_team(..., constructed=true)` + existing Yurt +1 Food / 8s
- Player Yurt / income / train path unchanged
- Harvest pick restored (`BaseResource.resource_amount`) after M21.4 regression fix

---

## Done chain (recent)

```
M19.1 Training Queue          ✓
M19.2 Remote train Worker/Soldier ✓
M19.3 Quick Select TC/Barracks + left layout ✓
M20   Basic Minimap           ✓
M20.1 VisibilityMap + minimap enemy filter ✓
M20.2 Fog visual + B2 hide 3D ✓
MAP-R Resources R2–R7         ✓
M21.1 Food Display            ✓
M21.2 Yurt Food Income        ✓
M21.3 Barracks full queue (Cav/Siege) ✓
M21.4 AI Food + Yurt          ✓ ACCEPTED
```

**Parked ideas:** TD-FOG-01 · TD-DEPLOY-01 (optional auto-unpack toggle, default OFF)
