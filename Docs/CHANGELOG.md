# CHANGELOG

## 2026-10-01 — M24 Fog Visual Polish ACCEPTED

- World fog: linear sample + smoothstep, pure/near-black UNEXPLORED, darker EXPLORED
- DirectionalLight3D (SunLight) + reduced ambient so geometry is not flat-lit
- Perf: minimap fog one cached RGBA texture (no per-cell draw_rect/frame)
- VisibilityMap: PackedByteArray fog write, update interval 0.5s, visible-only toggles
- VisibilityMap / cell_size / B2 hide unchanged
- Stable match to VICTORY without hitch spikes

## 2026-09-30 — M23.1 Projectile Combat ACCEPTED

- Damage on arrival for Mergen / Watchtower (arrow) and Siege (stone)
- Speeds: arrow 32, stone 20 · fly_time clamp 0.12–0.50 · straight path
- Freed attacker mid-flight: no crash (`is_instance_valid` source)
- Melee unchanged · cooldown at fire
- **Polish same day:** camera start on player TC, dolly zoom, edge-scroll UI skip, unit face-on-move, repair `request_repair_tick` restore

## 2026-09-30 — M23 Mergen ACCEPTED

- Foot archer: train from Barracks (60W+1F, queue max 5 with Soldier/Cav/Siege)
- Stats: HP 70, dmg 14, range 11, cd 1.1, speed 2.5, DamageType.RANGED
- CommandBar Mergen button; no AI train Mergen

## Recent (condensed)

- M22 AI Eco · M21.4 AI Yurt · M21.1–M21.3 Food/Yurt/queue
- M20–M20.2 Minimap + FoW · MAP-R R2–R7 resources
