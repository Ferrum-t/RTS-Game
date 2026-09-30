# CHANGELOG

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

## 2026-09-30 — Horse visual on climate suspend

- HorseHerd `visible=false` while climate-suspended; resume restores mesh

## Recent (condensed)

- M22 AI Eco · M21.4 AI Yurt · M21.1–M21.3 Food/Yurt/queue
- M20–M20.2 Minimap + FoW · MAP-R R2–R7 resources
