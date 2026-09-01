# Stage 1.5 — Gameplay Design

**Status:** Design in progress — **no implementation task yet**  
**Depends on:** Stage 1 **ACCEPTED** (`CURRENT_STATE.md`)  
**Process:** `ACCEPTANCE_AND_PROCESS.md` (design before code; §3 — do not invent AI systems without proven need)

**Not this document:** Economy 1.5 implementation, T2 content, zone→harvest **code**, AI migration code.

---

## Why Stage 1.5 exists

Stage 1 delivers a complete T1 fight:

```
ENVIRONMENT → RESOURCES → WORKERS → ECONOMY → MILITARY → ATTACK → RAID → VICTORY/DEFEAT
```

After ~5–10 minutes the risk is a **flat loop**:

```
gather → Barracks → army → attack TC → win/lose → (same again next match)
```

Stage 1.5 answers:

> **Why should the player keep playing after the basic T1 economy has stabilized?**

For **Nomad Wars** the intended identity is not “RTS with nomad skins”, but:

```
map changes → resources change → society must move → army is part of a mobile system
```

---

## Causal chain to design (fill in before any feature code)

For every proposed mid-game beat, answer:

```
What changed on the map / economy?
      ↓
Why is the player forced to react?
      ↓
What choices exist? (develop / migrate / defend / raid / all-in)
      ↓
What is the risk of each choice?
      ↓
What is the payoff?
      ↓
How does that create conflict with the opponent?
```

Do **not** start from “add migration” or “add T2” in isolation. Start from the chain above.

---

## Open design questions

### Environment & resources

#### Q1 — Player-facing role of moving ecological zones (beyond visual)?

**Status:** **DESIGN DECISION** (direction closed; balance numbers not specified)

**Short rule:** Player controls a **working region**, not a green blob.

**Decision hierarchy:**

```
ZONE
  → changes the value of a region (soft efficiency on existing nodes)

WORKERS
  → short-term: may follow temporary advantage

SETTLEMENT
  → long-term: moves only under structural, lasting disadvantage
```

**Player-facing rule:**

> Land on the map is sometimes better or worse for the **same** Wood / Stone / Horses. A good strip lasts long enough to plan and contest, but is not so strong that the only strategy is chasing the favorable band every tick. The player may endure at home, retarget workers, contest the strip with the army, or (expensively, optionally) relocate the settlement. The opponent wants the same working region.

**Zone role (refined):**

- Soft **spatial economy modifiers** on existing resource nodes (efficiency / value), not pure VFX, not hard base-kill timer, not mandatory migration.
- Magnitude must be **meaningful** (affects army/build **tempo**) but **not dominant** (off-band harvest remains viable; ignore is suboptimal, not suicide).
- Value attaches to a **working region**: resource cluster + path to settlement + defendability + opponent interest + **time window** — not the center of a moving sprite.
- Anti-chase principles: spatial **persistence** (minutes-scale windows), size ≈ cluster, movement slower than a free harvest cycle, large neutral baseline map, logistics tax on long trips, exposed workers so army presence matters.

**Worker relocation** = short-term response (labor moves to land).  
**Settlement migration** = optional long-term response (anchor moves when structural tax of deposit + train + defense exceeds migrate cost). Migration is **not** required by zone motion alone.

**Architectural gameplay constraint (preserve later):**  
If remote harvesting ever becomes so convenient that **distance stops mattering**, migration loses independent value and Nomad identity weakens. Do not silently remove structural tax on far eco (path time, deposit at settlement, production/rally at settlement, undefended workers).

**Opponent interaction:** Recurring contest over the same valuable region (raid workers / defend eco / contest strip / still may push TC) — **not** a separate capture-point mode.

**Causal chain (Q1):**

```
map change (slow bands over clusters)
↓
economic consequence (meaningful efficiency → tempo)
↓
player decision (endure / relocate workers / contest / optional migrate)
↓
risk (tempo loss / exposed workers / army away from TC / migrate downtime)
↓
payoff (better trips, deny enemy tempo, durable region, optional better anchor)
↓
opponent conflict (same region → eco-war without replacing TC victory)
```

**Still open under Environment & resources (not decided here):**

- When do resources become **scarce or wrong-typed** near the home base?
- Is depletion a soft timer toward migration, or a hard local collapse?

**Not required by Q1 alone:** Economy 1.5, T2, AI migration, new resources, new win conditions, hard collapse, capture-point scoring, zone→harvest **implementation** (design direction only; Stage B code later when tasked).

---

#### Q2 — (open) When do resources become scarce or wrong-typed near the home base?

#### Q3 — (open) Is depletion a soft timer toward migration, or a hard local collapse?

### Mobility & settlement

- Why can’t the player just sit on one TC forever?
- What does “migrate” mean in one sentence for the player?
- How do pack/unpack buildings participate in that pressure (already exist in Stage 1)?

### Conflict beyond “kill TC”

- Reasons to attack that are **not** only enemy Town Center?
- Contested space, herds, favorable zones, raid loot, denying a migration path?
- Mid-game decision matrix: develop vs migrate vs defend vs raid vs commit army?

### Progression

- Where does **T2** appear as a *response* to Stage 1.5 pressure (not as a content dump)?
- New win/lose conditions later — only after the loop needs them (see TD-03 coupling).

### AI (only if design requires it)

- Does Stage 1.5 need the AI to understand goal → cost → deficit → workers?
- If **yes** → then open **Economy 1.5 design** with a written requirement from this doc.
- If **no** → keep dual-floor Stage 1 AI; do not complicate the decision layer.

---

## Out of scope until design answers exist

| Topic | Rule |
|--------|------|
| Economy 1.5 code | Frozen unless a later question forces it |
| T2 buildings/units | Frozen |
| Zone harvest multipliers **code** | Allowed only after explicit implementation task; Q1 gives **direction** only |
| AI migration | After migration is a proven player-facing necessity |
| New unit roster | After conflict reasons are clear |

---

## Working note

Stage 1 foundation is solid enough to **design** mid-game without rewriting the economic AI. Prefer one coherent loop story over parallel feature spikes.

Q1 direction locked 2026-09-01 (two-pass design). Next: **Q2** (scarce / wrong-typed resources near home base).

*Created 2026-09-01 after Stage 1 formal sign-off.*
