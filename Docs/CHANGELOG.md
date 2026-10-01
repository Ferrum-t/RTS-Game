# CHANGELOG

## 2026-10-01 — M25 Horse Archer (F5 pending)

- New unit Horse Archer (mounted ranged): 80W+2F+1H, ~6s train
- Stats: HP 90, dmg 13, range 10, speed 4.2, cd 1.0, DamageType.RANGED
- Barracks shared queue max 5; cancel refunds W+F+H
- CommandBar button; no AI train; stop-to-shoot

## 2026-10-01 — M24 Fog Visual Polish ACCEPTED

- World fog: linear sample + smoothstep, pure/near-black UNEXPLORED, darker EXPLORED
- DirectionalLight3D (SunLight) + reduced ambient
- Perf: minimap fog one texture; VisibilityMap buffer write; 0.5s interval
- Stable match to VICTORY without hitch spikes

## 2026-09-30 — M23.1 Projectile Combat ACCEPTED

- Damage on arrival for Mergen / Watchtower (arrow) and Siege (stone)
- Speeds: arrow 32, stone 20 · fly_time clamp 0.12–0.50 · straight path
- Freed attacker mid-flight: no crash
- Melee unchanged · cooldown at fire

## 2026-09-30 — M23 Mergen ACCEPTED

- Foot archer from Barracks (60W+1F, queue max 5)
- HP 70, dmg 14, range 11, cd 1.1, speed 2.5

## Recent (condensed)

- M22 AI Eco · M21.4 AI Yurt · M21.1–M21.3 Food/Yurt/queue
- M20–M20.2 Minimap + FoW · MAP-R R2–R7 resources
