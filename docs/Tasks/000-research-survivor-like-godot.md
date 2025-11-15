# 000-research-survivor-like-godot.md

## Goal
Capture external best practices for a Vampire Survivors–style 2D PC/Steam game in Godot 4 and align Project-YnS / Nightfall Survivor’s architecture with them.

This is a **research + documentation** task. No core gameplay code changes required.

## Tasks

### 1. Document current gameplay loop
Create `docs/loop.md`:

- Describe *your* current loop in short bullets:
  - Player input → hero movement.
  - Automatic weapon firing / cooldown.
  - Enemy spawning & pathing.
  - XP gain, leveling, upgrades.
  - Game over / restart.
- Add a small diagram (ASCII or a quick image link) that shows:
  - `Input → Actor → WeaponSystem → Ammo → Enemy → XP → LevelUps`

### 2. External references checklist
In `docs/loop.md` (or a sibling `docs/research_notes.md`), add a section:

- List a few YouTube / article references you want to emulate (you will watch them, no need to store links if you don’t want):
  - One “Vampire Survivors clone in Godot 4” series.
  - One data-driven Godot architecture talk (autoloads, resources).
  - One video focused on performance in Godot (object pooling, signals, avoiding per-frame allocations).

For each reference, add 3–5 key takeaways, e.g.:

- Use **autoload singletons** for systems: `WeaponSystem`, `EnemyPool`, `Config`, `Logger`.
- Keep enemies and weapons **data-driven** with resources / JSON.
- Prefer **composition** (Actor + AI + Weapon) over huge inheritance chains.

### 3. Feature parity checklist
Create `docs/feature_checklist.md` with a simple checklist:

- [ ] Auto-attack & configurable weapon cooldowns
- [ ] Multiple concurrent weapons
- [ ] Enemy waves with difficulty scaling
- [ ] Empowered / elite / boss enemies
- [ ] XP, levels, upgrade choices
- [ ] High entity performance (1k+ enemies/projectiles)
- [ ] Autoplay / simulation runner
- [ ] Config-driven parameters for balancing

Mark each item as:

- ✅ Implemented
- 🟡 Partially implemented
- ❌ Missing

### 4. Architecture alignment notes
Create `docs/architecture_notes.md`:

- Briefly describe your current architecture:
  - Autoloads (what you have now).
  - Main scene composition (root → level → player, enemies, UI).
  - Where configs currently live.
- For each system (player, enemy, weapon, config, logging):
  - Note if it is **data-driven** or **hard-coded**.
  - Note if it uses **OOP** (inheritance/composition) in a way that will scale with new archetypes (empowered, bosses, etc.).

This will guide later PRs.

## Tests

No automated tests required here.

Light validation suggestions:

- Run your current simulation/autoplay runner and write short observations into `docs/loop.md` about:
  - How the pacing *feels*.
  - Any obvious performance drops when enemy/projectile count is high.

## Tiny equation note

A simple wave difficulty curve you might adopt later:

> `enemy_count(wave_index) = base_count * (1 + growth_rate) ^ wave_index`

where:

- `base_count` is the number of enemies in wave 0.
- `growth_rate` could be 0.1–0.25 for gentle exponential growth.
