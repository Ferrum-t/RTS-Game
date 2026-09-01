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

**Not required by Q1 alone:** Economy 1.5, T2, AI migration, new resources, new win conditions, hard collapse, capture-point scoring, zone→harvest **implementation** (design direction only; Stage B code later when tasked).

---

#### Q2 — When do resources become scarce or wrong-typed near the home base?

**Status:** **DESIGN DECISION** (2026-09-01)

**Consistency with Q1 / Q3:** OK — zone stays flow; depletion stays stock and is not a migration clock; distance tax preserved; migration optional; economic scarcity is not Economy 1.5.

**Scarcity model:**

| Type | Meaning |
|------|--------|
| **Physical depletion** | Node/cluster amount → 0 (local end of stock) |
| **Spatial scarcity** | Useful stock still exists on the map, but the next cluster is far |
| **Wrong-typed geography** | Nearby stock is abundant but poorly matched to the current plan (e.g. stone-rich home, wood-hungry army) |
| **Economic scarcity** | Felt tempo gap: income vs current production demand — **observed result**, not a separate deficit/goals subsystem |

**Home region:** initially strong working region / starting reserve — **not** an infinite safe income bubble and **not** a timed eviction.

**Primary mid-game pressure:** the **cheap** working region next to the settlement becomes insufficient (empty, far next cluster, and/or wrong mix). Player must decide **where and what** to extract next — not press a forced Migration command.

**Orthogonal factors (do not collapse into one meter):**

```
DEPLETION  = stock
ZONE       = flow efficiency     (Q1)
DISTANCE   = logistics cost      (Q1 constraint — remote harvest always pays tax)
OPPONENT   = territorial pressure
SETTLEMENT = production / deposit / defense anchor
```

No zone-driven amount wipe. Zones do not become depletion.

**After local pressure / depletion — multiple valid answers:**

```
endure → switch local type → remote harvest → contest → optional migration
```

- Full local physical depletion is **allowed** and **survivable** (not economic game-over).
- Remote harvesting remains a real trade-off because of **distance tax**.
- **Migration** only when **persistent structural mismatch**: remote-as-normal and cumulative logistics / defense / production tax exceed relocation cost. Never automatic on empty home. Never hard depletion timer. Never forced migration.

**Wrong-typed geography (Nomad-specific):** a still-healthy home of the *wrong* mix can push spatial decisions as strongly as an empty home of the *right* mix.

**Resource types:** same depletion rules for Wood / Stone / Horses; different strategic weight (wood often drives T1 army tempo; stone buildings; horses spatial prize without gating all T1). **No new resources (including Gold) for Q2.**

**Canonical causal chain (Q2):**

```
resource state
(empty nearby / far next cluster / wrong mix / slow effective income)
↓
player economic situation
(tempo vs current plan)
↓
strategic mismatch
(region no longer supports the plan efficiently)
↓
available choices
(endure / switch / remote / contest / optional migrate)
↓
risk
(tempo / exposure / army split / migration downtime)
↓
payoff
(restore tempo / secure resource type / deny enemy / better long-term anchor)
↓
territorial conflict and/or optional migration pressure
```

**Final design rule (Q2):**

> Resources can become locally scarce or geographically wrong for the player's current plan. This changes the value of the working region, but never commands migration. Local depletion is survivable; spatial distance, resource mismatch, ecological efficiency, and opponent pressure determine whether another region becomes worth pursuing. Migration remains an optional response to persistent structural mismatch, not to depletion alone.

**Not required by Q2:** Economy 1.5, AI migration, T2, hard depletion timer, forced migration, zone-driven amount depletion, Gold/new resources, new victory conditions, capture points.

---

#### Q3 — Is depletion a soft timer toward migration, or a hard local collapse?

**Status:** **DESIGN DECISION** (2026-09-01)

**Core constraint:** **Depletion ≠ migration clock.**

| Model | Verdict |
|--------|--------|
| Hard local collapse (`home empty → must migrate`) | **Rejected** — survival timer, low agency, snowball, scripted nomad |
| Soft-timer-toward-migration framing | **Rejected as framing** — still timer-shaped if migrate is the expected end of depletion |
| **Depletion as pressure on working-region value** | **Accepted** |

**What depletion is:** one input that lowers extract value of a region (stock left). It does **not** command “Migrate.”

**What depletion is not:** a soft or hard survival timer; a direct parent of migration; global eco collapse when a local cluster hits 0.

**Orthogonal axes (keep separate):**

```
DEPLETION  = stock left on nodes/cluster
ZONE       = flow efficiency now          (Q1)
DISTANCE   = logistics tax                (Q1 constraint)
SETTLEMENT = production / deposit / defense anchor
OPPONENT   = contest pressure
```

**Stock × flow (player-readable states):**

| Stock | Flow | Meaning |
|-------|------|--------|
| High | Favorable | Strong working region; prime contest |
| High | Poor | Reserve exists; currently inefficient |
| Low | Favorable | Efficient but short-lived opportunity |
| Low | Poor | Weak region; seek alternatives |

**Full local depletion is allowed and survivable.** Intended ladder (not a single forced step):

```
local stock gone
→ remote harvest (pay distance tax)
→ and/or switch resource / plan
→ and/or contest another region
→ only if remote-as-normal + structural tax persists
→ migration becomes attractive
→ migration remains optional
```

**Canonical causal chain (Q3):**

```
depletion
→ spatial / strategic mismatch
→ logistics tax
→ sustained inefficiency (with zone, wrong-type, opponent as co-inputs)
→ migration becomes attractive
→ migration remains optional
```

**Qualitative pressure ladder (no numbers):**

```
SAFE → LOCAL PRESSURE → REMOTE HARVEST → STRUCTURAL MISMATCH → MIGRATION ATTRACTIVE (still not mandatory)
```

**Recovery:** Match-scale permanent empty nodes are acceptable; no **required** regeneration system. Old home can remain a production anchor with remote extract; “return” only if residual/other value remains.

**Anti-snowball (design constraints):** depletion is local not global; zone magnitude stays meaningful not dominant (Q1); multiple answers always exist; pressure must be readable (not a hidden timer).

**Opponent:** Soft depletion feeds a contest graph (fight / longer remote / switch plan / migrate elsewhere), not `empty → self-migrate`.

**Not required by Q3:** Economy 1.5, AI migration, T2, regeneration system, new resources, new victory conditions, mandatory migration, hard local collapse, hidden survival timer.

**Final design rule:**

> Resources can run out locally. Running out never commands “Migrate.” It changes the value of a working region; together with zone, distance, mismatch, and opponent it can make migration attractive. Migration remains a choice. A player can lose from bad economic geography decisions without any invisible survival timer firing.

---

### Mobility & settlement

#### Q4 — Why not sit forever / what is migrate / role of pack-unpack?

**Status:** **DESIGN DECISION** (2026-09-01)

**Consistency Q1 ↔ Q2 ↔ Q3 ↔ Q4:** OK — zone never alone forces migrate; scarcity enables remote without forcing pack; depletion ≠ pack now; distance tax preserved on the full anchor loop; multiple agency paths; migration can be wrong; attractiveness is structural cost vs new-anchor value, **not** “after N minutes of remote harvest.”

**Mobility hierarchy:**

```
Worker relocation
    ↓
Remote harvesting
    ↓
Temporary forward presence
    ↓
Settlement migration
```

| Level | Role |
|-------|------|
| **Worker relocation** | Short-term / local mismatch (zone window, wrong type, thin nearby) |
| **Remote harvesting** | Sustained spatial scarcity while **keeping** the old settlement anchor |
| **Temporary forward presence** | Contest / protect a strip — **not** a new settlement |
| **Settlement migration** | Long-term reposition of deposit + production + defense + rally **anchor** |

**Core distinction:**

> Worker relocation solves a **temporary/local** mismatch. Settlement migration solves a **persistent structural** mismatch of the **whole** settlement anchor.

**Settlement anchor (Stage 1 structure — preserve):**

```
resources → workers → deposit at TC → production / rally → army + defense
```

Remote extract must **not** become free because workers can walk far. Distance tax is the repeated cost on travel, deposit, production/rally lag, and undefended remote workers.

**Player-facing definition of migration:**

> Move the settlement anchor closer to a region you believe will sustain your economy and army for the long term, paying downtime and risk.

Pack/unpack (existing Stage 1 mobile buildings) is the **means** to change anchor, not the meaning of the decision.

**Why not migrate immediately:** current settlement still supports the plan; remote region may be temporary; migration downtime can lose military timing; destination may be contested; existing defensive/rally footprint has value; worker relocation may already suffice; player may intentionally pursue a military/TC strategy instead.

**Why migrate eventually (no time-threshold substitute):** migration becomes attractive only when **persistent** remote harvesting plus repeated distance tax plus deposit/production/defense/rally friction, against a **durable** alternative region, outweigh the continued cost of the old anchor. Compare structural tax to migrate cost and expected value of the new anchor — **not** “remote for N minutes ⇒ must pack.”

**Migration can be wrong:** too early (window ends, stranded); too late (tempo already bled); wrong destination; move into contested ground; wrong prediction of the future working region. If migration cannot fail as a bet, it is not strategic.

**Opponent interaction (no capture points):**

```
A starts migration
↓
B can raid / contest / intercept / attack old or soft targets
↓
A can continue / abort / redirect / defend / choose another region
```

**Can the player win without migration?** **Yes.** Migration is **one strategic branch among several**, not a hidden requirement for victory.

**Canonical causal chain (Q4):**

```
resource geography changes
(stock / type / zone flow / access)
↓
working region moves or becomes structurally distant
↓
worker relocation / remote harvest initially solves it
↓
persistent distance + deposit + production + defense tax accumulate
↓
player evaluates alternative long-term anchor
↓
migration becomes attractive
↓
migration creates downtime + vulnerability + positional risk
↓
destination must remain valuable long enough
↓
opponent can contest / punish
↓
successful migration creates a better long-term settlement anchor
```

**Final design rule (Q4):**

> Settlement migration is an optional long-term repositioning of the economic and military anchor. It is not triggered by depletion or zones alone. It becomes attractive when persistent geographic mismatch makes remote extraction and the resulting deposit, production, rally, and defense costs worse than establishing a new anchor. Migration is a prediction and a strategic bet: it costs time and safety, can be wrong, and is never mandatory for victory.

**Not required by Q4:** Economy 1.5, deficit AI, AI migration, T2, new migration currency, forced migration, hard collapse, capture points, new victory conditions, new resource types, Stage 1 changes beyond preserving existing distance / deposit / production / rally / pack-unpack behavior.

---

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
| Resource regeneration system | Not required by Q3 |
| Hard local collapse / migration timer | **Rejected** (Q3) |
| Forced migration / migration time-threshold | **Rejected** (Q4) |

---

## Working note

Stage 1 foundation is solid enough to **design** mid-game without rewriting the economic AI. Prefer one coherent loop story over parallel feature spikes.

| Question | Status |
|----------|--------|
| Q1 Zones | **DESIGN ACCEPTED** |
| Q2 Scarcity / wrong-typed | **DESIGN ACCEPTED** |
| Q3 Depletion | **DESIGN ACCEPTED** |
| Q4 Mobility & settlement | **DESIGN ACCEPTED** |

Q1–Q4 form one system: flow × stock × logistics × optional anchor move. Next open block: **Conflict beyond kill TC**.

*Created 2026-09-01 after Stage 1 formal sign-off. Q1–Q4 recorded 2026-09-01.*
