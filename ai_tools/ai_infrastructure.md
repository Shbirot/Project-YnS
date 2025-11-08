# AI Training & Performance Testing Infrastructure

## Vision

Build an **AI-driven automated testing system** that plays Nightfall Survivor like a pro, collects performance metrics, and provides data-driven insights for optimization decisions. Every code change will be benchmarked automatically, with metrics tracked across versions and visualized as graphs.

## Core Objectives

1. **Automated Gameplay**: AI agent plays the game autonomously for consistent, reproducible testing
2. **Performance Benchmarking**: Measure FPS, memory, entity counts, physics time, render time
3. **Regression Detection**: Automatically detect performance drops between versions
4. **Historical Tracking**: Store metrics with git commits for long-term trend analysis
5. **Decision Support**: Visual dashboards show impact of changes

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Nightfall Survivor                       │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │ AI Agent   │→ │ Game Session │→ │ Metrics Collector│    │
│  │ (Player)   │  │   (Main.gd)  │  │  (Autoload)      │    │
│  └────────────┘  └──────────────┘  └──────────────────┘    │
│         ↓               ↓                     ↓              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │            Session Recorder (JSON output)              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              Performance Analysis Pipeline                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Metrics DB   │→ │  Analyzer    │→ │  Report Gen      │  │
│  │  (SQLite)    │  │  (Python)    │  │  (HTML/MD)       │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Version Comparison                         │
│  • FPS trends over time                                     │
│  • Memory usage growth                                      │
│  • Entity count scaling                                     │
│  • Physics/render time breakdown                            │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. AI Agent (GDScript)

**Purpose**: Autonomous game-playing bot that simulates skilled player behavior

**Location**: `game/scripts/ai/ai_agent.gd`

**Responsibilities**:
- Pathfinding and movement decisions
- Target prioritization (enemies, pickups)
- Weapon usage and aiming
- Survival strategies (kiting, positioning)

**Behavior Modes**:
- **Heuristic Mode**: Rule-based AI (initial implementation)
- **Learning Mode**: Reinforcement learning (future)
- **Replay Mode**: Replays recorded sessions

**Heuristic Strategies**:
```gdscript
class_name AIAgent

enum Strategy {
    AGGRESSIVE,   # Max DPS, risky positioning
    BALANCED,     # Mix of offense/defense
    DEFENSIVE,    # Survival-focused, kiting
    COLLECTOR,    # Prioritize pickups/coins
}

var strategy: Strategy = Strategy.BALANCED

func _physics_process(delta):
    # Decision pipeline
    var threats = _evaluate_threats()
    var opportunities = _evaluate_opportunities()
    var decision = _make_decision(threats, opportunities)
    _execute_decision(decision)

func _evaluate_threats() -> Array:
    # Find nearby enemies, projectiles, damage zones
    # Calculate danger score based on distance, damage, HP
    pass

func _evaluate_opportunities() -> Array:
    # Find pickups, powerups, safe zones
    # Calculate value score
    pass

func _make_decision(threats, opportunities) -> Dictionary:
    match strategy:
        Strategy.AGGRESSIVE:
            return _aggressive_decision(threats, opportunities)
        Strategy.BALANCED:
            return _balanced_decision(threats, opportunities)
        Strategy.DEFENSIVE:
            return _defensive_decision(threats, opportunities)
        Strategy.COLLECTOR:
            return _collector_decision(threats, opportunities)

func _execute_decision(decision: Dictionary) -> void:
    # Set movement input
    # Trigger weapon fire
    # Activate abilities
    pass
```

#### 2. Metrics Collector (GDScript Autoload)

**Purpose**: Real-time performance monitoring during gameplay

**Location**: `game/autoload/metrics_collector.gd`

**Collected Metrics**:

| Category | Metrics | Sampling Rate |
|----------|---------|---------------|
| **Frame Time** | avg, min, max, p95, p99, stddev | Every frame |
| **Memory** | static, dynamic, texture, total, peak | Every 1s |
| **Entity Counts** | enemies, projectiles, collectibles, effects | Every frame |
| **Physics** | collision checks, body count, island count | Every physics frame |
| **Rendering** | draw calls, triangles, shader switches | Every frame |
| **Gameplay** | kills, damage dealt, damage taken, coins | On event |

**Implementation**:
```gdscript
extends Node
class_name MetricsCollector

signal metrics_updated(frame_data: Dictionary)
signal session_completed(summary: Dictionary)

var _frame_times: Array[float] = []
var _memory_samples: Array[Dictionary] = []
var _entity_snapshots: Array[Dictionary] = []
var _gameplay_events: Array[Dictionary] = []

var _session_start_time: float = 0.0
var _session_duration: float = 0.0
var _enabled: bool = false

func start_session() -> void:
    _enabled = true
    _session_start_time = Time.get_ticks_msec() / 1000.0
    _frame_times.clear()
    _memory_samples.clear()
    _entity_snapshots.clear()
    _gameplay_events.clear()

func end_session() -> Dictionary:
    _enabled = false
    _session_duration = (Time.get_ticks_msec() / 1000.0) - _session_start_time
    return _generate_summary()

func _process(delta: float) -> void:
    if not _enabled:
        return

    # Frame time tracking
    _frame_times.append(delta)

    # Entity counting
    var entities = {
        "enemies": get_tree().get_nodes_in_group("enemies").size(),
        "projectiles": get_tree().get_nodes_in_group("projectiles").size(),
        "collectibles": get_tree().get_nodes_in_group("collectibles").size(),
        "effects": get_tree().get_nodes_in_group("effects").size(),
    }
    _entity_snapshots.append(entities)

    # Emit real-time data
    var frame_data = {
        "delta": delta,
        "fps": Engine.get_frames_per_second(),
        "entities": entities,
    }
    metrics_updated.emit(frame_data)

func _sample_memory() -> Dictionary:
    return {
        "static": Performance.get_monitor(Performance.MEMORY_STATIC),
        "dynamic": Performance.get_monitor(Performance.MEMORY_DYNAMIC),
        "static_max": Performance.get_monitor(Performance.MEMORY_STATIC_MAX),
        "timestamp": Time.get_ticks_msec() / 1000.0 - _session_start_time,
    }

func record_gameplay_event(event_type: String, data: Dictionary) -> void:
    _gameplay_events.append({
        "type": event_type,
        "data": data,
        "timestamp": Time.get_ticks_msec() / 1000.0 - _session_start_time,
    })

func _generate_summary() -> Dictionary:
    # Calculate statistics
    var fps_values = _frame_times.map(func(dt): return 1.0 / dt if dt > 0 else 0.0)

    return {
        "session": {
            "duration": _session_duration,
            "frames": _frame_times.size(),
        },
        "fps": {
            "avg": _calc_avg(fps_values),
            "min": _calc_min(fps_values),
            "max": _calc_max(fps_values),
            "p95": _calc_percentile(fps_values, 0.95),
            "p99": _calc_percentile(fps_values, 0.99),
            "stddev": _calc_stddev(fps_values),
        },
        "memory": {
            "avg_dynamic": _calc_avg(_memory_samples.map(func(m): return m.dynamic)),
            "peak_dynamic": _calc_max(_memory_samples.map(func(m): return m.dynamic)),
            "avg_static": _calc_avg(_memory_samples.map(func(m): return m.static)),
        },
        "entities": {
            "avg_enemies": _calc_avg(_entity_snapshots.map(func(e): return e.enemies)),
            "max_enemies": _calc_max(_entity_snapshots.map(func(e): return e.enemies)),
            "avg_projectiles": _calc_avg(_entity_snapshots.map(func(e): return e.projectiles)),
            "max_projectiles": _calc_max(_entity_snapshots.map(func(e): return e.projectiles)),
        },
        "gameplay": _summarize_gameplay_events(),
    }
```

#### 3. Session Recorder (GDScript)

**Purpose**: Record gameplay sessions for replay and analysis

**Location**: `game/scripts/ai/session_recorder.gd`

**Output Format**: JSON file per session

```json
{
  "session_id": "uuid-v4",
  "git_commit": "abc123def",
  "godot_version": "4.2.2",
  "timestamp": "2025-11-08T10:30:00Z",
  "config": {
    "ai_strategy": "BALANCED",
    "environment": "dev",
    "seed": 42
  },
  "metrics": {
    "fps": { "avg": 58.5, "min": 45.2, "max": 60.0, "p95": 59.8, "p99": 60.0 },
    "memory": { "avg_dynamic": 125000000, "peak_dynamic": 180000000 },
    "entities": { "avg_enemies": 45, "max_enemies": 82, "avg_projectiles": 120 },
    "gameplay": {
      "duration": 300.0,
      "kills": 450,
      "damage_dealt": 18500,
      "damage_taken": 850,
      "coins_collected": 320,
      "deaths": 0
    }
  },
  "events": [
    { "type": "spawn_wave", "timestamp": 5.2, "data": { "wave": 1, "enemy_count": 10 } },
    { "type": "player_death", "timestamp": 120.5, "data": { "killer": "enemy_bat" } },
    { "type": "level_up", "timestamp": 45.0, "data": { "level": 2 } }
  ]
}
```

#### 4. Benchmark Runner (Python Script)

**Purpose**: Orchestrate multiple AI playthroughs and collect results

**Location**: `ai_tools/scripts/benchmark_runner.py`

**Workflow**:
```
1. Check git status (must be clean or committed)
2. Get current commit hash and branch
3. Launch Godot headless with AI agent
4. Run N sessions (default 10)
5. Collect all session JSON files
6. Compute aggregate statistics
7. Store in metrics database
8. Generate comparison report
```

**Usage**:
```bash
# Run 10 AI sessions in dev environment
python ai_tools/scripts/benchmark_runner.py --sessions 10 --env dev

# Run with specific AI strategy
python ai_tools/scripts/benchmark_runner.py --sessions 20 --strategy AGGRESSIVE

# Compare against previous version
python ai_tools/scripts/benchmark_runner.py --sessions 10 --compare HEAD~1
```

**Output**:
```
========================================
Benchmark Results
========================================
Commit: abc123def (main)
Date: 2025-11-08 10:30:00
Sessions: 10
Strategy: BALANCED

Performance Metrics:
  FPS:        58.5 ± 2.1 (min: 45.2, p95: 59.8)
  Memory:     125 MB ± 15 MB (peak: 180 MB)
  Entities:   45 ± 12 enemies, 120 ± 30 projectiles

Gameplay Metrics:
  Avg Survival: 300.0s
  Avg Kills:    450
  Avg Coins:    320

Comparison to abc122aaa (1 commit ago):
  FPS:        +2.3% ✅
  Memory:     +8.5% ⚠️
  Avg Kills:  +5.0% ✅

Full report: ./ai_tools/reports/benchmark_abc123def.html
```

#### 5. Metrics Database (SQLite)

**Purpose**: Store historical metrics for trend analysis

**Location**: `ai_tools/metrics.db`

**Schema**:
```sql
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    git_commit TEXT NOT NULL,
    git_branch TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    godot_version TEXT,
    environment TEXT,
    ai_strategy TEXT,
    config JSON
);

CREATE TABLE performance_metrics (
    session_id TEXT REFERENCES sessions(id),
    metric_name TEXT NOT NULL,
    value REAL NOT NULL,
    unit TEXT,
    PRIMARY KEY (session_id, metric_name)
);

CREATE TABLE gameplay_metrics (
    session_id TEXT REFERENCES sessions(id),
    duration REAL,
    kills INTEGER,
    damage_dealt INTEGER,
    damage_taken INTEGER,
    coins_collected INTEGER,
    deaths INTEGER
);

CREATE TABLE events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT REFERENCES sessions(id),
    timestamp REAL,
    event_type TEXT,
    data JSON
);

CREATE INDEX idx_commit ON sessions(git_commit);
CREATE INDEX idx_timestamp ON sessions(timestamp);
CREATE INDEX idx_metric ON performance_metrics(metric_name);
```

#### 6. Performance Analyzer (Python)

**Purpose**: Analyze metrics and detect regressions

**Location**: `ai_tools/scripts/metrics_analyzer.py`

**Features**:
- Statistical comparison (t-tests, confidence intervals)
- Trend detection (linear regression, moving averages)
- Anomaly detection (outlier identification)
- Regression alerts (automatic warnings)

**Example Analysis**:
```python
# Compare two commits
analyzer = MetricsAnalyzer(db_path="ai_tools/metrics.db")
comparison = analyzer.compare_commits(
    commit_a="abc123def",
    commit_b="abc122aaa",
    metrics=["fps_avg", "memory_peak", "kills_avg"]
)

for metric, result in comparison.items():
    print(f"{metric}:")
    print(f"  A: {result['mean_a']:.2f} ± {result['stddev_a']:.2f}")
    print(f"  B: {result['mean_b']:.2f} ± {result['stddev_b']:.2f}")
    print(f"  Change: {result['percent_change']:+.1f}%")
    print(f"  Significant: {result['statistically_significant']}")
```

#### 7. Report Generator (Python + HTML)

**Purpose**: Create visual performance reports

**Location**: `ai_tools/scripts/report_generator.py`

**Output**: HTML report with interactive charts

**Sections**:
1. **Executive Summary**: Key metrics, pass/fail status
2. **FPS Analysis**: Time series, histogram, percentiles
3. **Memory Profile**: Usage over time, peak tracking
4. **Entity Scaling**: Entity counts vs FPS correlation
5. **Gameplay Comparison**: Kills, survival time, efficiency
6. **Event Timeline**: Notable events during session
7. **Historical Trends**: Multi-version comparison graphs

**Technologies**:
- Plotly.js for interactive charts
- Pandas for data processing
- Jinja2 for HTML templating

## AI Training Approach

### Phase 1: Heuristic AI (Immediate)

Rule-based bot using spatial awareness and threat assessment:

**Movement Strategy**:
```
1. Calculate danger zones (enemies, projectiles)
2. Find safe positions (distance from threats)
3. Balance safety vs opportunity (pickups, positioning)
4. Move toward optimal position
```

**Combat Strategy**:
```
1. Find enemies in weapon range
2. Prioritize by threat (distance, HP, damage)
3. Aim at highest priority target
4. Fire when cooldown ready
```

**Pros**: Works immediately, deterministic, debuggable
**Cons**: Not adaptive, requires manual tuning

### Phase 2: Behavior Trees (Medium-term)

More sophisticated decision-making using behavior trees:

```
Root: Selector
├── Sequence: Handle Critical Threat
│   ├── Condition: HP < 30%
│   └── Action: Kite away from enemies
├── Sequence: Collect Valuable Pickup
│   ├── Condition: Powerup nearby
│   └── Action: Move to pickup
├── Sequence: Engage Enemies
│   ├── Condition: Enemies in range
│   └── Action: Attack and kite
└── Action: Explore
```

**Pros**: Modular, reusable, easier to extend
**Cons**: Still manually designed

### Phase 3: Reinforcement Learning (Future)

Train neural network using RL:

**State Space**:
- Player position, HP, weapon cooldown
- Nearest N enemies (position, HP, distance)
- Nearest M pickups (type, position, distance)
- Danger heatmap (discretized grid)

**Action Space**:
- Movement direction (8-way or continuous)
- Fire weapon (yes/no)
- Use ability (if applicable)

**Reward Function**:
```
reward =
    + 1.0 * kills
    + 0.1 * damage_dealt
    + 0.05 * coins_collected
    - 0.5 * damage_taken
    + 10.0 * survival_time
    - 100.0 * death
```

**Training Infrastructure**:
- GodotRL Agents plugin (https://github.com/edbeeching/godot_rl_agents)
- Stable-Baselines3 (PPO algorithm)
- Parallel environment instances (10-20 simultaneous games)
- Training duration: 1M-10M steps

**Pros**: Can discover novel strategies, adapts to balance changes
**Cons**: Training time, requires GPU, less explainable

## Integration with CI/CD

### Automated Benchmarking on Every PR

```yaml
# .github/workflows/performance-check.yml
name: Performance Benchmark

on:
  pull_request:
    branches: [main, dev]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 2  # Need previous commit for comparison

      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install dependencies
        run: pip install -r ai_tools/requirements.txt

      - name: Run benchmark
        run: |
          python ai_tools/scripts/benchmark_runner.py \
            --sessions 10 \
            --env stage \
            --compare HEAD~1 \
            --output ./benchmark_report.json

      - name: Check for regressions
        run: |
          python ai_tools/scripts/regression_checker.py \
            --report ./benchmark_report.json \
            --threshold-fps -5.0 \
            --threshold-memory +20.0

      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: performance-report
          path: ./ai_tools/reports/

      - name: Comment on PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('./benchmark_report.json'));
            const comment = `
            ## Performance Benchmark Results

            | Metric | Current | Previous | Change |
            |--------|---------|----------|--------|
            | FPS (avg) | ${report.fps.avg} | ${report.baseline.fps.avg} | ${report.fps.change}% |
            | Memory (peak) | ${report.memory.peak}MB | ${report.baseline.memory.peak}MB | ${report.memory.change}% |
            | Entity count | ${report.entities.avg} | ${report.baseline.entities.avg} | ${report.entities.change}% |

            ${report.regression_detected ? '⚠️ **Performance regression detected!**' : '✅ No regressions detected'}

            [Full report](./ai_tools/reports/latest.html)
            `;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

## Deliverables

### Immediate (Week 1-2)
- [ ] `AIAgent` with heuristic behavior (aggressive, balanced, defensive)
- [ ] `MetricsCollector` autoload with real-time FPS/memory tracking
- [ ] `SessionRecorder` that outputs JSON files
- [ ] Basic Python script to run 10 sessions and aggregate results

### Short-term (Week 3-4)
- [ ] SQLite database schema and ingestion pipeline
- [ ] `benchmark_runner.py` with comparison to previous commit
- [ ] HTML report generator with basic charts
- [ ] CI/CD integration for automated benchmarks

### Medium-term (Month 2-3)
- [ ] Behavior tree AI for more sophisticated play
- [ ] Spatial partitioning performance optimizations
- [ ] Interactive dashboard for browsing historical metrics
- [ ] Regression detection with automatic alerts

### Long-term (Month 4+)
- [ ] Reinforcement learning training pipeline
- [ ] Multiple AI strategies for different playstyles
- [ ] Game balance analyzer (enemy difficulty, weapon effectiveness)
- [ ] Procedural content testing (auto-test generated levels)

## Success Metrics

How do we know this system is working?

1. **Catches performance regressions before merge** (>90% detection rate)
2. **Saves development time** (avoid manual performance testing)
3. **Guides optimization efforts** (identify bottlenecks with data)
4. **Tracks progress over time** (visualize long-term trends)
5. **Builds confidence** (ship knowing performance impact)

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| AI doesn't play well | Inconsistent benchmarks | Start with simple heuristics, validate manually |
| Metrics overhead affects performance | Skewed results | Make collector lightweight, toggleable |
| Long benchmark time | Slow CI/CD | Parallelize sessions, optimize runtime |
| Database bloat | Storage costs | Retention policy (keep 90 days), aggregation |
| False positives | Alert fatigue | Statistical significance tests, threshold tuning |

## Future Enhancements

- **Multi-platform benchmarking**: Test on Windows, Linux, Android
- **Automated A/B testing**: Compare two branches simultaneously
- **Player behavior modeling**: Compare AI to real player data
- **Balance optimization**: AI suggests weapon/enemy stat tweaks
- **Stress testing**: Find breaking points (max enemies, max projectiles)

---

**Author**: Claude + Yves
**Date**: 2025-11-08
**Status**: Design proposal - ready for implementation
