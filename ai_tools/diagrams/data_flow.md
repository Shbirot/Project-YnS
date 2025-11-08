# Data Flow Diagram

## Metrics Collection Flow (During Gameplay)

```
┌───────────────────────────────────────────────────────────────┐
│                         GAME LOOP                             │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  _process(delta):                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 1. MetricsCollector._process(delta)                     │ │
│  │    ├── Record frame time: _frame_times.append(delta)    │ │
│  │    ├── Count entities:                                  │ │
│  │    │   ├── enemies = get_tree().get_nodes_in_group("enemies").size() │
│  │    │   ├── projectiles = ...                            │ │
│  │    │   └── Store in _entity_snapshots                   │ │
│  │    └── Emit metrics_updated signal (real-time data)     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  _physics_process(delta):                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 2. Game Logic                                           │ │
│  │    ├── Enemy AI decisions                               │ │
│  │    ├── Projectile movement                              │ │
│  │    ├── Collision detection                              │ │
│  │    └── Trigger events:                                  │ │
│  │        ├── enemy_killed →                               │ │
│  │        │   MetricsCollector.record_gameplay_event(...)  │ │
│  │        ├── damage_taken →                               │ │
│  │        │   MetricsCollector.record_gameplay_event(...)  │ │
│  │        └── coin_collected →                             │ │
│  │            MetricsCollector.record_gameplay_event(...)  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  Memory Sampling Timer (every 1 second):                      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 3. Sample Memory                                        │ │
│  │    ├── static = Performance.get_monitor(MEMORY_STATIC)  │ │
│  │    ├── dynamic = Performance.get_monitor(MEMORY_DYNAMIC)│ │
│  │    └── Store in _memory_samples                         │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                  SESSION END (Game Over)                      │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  GameController._on_game_over():                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 1. Stop metrics collection                              │ │
│  │    var summary = MetricsCollector.end_session()         │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 2. Generate summary statistics                          │ │
│  │    ├── Aggregate _frame_times → fps_avg, fps_p95, ...  │ │
│  │    ├── Aggregate _memory_samples → memory_peak, ...     │ │
│  │    ├── Aggregate _entity_snapshots → entities_max, ...  │ │
│  │    └── Summarize _gameplay_events → kills, damage, ...  │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 3. Create session record                                │ │
│  │    {                                                    │ │
│  │      "session_id": UUID,                                │ │
│  │      "git_commit": get_git_commit(),                    │ │
│  │      "timestamp": ISO8601,                              │ │
│  │      "metrics": {                                       │ │
│  │        "frame_performance": {...},                      │ │
│  │        "memory": {...},                                 │ │
│  │        "entities": {...},                               │ │
│  │        "gameplay": {...}                                │ │
│  │      },                                                 │ │
│  │      "events": [...]                                    │ │
│  │    }                                                    │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ 4. Save to file                                         │ │
│  │    SessionRecorder.save_session(summary)                │ │
│  │    → user://metrics/session_<uuid>.json                 │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

---

## Benchmark Pipeline Flow (Automated Testing)

```
┌───────────────────────────────────────────────────────────────┐
│                    BENCHMARK RUNNER                           │
│                  (benchmark_runner.py)                        │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Validate Environment                                      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ • Check git status (clean or committed)                 │ │
│  │ • Get commit hash: abc123def                            │ │
│  │ • Get branch: main                                      │ │
│  │ • Verify Godot executable exists                        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  2. Launch N Sessions (default 10)                            │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ for i in range(10):                                     │ │
│  │   subprocess.run([                                      │ │
│  │     "godot",                                            │ │
│  │     "--headless",                                       │ │
│  │     "--disable-render-loop",                            │ │
│  │     "--",                                               │ │
│  │     "--ai-agent",                                       │ │
│  │     "--ai-strategy", "BALANCED",                        │ │
│  │     "--session-id", f"bench_{i}",                       │ │
│  │   ])                                                    │ │
│  │   # Wait for session to complete                        │ │
│  │   # Session writes JSON to user://metrics/              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  3. Collect Session Files                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ session_files = glob("~/.local/share/godot/app_userdata/nightfall/metrics/*.json") │
│  │ sessions = [json.load(f) for f in session_files]        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  4. Aggregate Statistics                                      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ fps_values = [s["metrics"]["fps"]["avg"] for s in sessions] │
│  │ aggregate = {                                           │ │
│  │   "fps_avg": np.mean(fps_values),                       │ │
│  │   "fps_stddev": np.std(fps_values),                     │ │
│  │   "fps_min": np.min([s["metrics"]["fps"]["min"] for s in sessions]), │
│  │   "fps_p95": np.percentile(...),                        │ │
│  │   ...                                                   │ │
│  │ }                                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  5. Store in Database                                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ db.insert_sessions(sessions)                            │ │
│  │ db.insert_aggregate(commit="abc123", data=aggregate)    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  6. Compare to Baseline (if --compare flag)                   │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ baseline = db.get_aggregate(commit="abc122")            │ │
│  │ comparison = {                                          │ │
│  │   "fps_change": (aggregate.fps - baseline.fps) / baseline.fps * 100, │
│  │   "memory_change": ...,                                 │ │
│  │   "regression_detected": fps_change < -5.0              │ │
│  │ }                                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  7. Generate Report                                           │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ report_generator.create_html(                           │ │
│  │   aggregate=aggregate,                                  │ │
│  │   baseline=baseline,                                    │ │
│  │   comparison=comparison,                                │ │
│  │   output="reports/benchmark_abc123.html"                │ │
│  │ )                                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  8. Print Summary & Exit                                      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ print(f"FPS: {aggregate.fps:.1f} ({comparison.fps_change:+.1f}%)") │
│  │ if comparison.regression_detected:                      │ │
│  │   exit(1)  # Fail build                                 │ │
│  │ else:                                                   │ │
│  │   exit(0)  # Pass                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

---

## Database Storage Flow

```
┌───────────────────────────────────────────────────────────────┐
│                    DB INGESTION                               │
│                 (db_ingestion.py)                             │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  Input: session_<uuid>.json                                   │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ {                                                       │ │
│  │   "session_id": "550e8400-...",                         │ │
│  │   "git_commit": "abc123",                               │ │
│  │   "timestamp": "2025-11-08T10:30:00Z",                  │ │
│  │   "metrics": {                                          │ │
│  │     "fps": { "avg": 58.3, "min": 47.2, ... },           │ │
│  │     "memory": { "peak": 198.5, ... },                   │ │
│  │     ...                                                 │ │
│  │   },                                                    │ │
│  │   "events": [...]                                       │ │
│  │ }                                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  Transform to Relational Schema                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ INSERT INTO sessions VALUES (                           │ │
│  │   "550e8400-...",  -- id                                │ │
│  │   "abc123",        -- git_commit                        │ │
│  │   "main",          -- git_branch                        │ │
│  │   "2025-11-08 10:30:00",  -- timestamp                  │ │
│  │   "4.2.2",         -- godot_version                     │ │
│  │   "dev",           -- environment                       │ │
│  │   "BALANCED",      -- ai_strategy                       │ │
│  │   '{"seed": 42}'   -- config (JSON)                     │ │
│  │ );                                                      │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ INSERT INTO performance_metrics VALUES                  │ │
│  │   ("550e8400-...", "fps_avg", 58.3, "FPS"),             │ │
│  │   ("550e8400-...", "fps_min", 47.2, "FPS"),             │ │
│  │   ("550e8400-...", "fps_p95", 59.8, "FPS"),             │ │
│  │   ("550e8400-...", "memory_peak", 198.5, "MB"),         │ │
│  │   ...;                                                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ INSERT INTO gameplay_metrics VALUES (                   │ │
│  │   "550e8400-...",  -- session_id                        │ │
│  │   320.5,           -- duration                          │ │
│  │   485,             -- kills                             │ │
│  │   18250,           -- damage_dealt                      │ │
│  │   1850,            -- damage_taken                      │ │
│  │   340,             -- coins_collected                   │ │
│  │   0                -- deaths                            │ │
│  │ );                                                      │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ INSERT INTO events VALUES                               │ │
│  │   (NULL, "550e8400-...", 5.2, "spawn_wave", '{"wave": 1}'), │
│  │   (NULL, "550e8400-...", 45.0, "level_up", '{"level": 2}'), │
│  │   ...;                                                  │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

---

## Analysis & Reporting Flow

```
┌───────────────────────────────────────────────────────────────┐
│                  METRICS ANALYZER                             │
│               (metrics_analyzer.py)                           │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Query Database                                            │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ # Get all sessions for current commit                   │ │
│  │ current_sessions = db.query("""                         │ │
│  │   SELECT * FROM sessions                                │ │
│  │   WHERE git_commit = ?                                  │ │
│  │ """, commit_hash)                                       │ │
│  │                                                         │ │
│  │ # Get performance metrics                               │ │
│  │ current_metrics = db.query("""                          │ │
│  │   SELECT metric_name, AVG(value) as avg, STDDEV(value)  │ │
│  │   FROM performance_metrics                              │ │
│  │   WHERE session_id IN (...)                             │ │
│  │   GROUP BY metric_name                                  │ │
│  │ """)                                                    │ │
│  │                                                         │ │
│  │ # Same for baseline commit                              │ │
│  │ baseline_metrics = db.query(..., baseline_commit)       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  2. Statistical Comparison                                    │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ from scipy import stats                                 │ │
│  │                                                         │ │
│  │ # T-test for statistical significance                   │ │
│  │ t_stat, p_value = stats.ttest_ind(                      │ │
│  │   current_fps_samples,                                  │ │
│  │   baseline_fps_samples                                  │ │
│  │ )                                                       │ │
│  │                                                         │ │
│  │ # Calculate effect size (Cohen's d)                     │ │
│  │ effect_size = (mean_current - mean_baseline) / pooled_std │
│  │                                                         │ │
│  │ # Determine significance                                │ │
│  │ is_significant = (p_value < 0.05) and (abs(effect_size) > 0.3) │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  3. Trend Detection                                           │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ # Get last 30 days of data                              │ │
│  │ trend_data = db.query("""                               │ │
│  │   SELECT DATE(timestamp), AVG(value)                    │ │
│  │   FROM performance_metrics                              │ │
│  │   JOIN sessions ON session_id = sessions.id             │ │
│  │   WHERE metric_name = 'fps_avg'                         │ │
│  │     AND timestamp > datetime('now', '-30 days')         │ │
│  │   GROUP BY DATE(timestamp)                              │ │
│  │ """)                                                    │ │
│  │                                                         │ │
│  │ # Linear regression for trend                           │ │
│  │ slope, intercept, r_value = stats.linregress(...)       │ │
│  │                                                         │ │
│  │ # Detect: improving, degrading, or stable?              │ │
│  │ if slope > 0.1:                                         │ │
│  │   trend = "improving"                                   │ │
│  │ elif slope < -0.1:                                      │ │
│  │   trend = "degrading"                                   │ │
│  │ else:                                                   │ │
│  │   trend = "stable"                                      │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  4. Generate Insights                                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ insights = {                                            │ │
│  │   "regression_detected": is_significant and change < -5%,│ │
│  │   "improvement_detected": is_significant and change > 5%,│ │
│  │   "trend": trend,                                       │ │
│  │   "recommendations": [                                  │ │
│  │     "Memory usage increased by 15% - investigate allocations", │
│  │     "FPS improved by 3% - good job!",                   │ │
│  │   ]                                                     │ │
│  │ }                                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                  REPORT GENERATOR                             │
│              (report_generator.py)                            │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Prepare Data for Visualization                            │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ import pandas as pd                                     │ │
│  │ import plotly.express as px                             │ │
│  │                                                         │ │
│  │ # Convert DB results to DataFrame                       │ │
│  │ df_fps = pd.DataFrame(fps_data)                         │ │
│  │ df_memory = pd.DataFrame(memory_data)                   │ │
│  │ df_entities = pd.DataFrame(entity_data)                 │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  2. Create Charts                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ # FPS over time (line chart)                            │ │
│  │ fig_fps = px.line(df_fps, x='time', y='fps',            │ │
│  │                   title='FPS Over Session Time')        │ │
│  │                                                         │ │
│  │ # FPS histogram                                         │ │
│  │ fig_hist = px.histogram(df_fps, x='fps', nbins=50,      │ │
│  │                         title='FPS Distribution')       │ │
│  │                                                         │ │
│  │ # Entity count vs FPS (scatter)                         │ │
│  │ fig_scatter = px.scatter(df_entities, x='entity_count', │ │
│  │                          y='fps', trendline='ols')      │ │
│  │                                                         │ │
│  │ # Convert to HTML                                       │ │
│  │ fps_chart_html = fig_fps.to_html()                      │ │
│  │ hist_chart_html = fig_hist.to_html()                    │ │
│  │ scatter_chart_html = fig_scatter.to_html()              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  3. Render HTML Template                                      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ from jinja2 import Template                             │ │
│  │                                                         │ │
│  │ template = Template(open('report_template.html').read())│ │
│  │ html_output = template.render(                          │ │
│  │   commit=commit_hash,                                   │ │
│  │   branch=branch_name,                                   │ │
│  │   timestamp=timestamp,                                  │ │
│  │   metrics=current_metrics,                              │ │
│  │   baseline=baseline_metrics,                            │ │
│  │   comparison=comparison,                                │ │
│  │   insights=insights,                                    │ │
│  │   fps_chart=fps_chart_html,                             │ │
│  │   hist_chart=hist_chart_html,                           │ │
│  │   scatter_chart=scatter_chart_html,                     │ │
│  │ )                                                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ↓                                │
│  4. Save Report                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ output_path = f"reports/benchmark_{commit_hash}.html"   │ │
│  │ with open(output_path, 'w') as f:                       │ │
│  │   f.write(html_output)                                  │ │
│  │                                                         │ │
│  │ print(f"Report saved to {output_path}")                 │ │
│  └─────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

---

## CI/CD Data Flow

```
GitHub PR → Trigger Workflow
    ↓
[Step 1] Checkout PR head commit
    ↓
[Step 2] Run benchmark (10 sessions)
    ↓
Godot (headless) × 10
    ├→ Session 1 → session_001.json
    ├→ Session 2 → session_002.json
    ├→ ...
    └→ Session 10 → session_010.json
    ↓
[Step 3] Aggregate results
    ├→ Load all 10 JSON files
    ├→ Compute statistics (mean, stddev, percentiles)
    └→ benchmark_head.json
    ↓
[Step 4] Checkout base commit (PR base)
    ↓
[Step 5] Run benchmark (10 sessions)
    ↓
Godot (headless) × 10
    ├→ Session 1 → session_base_001.json
    ├→ ...
    └→ Session 10 → session_base_010.json
    ↓
[Step 6] Aggregate results
    └→ benchmark_base.json
    ↓
[Step 7] Compare head vs base
    ├→ Calculate percent changes
    ├→ Run statistical tests
    └→ comparison.json
    ↓
[Step 8] Generate HTML report
    └→ reports/pr_123.html
    ↓
[Step 9] Post comment on PR
    ├→ Summary table (markdown)
    ├→ Link to full report
    └→ Pass/Fail status
    ↓
[Step 10] Exit
    ├→ Exit 0 (success) → PR can merge
    └→ Exit 1 (regression) → PR blocked
```

---

**Author**: Claude + Yves
**Date**: 2025-11-08
**Status**: Design complete
