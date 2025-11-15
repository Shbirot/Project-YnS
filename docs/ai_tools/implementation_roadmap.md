# Implementation Roadmap

## Overview

This document provides a **step-by-step plan** to implement both the object hierarchy refactor and AI performance infrastructure **incrementally and safely**, without breaking the existing game.

## Guiding Principles

1. **Incremental delivery**: Each phase delivers working, testable functionality
2. **Non-breaking changes**: Existing game continues to work throughout
3. **Measure everything**: Validate improvements with data
4. **Fail fast**: Test early, identify issues quickly
5. **Parallel tracks**: Object refactor and AI infrastructure can proceed independently

## Timeline Overview

```
Week 1-2:   Foundations (metrics, basic AI)
Week 3-4:   Object hierarchy prototype
Week 5-6:   Object pooling, benchmarking
Week 7-8:   Integration, optimization
Week 9-10:  Polishing, documentation
Week 11-12: Advanced features (optional)
```

---

## Phase 1: Metrics Infrastructure (Week 1-2)

**Goal**: Get baseline measurements before making any changes

### Week 1: Basic Metrics Collection

#### Tasks
- [ ] Create `MetricsCollector` autoload
  - Frame time tracking (delta, FPS)
  - Memory sampling (static, dynamic, peak)
  - Entity counting (enemies, projectiles, collectibles)
- [ ] Create `SessionRecorder` script
  - JSON output format
  - Git commit tagging
  - Session summary generation
- [ ] Add metrics recording to `GameController`
  - Start session on game start
  - End session on game over
  - Save JSON to `user://metrics/`

**Deliverable**: Game outputs `session_<uuid>.json` file on every playthrough

**Test**: Manually play 3 games, verify JSON files are created with correct data

---

### Week 2: Basic AI Agent

#### Tasks
- [ ] Create `AIAgent` script with heuristic behavior
  - Implement `BALANCED` strategy (baseline)
  - Movement: avoid enemies, collect pickups
  - Combat: aim at nearest enemy, fire when ready
- [ ] Add AI toggle to game (cmdline arg `--ai-agent`)
- [ ] Create Python script `benchmark_runner.py`
  - Launch Godot headless with AI agent
  - Run N sessions (default 10)
  - Collect all JSON files
  - Compute aggregate statistics
  - Print summary report

**Deliverable**: `python ai_tools/scripts/benchmark_runner.py --sessions 10` runs 10 AI games and prints summary

**Test**: Run 10 AI sessions, verify:
- AI survives at least 60 seconds on average
- FPS averages 55+ on dev machine
- Memory stays under 250MB

---

## Phase 2: Object Hierarchy Refactor (Week 3-4)

**Goal**: Create new `GameObject` base with property-based design

### Week 3: GameObject Prototype

#### Tasks
- [ ] Create `GameObject` base class
  - Enum properties: `PhysicsMode`, `CollisionMode`, `MovementMode`, `InteractionType`, `RenderTier`
  - Lazy-created components: sprite, collision_shape, interaction_area
  - Poolable interface: `reset()`, `activate()`, `deactivate()`
  - Lifecycle hooks: `_on_spawn()`, `_on_despawn()`
- [ ] Create convenience subclasses
  - `PhysicsEntity` (physics + collision)
  - `StaticEntity` (no movement)
  - `EffectEntity` (short-lived visuals)
- [ ] Write unit tests for `GameObject`
  - Property setting/getting
  - Component creation
  - Lifecycle hooks

**Deliverable**: `GameObject.gd` base class with tests passing

**Test**: Create test scenes with various property combinations, verify correct behavior

---

### Week 4: Migrate One Leaf Class

#### Tasks
- [ ] Migrate `Enemy` to use new `PhysicsEntity` base
  - Update `enemy.gd` to extend `PhysicsEntity`
  - Set properties in `_init()` or `_ready()`
  - Test collision, movement, damage
- [ ] Update `MonsterFactory` to work with new base
  - Set properties from catalog JSON
  - No scene changes yet (gradual migration)
- [ ] Run full test suite
  - Ensure all existing tests pass
  - AI agent can still play

**Deliverable**: Enemy using new hierarchy, game still works

**Test**:
- Manual playtest (enemies behave correctly)
- AI agent benchmark (compare to week 2 baseline)
- All unit tests pass

---

## Phase 3: Object Pooling (Week 5-6)

**Goal**: Implement pooling for frequently created objects

### Week 5: Pooling Infrastructure

#### Tasks
- [ ] Create `ObjectPool` singleton
  - `get_or_create(scene_path)` method
  - `return_to_pool(instance)` method
  - Per-scene pools
  - Active object tracking
- [ ] Update `GameObject` with pooling support
  - `reset()` clears state
  - `activate()` re-enables
  - `deactivate()` hides and pauses
- [ ] Update `Enemy` to use pooling
  - Replace `queue_free()` with `ObjectPool.return_to_pool()`
  - Override `reset()` to clear HP, position, etc.

**Deliverable**: Enemies are pooled, zero GC pressure from enemy spawns

**Test**:
- Spawn 1000 enemies rapidly
- Check memory allocations (should be near zero)
- Verify no visual glitches

---

### Week 6: Expand Pooling

#### Tasks
- [ ] Pool projectiles
  - Migrate `ProjectileBase` to pooling
  - Update weapon firing to use pool
- [ ] Pool collectibles (coins)
- [ ] Pool damage numbers
- [ ] Benchmark pooled vs non-pooled
  - Run AI sessions with pooling ON
  - Run AI sessions with pooling OFF
  - Compare FPS, memory, frame time variance

**Deliverable**: All frequently created objects are pooled

**Test**: AI benchmark shows measurable improvement (target: +10% FPS, -50% memory allocations)

---

## Phase 4: Performance Analysis Tools (Week 7-8)

**Goal**: Build tools to analyze and compare metrics

### Week 7: Database & Analysis

#### Tasks
- [ ] Create SQLite schema (`metrics.db`)
  - `sessions` table
  - `performance_metrics` table
  - `gameplay_metrics` table
  - `events` table
- [ ] Create `db_ingestion.py` script
  - Read session JSON files
  - Insert into database
  - Handle duplicates gracefully
- [ ] Create `metrics_analyzer.py` script
  - Compare two commits
  - Statistical significance tests
  - Trend detection

**Deliverable**: Session data stored in database, queryable via SQL or Python

**Test**:
- Ingest 50 sessions from weeks 1-6
- Query: "Average FPS for commit abc123"
- Query: "Compare FPS between weeks 2 and 6"

---

### Week 8: Report Generation

#### Tasks
- [ ] Create `report_generator.py` script
  - HTML template with Plotly charts
  - FPS time series
  - Memory usage graph
  - Entity count vs FPS scatter plot
  - Gameplay metrics comparison
- [ ] Generate report for each benchmark run
  - Save to `ai_tools/reports/benchmark_<commit>.html`
  - Include pass/fail status based on thresholds
- [ ] Add regression checker
  - Compare to previous commit
  - Alert if FPS drops >5% or memory increases >20%

**Deliverable**: HTML reports with interactive charts

**Test**: Generate report for week 6 benchmark, verify charts are correct

---

## Phase 5: Integration & Optimization (Week 9-10)

**Goal**: CI/CD integration, polish, and advanced optimizations

### Week 9: CI/CD Integration

#### Tasks
- [ ] Create `.github/workflows/performance-check.yml`
  - Runs on every PR to main/dev
  - Executes 10 AI sessions
  - Compares to base branch
  - Posts comment on PR with results
- [ ] Add performance gates
  - PR fails if FPS drops >5%
  - PR fails if memory increases >25%
  - Warning if entity count increases significantly
- [ ] Test workflow
  - Create test PR with intentional performance regression
  - Verify workflow detects it and blocks merge

**Deliverable**: Automated performance checking on every PR

**Test**: Create PRs with good/bad performance changes, verify workflow behavior

---

### Week 10: Advanced Optimizations

#### Tasks
- [ ] Implement collision layer strategy
  - Define layer assignments (player, enemies, projectiles, etc.)
  - Update all entities to use correct layers/masks
  - Benchmark collision check reduction
- [ ] Implement spatial partitioning (optional)
  - `SpatialGrid` class for entity queries
  - Replace `get_tree().get_nodes_in_group()` calls
  - Benchmark query performance
- [ ] Implement render tier management (optional)
  - `RenderManager` that hides decorative objects when FPS drops
  - Test under heavy load

**Deliverable**: Additional performance improvements beyond pooling

**Test**: AI benchmark under extreme load (300+ entities), verify FPS stays >45

---

## Phase 6: Polish & Documentation (Week 11-12)

**Goal**: Production-ready system with full documentation

### Week 11: Multiple AI Strategies

#### Tasks
- [ ] Implement `AGGRESSIVE` AI strategy
  - Maximize DPS, risky positioning
- [ ] Implement `DEFENSIVE` AI strategy
  - Prioritize survival, kiting
- [ ] Implement `COLLECTOR` AI strategy
  - Prioritize pickups and coins
- [ ] Benchmark all strategies
  - Compare kills, survival time, coins collected
  - Identify which strategy stresses performance most

**Deliverable**: 4 AI strategies, each benchmarked

**Test**: Each strategy completes 10 sessions successfully

---

### Week 12: Documentation & Knowledge Transfer

#### Tasks
- [ ] Update all markdown docs with implementation details
- [ ] Create video walkthrough of system
- [ ] Write developer guide: "How to Add New Metrics"
- [ ] Write developer guide: "How to Add New AI Behavior"
- [ ] Create dashboard (optional): Web UI to browse historical metrics

**Deliverable**: Comprehensive documentation for future maintainers

**Test**: New developer can add a custom metric following the guide

---

## Success Criteria

By the end of the roadmap, the system should:

- ✅ Run 10 AI sessions in under 30 minutes
- ✅ Detect >90% of performance regressions
- ✅ Produce clear, actionable reports
- ✅ Store historical metrics for trend analysis
- ✅ Integrate with CI/CD (automated PR checks)
- ✅ Support at least 4 AI strategies
- ✅ Achieve >10% FPS improvement via pooling
- ✅ Reduce memory allocations by >50%
- ✅ Have full documentation and examples

---

## Risk Management

### Risk: AI doesn't play well enough
**Mitigation**: Start with simple heuristics, validate manually, iterate based on metrics

### Risk: Metrics collection overhead affects performance
**Mitigation**: Make collector lightweight, toggle-able, measure overhead explicitly

### Risk: Object refactor breaks existing game
**Mitigation**: Incremental migration, keep old classes working, extensive testing

### Risk: Long benchmark times slow down CI
**Mitigation**: Parallelize sessions, optimize session length, cache baseline results

### Risk: Database bloat from too many sessions
**Mitigation**: Retention policy (90 days), aggregate old data, compress JSON

---

## Optional Extensions (Beyond Week 12)

### Reinforcement Learning AI
- Integrate GodotRL Agents plugin
- Train PPO agent using Stable-Baselines3
- Compare RL agent to heuristic agent

### Multi-Platform Benchmarking
- Run benchmarks on Windows, Linux, Android
- Identify platform-specific performance issues

### Game Balance Analyzer
- Track weapon effectiveness (kills per weapon type)
- Track enemy difficulty (time to kill, damage dealt)
- Suggest balance tweaks based on data

### Procedural Content Testing
- Generate random levels
- AI tests each level
- Flag levels with performance issues or poor gameplay

---

## Checkpoints & Go/No-Go Decisions

### Checkpoint 1 (End of Week 2)
**Question**: Are baseline metrics reliable?
- AI completes sessions consistently?
- Metrics data looks correct?
- Benchmark runner works?

**Go/No-Go**: If AI fails >50% of sessions, improve AI before proceeding

---

### Checkpoint 2 (End of Week 4)
**Question**: Is new object hierarchy working?
- Enemy migration successful?
- Performance unchanged or better?
- Tests passing?

**Go/No-Go**: If migration causes regressions, revert and redesign

---

### Checkpoint 3 (End of Week 6)
**Question**: Is pooling worth it?
- FPS improvement >5%?
- Memory allocation reduction >30%?
- No visual bugs?

**Go/No-Go**: If pooling doesn't help, investigate why (maybe not the bottleneck)

---

### Checkpoint 4 (End of Week 10)
**Question**: Is the system production-ready?
- CI/CD working reliably?
- Reports are actionable?
- Team is using it?

**Go/No-Go**: If team isn't using it, identify friction points and address

---

## Development Workflow Integration

### Daily Development Loop (After Week 10)

```
1. Developer makes code changes
2. Commits to feature branch
3. Opens PR to dev
4. CI/CD runs 10 AI sessions automatically
5. Report posted to PR within 15 minutes
6. Developer reviews report:
   - ✅ FPS +2%, memory -5MB → Good!
   - ⚠️ FPS -1%, memory +50MB → Investigate
   - ❌ FPS -8%, memory +100MB → Fix before merge
7. Iterate if needed
8. Merge when performance is acceptable
```

### Weekly Review (After Week 12)

```
1. Review performance trends over past week
2. Identify any gradual regressions
3. Prioritize optimization work
4. Celebrate improvements!
```

---

## Final Deliverables Summary

By end of roadmap:

### Code Artifacts
- `GameObject` base class with property-based design
- `ObjectPool` singleton
- `MetricsCollector` autoload
- `SessionRecorder` script
- `AIAgent` with 4 strategies
- Migrated leaf classes (Enemy, Projectile, Collectible)

### Infrastructure
- SQLite database schema
- Python analysis scripts (`benchmark_runner.py`, `metrics_analyzer.py`, `report_generator.py`)
- CI/CD workflow (GitHub Actions)
- HTML report templates

### Documentation
- Architecture refactor plan (this doc + diagrams)
- AI infrastructure design
- Metrics schema
- Implementation roadmap
- Developer guides

### Data
- Baseline metrics (week 1-2)
- Performance improvements over time
- Historical trend database

---

**Author**: Claude + Yves
**Date**: 2025-11-08
**Status**: Ready for execution
**Estimated Effort**: 12 weeks (1 developer, part-time) or 6 weeks (full-time)
