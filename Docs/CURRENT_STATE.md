# CURRENT STATE

**Product:** **Nomad Wars** (EN official) · technical `NomadWars`  
**Branch:** `nomads-wars-grok`  
**HEAD fact date:** 2026-09-30

---

## Active sprint

| Field | Value |
|--------|--------|
| **Last accepted** | **M23.1 Projectile Combat** |
| **Now** | — open next LOCK |
| **F5** | M23.1 PASS (projectiles visible, damage on arrival, melee unchanged, victory) |

### M23.1 accepted scope (do not expand)

- Real projectile combat (not VFX-only): damage **on arrival**
- Mergen + Watchtower: arrow (speed 32, thin cylinder)
- Siege: stone (speed 20, sphere); Siege `attack_range` ~9
- `fly_time = clamp(dist/speed, 0.12, 0.50)` · straight path
- Target dead mid-flight → no damage · attacker freed mid-flight → safe null source
- Melee Soldier/Cavalry: instant (unchanged)
- Cooldown starts at fire

**Also landed (same day polish, not a milestone):**
- Camera start focus on player TC · dolly zoom on Z · edge-scroll ignores UI
- Units face move direction (−Z forward)
- M12 repair path restored (`request_repair_tick`)

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
M21.4 AI Food + Yurt          ✓
M22   AI Eco balance          ✓
M23   Mergen foot archer      ✓
M23.1 Projectile combat       ✓ ACCEPTED
```

**Parked ideas:** TD-FOG-01 · TD-DEPLOY-01 · TD-FIRE-MOVE-01 (ranged shoot while moving; mobile tower fire stays OFF)
