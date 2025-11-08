# AI System Architecture Diagram

## High-Level System Overview

```
┌───────────────────────────────────────────────────────────────────┐
│                     NIGHTFALL SURVIVOR GAME                       │
│                                                                   │
│  ┌──────────────┐  ┌───────────────┐  ┌────────────────────┐     │
│  │   AI Agent   │→ │  Game Logic   │→ │ Metrics Collector  │     │
│  │  (Player)    │  │  (Main.gd)    │  │    (Autoload)      │     │
│  └──────────────┘  └───────────────┘  └────────────────────┘     │
│         ↓                  ↓                      ↓               │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │          Session Recorder (JSON output)                  │    │
│  │  • Git commit hash                                       │    │
│  │  • Performance metrics (FPS, memory, entities)           │    │
│  │  • Gameplay metrics (kills, damage, coins)               │    │
│  │  • Event timeline (spawns, deaths, pickups)              │    │
│  └──────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────┘
                              ↓ (writes session_<uuid>.json)
┌───────────────────────────────────────────────────────────────────┐
│               PERFORMANCE ANALYSIS PIPELINE                       │
│                                                                   │
│  ┌──────────────┐   ┌────────────────┐   ┌──────────────────┐   │
│  │  Metrics DB  │ ← │ DB Ingestion   │ ← │  Session JSON    │   │
│  │  (SQLite)    │   │   (Python)     │   │     Files        │   │
│  └──────────────┘   └────────────────┘   └──────────────────┘   │
│         ↓                                                         │
│  ┌──────────────┐   ┌────────────────┐   ┌──────────────────┐   │
│  │   Query &    │ → │   Analyzer     │ → │  Report Gen      │   │
│  │  Aggregate   │   │  (Statistics)  │   │  (HTML + Charts) │   │
│  └──────────────┘   └────────────────┘   └──────────────────┘   │
└───────────────────────────────────────────────────────────────────┘
                              ↓ (generates HTML report)
┌───────────────────────────────────────────────────────────────────┐
│                  VERSION COMPARISON & ALERTS                      │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  Interactive Dashboard                                   │    │
│  │  • FPS trends over time (line chart)                     │    │
│  │  • Memory usage growth (area chart)                      │    │
│  │  • Entity count vs FPS (scatter plot)                    │    │
│  │  • Commit comparison (side-by-side)                      │    │
│  │  • Regression alerts (highlight issues)                  │    │
│  └──────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────┘
```

---

## Component Detail: AI Agent

```
┌────────────────────────────────────────────────────────────┐
│                       AIAgent.gd                           │
│                                                            │
│  Strategies:                                               │
│  ├── AGGRESSIVE   → Max DPS, risky positioning            │
│  ├── BALANCED     → Mix offense/defense                   │
│  ├── DEFENSIVE    → Survival-focused, kiting              │
│  └── COLLECTOR    → Prioritize pickups/coins              │
│                                                            │
│  Decision Pipeline (every frame):                         │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 1. Perceive Environment                            │   │
│  │    ├── Find enemies (distance, HP, threat level)   │   │
│  │    ├── Find pickups (value, distance)              │   │
│  │    ├── Evaluate danger zones                       │   │
│  │    └── Check player HP, cooldowns                  │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 2. Make Decision (strategy-dependent)              │   │
│  │    ├── Calculate threat score for each enemy       │   │
│  │    ├── Calculate value score for each pickup       │   │
│  │    ├── Choose optimal position (safe + valuable)   │   │
│  │    └── Select target for attack                    │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 3. Execute Action                                  │   │
│  │    ├── Set movement input vector                   │   │
│  │    ├── Trigger weapon fire (if ready)              │   │
│  │    └── Use abilities (if needed)                   │   │
│  └────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘

Example Heuristic (BALANCED strategy):
=======================================

func _make_decision(threats, opportunities):
    var hp_ratio = stats.current_health / stats.max_health

    # If low HP, prioritize survival
    if hp_ratio < 0.3:
        return _defensive_decision(threats, opportunities)

    # If many enemies nearby, kite
    if threats.size() > 5:
        return {
            "action": "kite",
            "direction": _calculate_kite_direction(threats),
            "target": threats[0],  # Still shoot while kiting
        }

    # If valuable pickup nearby, collect
    if opportunities.size() > 0 and opportunities[0].value > 50:
        return {
            "action": "collect",
            "direction": (opportunities[0].position - global_position).normalized(),
            "target": null,
        }

    # Default: engage enemies
    return {
        "action": "engage",
        "direction": _calculate_optimal_position(threats),
        "target": _prioritize_target(threats),
    }
```

---

## Component Detail: Metrics Collector

```
┌────────────────────────────────────────────────────────────┐
│                  MetricsCollector.gd                       │
│                     (Autoload)                             │
│                                                            │
│  Responsibilities:                                         │
│  ├── Track frame times (delta, FPS)                       │
│  ├── Sample memory usage (static, dynamic, peak)          │
│  ├── Count entities (enemies, projectiles, effects)       │
│  ├── Record gameplay events (kills, damage, pickups)      │
│  └── Generate session summary                             │
│                                                            │
│  Data Structures:                                         │
│  ┌────────────────────────────────────────────────────┐   │
│  │ _frame_times: Array[float]                         │   │
│  │   → Every frame delta                              │   │
│  │   → Used to calculate FPS stats (avg, p95, p99)    │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ _memory_samples: Array[Dictionary]                 │   │
│  │   → Sampled every 1 second                         │   │
│  │   → { "static", "dynamic", "timestamp" }           │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ _entity_snapshots: Array[Dictionary]               │   │
│  │   → Every frame                                    │   │
│  │   → { "enemies", "projectiles", "collectibles" }   │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ _gameplay_events: Array[Dictionary]                │   │
│  │   → Event-driven                                   │   │
│  │   → { "type", "data", "timestamp" }                │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  Output (end of session):                                 │
│  └→ JSON file with aggregated statistics                  │
└────────────────────────────────────────────────────────────┘

Integration Points:
===================

# GameController starts session
MetricsCollector.start_session()

# Game systems record events
MetricsCollector.record_gameplay_event("enemy_killed", {
    "enemy_type": "bat",
    "damage": 50,
})

# GameController ends session
var summary = MetricsCollector.end_session()
SessionRecorder.save_session(summary)
```

---

## Component Detail: Benchmark Runner (Python)

```
┌────────────────────────────────────────────────────────────┐
│                 benchmark_runner.py                        │
│                                                            │
│  Workflow:                                                 │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 1. Validate Environment                            │   │
│  │    ├── Check git status (clean or committed)       │   │
│  │    ├── Get current commit hash & branch            │   │
│  │    └── Verify Godot executable exists              │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 2. Launch Godot Sessions                           │   │
│  │    ├── Run N sessions (default 10)                 │   │
│  │    ├── Headless mode (--headless --disable-render) │   │
│  │    ├── AI agent enabled (--ai-agent BALANCED)      │   │
│  │    └── Collect session JSON files                  │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 3. Aggregate Results                               │   │
│  │    ├── Load all session JSON files                 │   │
│  │    ├── Compute statistics (mean, stddev, p95, p99) │   │
│  │    └── Detect outliers (remove if needed)          │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 4. Compare to Baseline (optional)                  │   │
│  │    ├── Load previous commit's results from DB      │   │
│  │    ├── Calculate percent change                    │   │
│  │    └── Run statistical significance test (t-test)  │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 5. Generate Report                                 │   │
│  │    ├── Print summary to console                    │   │
│  │    ├── Save JSON report file                       │   │
│  │    ├── Generate HTML report (optional)             │   │
│  │    └── Exit with code (0=pass, 1=regression)       │   │
│  └────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘

Usage Examples:
===============

# Basic benchmark (10 sessions)
$ python ai_tools/scripts/benchmark_runner.py

# Benchmark with comparison to previous commit
$ python ai_tools/scripts/benchmark_runner.py --compare HEAD~1

# Benchmark with specific strategy
$ python ai_tools/scripts/benchmark_runner.py --strategy AGGRESSIVE --sessions 20

# Full benchmarking suite (all strategies)
$ python ai_tools/scripts/benchmark_runner.py --all-strategies
```

---

## Component Detail: Metrics Database (SQLite)

```
┌────────────────────────────────────────────────────────────┐
│                     metrics.db (SQLite)                    │
│                                                            │
│  Table: sessions                                           │
│  ┌────────────────────────────────────────────────────┐   │
│  │ id               TEXT PRIMARY KEY (UUID)           │   │
│  │ git_commit       TEXT NOT NULL                     │   │
│  │ git_branch       TEXT                              │   │
│  │ timestamp        DATETIME DEFAULT CURRENT_TIMESTAMP│   │
│  │ godot_version    TEXT                              │   │
│  │ environment      TEXT (dev/stage/prod)             │   │
│  │ ai_strategy      TEXT (BALANCED/AGGRESSIVE/etc)    │   │
│  │ config           JSON (session configuration)      │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  Table: performance_metrics                                │
│  ┌────────────────────────────────────────────────────┐   │
│  │ session_id       TEXT (FK → sessions.id)           │   │
│  │ metric_name      TEXT (fps_avg, memory_peak, etc.) │   │
│  │ value            REAL                              │   │
│  │ unit             TEXT (FPS, MB, ms, etc.)          │   │
│  │ PRIMARY KEY (session_id, metric_name)              │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  Table: gameplay_metrics                                   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ session_id       TEXT (FK → sessions.id)           │   │
│  │ duration         REAL                              │   │
│  │ kills            INTEGER                           │   │
│  │ damage_dealt     INTEGER                           │   │
│  │ damage_taken     INTEGER                           │   │
│  │ coins_collected  INTEGER                           │   │
│  │ deaths           INTEGER                           │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  Table: events                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │ id               INTEGER PRIMARY KEY AUTOINCREMENT │   │
│  │ session_id       TEXT (FK → sessions.id)           │   │
│  │ timestamp        REAL (seconds since session start)│   │
│  │ event_type       TEXT (spawn_wave, death, etc.)    │   │
│  │ data             JSON (event-specific data)        │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  Indexes:                                                  │
│  ├── idx_commit ON sessions(git_commit)                   │
│  ├── idx_timestamp ON sessions(timestamp)                 │
│  └── idx_metric ON performance_metrics(metric_name)       │
└────────────────────────────────────────────────────────────┘

Example Queries:
================

-- Get average FPS for a commit
SELECT AVG(value) FROM performance_metrics
WHERE metric_name = 'fps_avg'
  AND session_id IN (
    SELECT id FROM sessions WHERE git_commit = 'abc123'
  );

-- Compare two commits
SELECT
  a.git_commit,
  AVG(a.value) as fps_current,
  AVG(b.value) as fps_baseline,
  (AVG(a.value) - AVG(b.value)) / AVG(b.value) * 100 as percent_change
FROM performance_metrics a
JOIN sessions sa ON a.session_id = sa.id
JOIN performance_metrics b ON a.metric_name = b.metric_name
JOIN sessions sb ON b.session_id = sb.id
WHERE a.metric_name = 'fps_avg'
  AND sa.git_commit = 'abc123'
  AND sb.git_commit = 'abc122'
GROUP BY a.git_commit;

-- Trend over time (last 30 days)
SELECT
  DATE(timestamp) as date,
  AVG(value) as fps_avg,
  MIN(value) as fps_min,
  MAX(value) as fps_max
FROM performance_metrics
JOIN sessions ON performance_metrics.session_id = sessions.id
WHERE metric_name = 'fps_avg'
  AND timestamp > datetime('now', '-30 days')
GROUP BY DATE(timestamp)
ORDER BY date;
```

---

## Component Detail: Report Generator

```
┌────────────────────────────────────────────────────────────┐
│               report_generator.py                          │
│                                                            │
│  Input: Benchmark results (from DB or JSON)                │
│  Output: HTML report with interactive charts               │
│                                                            │
│  Report Sections:                                          │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 1. Executive Summary                               │   │
│  │    ├── Commit info (hash, branch, date)            │   │
│  │    ├── Pass/Fail status (red/green)                │   │
│  │    ├── Key metrics (FPS, memory, entities)         │   │
│  │    └── Comparison to baseline (% change)           │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 2. FPS Analysis                                    │   │
│  │    ├── Line chart: FPS over session time           │   │
│  │    ├── Histogram: FPS distribution                 │   │
│  │    ├── Box plot: FPS across sessions               │   │
│  │    └── Table: avg, min, max, p95, p99, stddev      │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 3. Memory Profile                                  │   │
│  │    ├── Area chart: Memory usage over time          │   │
│  │    ├── Line chart: Peak memory per session         │   │
│  │    └── Table: avg, peak, growth rate               │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 4. Entity Scaling                                  │   │
│  │    ├── Stacked area: Entities over time            │   │
│  │    ├── Scatter: Entity count vs FPS                │   │
│  │    └── Table: avg enemies, avg projectiles, max    │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 5. Gameplay Metrics                                │   │
│  │    ├── Bar chart: Kills, damage, coins             │   │
│  │    ├── Comparison to baseline (side-by-side)       │   │
│  │    └── AI skill score (derived metric)             │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 6. Event Timeline                                  │   │
│  │    ├── Timeline: Notable events (spawns, deaths)   │   │
│  │    └── Annotations on FPS chart                    │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 7. Regression Analysis                             │   │
│  │    ├── Table: All metrics comparison               │   │
│  │    ├── Highlight regressions (red) / improvements  │   │
│  │    └── Statistical significance (p-value)          │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
│  Technologies:                                             │
│  ├── Plotly.js (interactive charts)                       │
│  ├── Pandas (data processing)                             │
│  ├── Jinja2 (HTML templating)                             │
│  └── SciPy (statistical tests)                            │
└────────────────────────────────────────────────────────────┘
```

---

## CI/CD Integration Workflow

```
┌────────────────────────────────────────────────────────────┐
│          GitHub Actions: Performance Check                 │
│                                                            │
│  Trigger: Pull request to main/dev                         │
│                                                            │
│  Steps:                                                    │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 1. Checkout code                                   │   │
│  │    ├── Fetch depth 2 (need base commit)            │   │
│  │    └── Get PR base commit hash                     │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 2. Setup environment                               │   │
│  │    ├── Install Godot (via chickensoft setup action)│   │
│  │    ├── Install Python 3.10                         │   │
│  │    └── Install Python deps (pip install -r ...)    │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 3. Run benchmark (PR head)                         │   │
│  │    ├── python benchmark_runner.py --sessions 10    │   │
│  │    ├── Save results to benchmark_head.json         │   │
│  │    └── Ingest to database                          │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 4. Checkout base commit (comparison)               │   │
│  │    ├── git checkout HEAD~1                         │   │
│  │    ├── python benchmark_runner.py --sessions 10    │   │
│  │    ├── Save results to benchmark_base.json         │   │
│  │    └── Ingest to database                          │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 5. Compare results                                 │   │
│  │    ├── python regression_checker.py                │   │
│  │    ├── --head benchmark_head.json                  │   │
│  │    ├── --base benchmark_base.json                  │   │
│  │    ├── --threshold-fps -5.0                        │   │
│  │    └── --threshold-memory +20.0                    │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 6. Generate report                                 │   │
│  │    ├── python report_generator.py                  │   │
│  │    ├── Output: ./reports/pr_<number>.html          │   │
│  │    └── Upload as artifact                          │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 7. Comment on PR                                   │   │
│  │    ├── Post summary table (FPS, memory, entities)  │   │
│  │    ├── Highlight regressions (⚠️) or improvements  │   │
│  │    └── Link to full HTML report                    │   │
│  └────────────────────────────────────────────────────┘   │
│  ┌────────────────────────────────────────────────────┐   │
│  │ 8. Exit status                                     │   │
│  │    ├── Exit 0 if no regressions (PR can merge)     │   │
│  │    └── Exit 1 if regressions detected (block merge)│   │
│  └────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────┘

Example PR Comment:
===================

## 🎮 Performance Benchmark Results

| Metric | Current | Previous | Change | Status |
|--------|---------|----------|--------|--------|
| FPS (avg) | 58.3 | 56.1 | **+3.9%** | ✅ |
| Memory (peak) | 198 MB | 185 MB | **+7.0%** | ⚠️ |
| Entities (max) | 312 | 298 | **+4.7%** | ℹ️ |
| Kills/min | 90.8 | 88.5 | **+2.6%** | ✅ |

**Overall**: ✅ No critical regressions detected

📊 [View full report](https://artifacts/.../pr_123.html)
```

---

**Author**: Claude + Yves
**Date**: 2025-11-08
**Status**: Design complete - ready for implementation
