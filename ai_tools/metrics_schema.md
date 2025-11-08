# Performance Metrics Schema

## Overview

This document defines all performance metrics collected during automated benchmarking sessions. Each metric has a clear definition, unit, collection method, and performance targets.

## Metric Categories

### 1. Frame Performance

| Metric | Definition | Unit | Collection | Target |
|--------|------------|------|------------|--------|
| **fps_avg** | Average frames per second | FPS | Every frame | ≥ 58 |
| **fps_min** | Minimum FPS during session | FPS | Every frame | ≥ 45 |
| **fps_max** | Maximum FPS during session | FPS | Every frame | ≤ 60 |
| **fps_p95** | 95th percentile FPS | FPS | Every frame | ≥ 59 |
| **fps_p99** | 99th percentile FPS | FPS | Every frame | ≥ 58 |
| **fps_stddev** | Standard deviation of FPS | FPS | Every frame | ≤ 5 |
| **frame_time_avg** | Average frame time | ms | Every frame | ≤ 16.67 |
| **frame_time_max** | Maximum frame time (worst spike) | ms | Every frame | ≤ 50 |

**Collection Method**:
```gdscript
var delta = get_process_delta_time()
metrics.record_frame_time(delta)
```

**Why it matters**: Stable 60 FPS is critical for smooth gameplay. Drops below 45 FPS are noticeable and degrade experience.

---

### 2. Memory Usage

| Metric | Definition | Unit | Collection | Target |
|--------|------------|------|------------|--------|
| **memory_static** | Static memory (code, assets) | MB | Every 1s | ≤ 200 |
| **memory_dynamic** | Dynamic memory (runtime allocations) | MB | Every 1s | ≤ 150 |
| **memory_dynamic_peak** | Peak dynamic memory | MB | Every 1s | ≤ 250 |
| **memory_texture** | Texture memory (VRAM) | MB | Every 1s | ≤ 500 |
| **memory_total** | Total memory usage | MB | Every 1s | ≤ 600 |
| **allocations_per_sec** | New allocations per second | count/s | Every frame | ≤ 100 |

**Collection Method**:
```gdscript
var stats = {
    "static": Performance.get_monitor(Performance.MEMORY_STATIC) / 1_048_576.0,
    "dynamic": Performance.get_monitor(Performance.MEMORY_DYNAMIC) / 1_048_576.0,
    "static_max": Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 1_048_576.0,
}
```

**Why it matters**: Memory leaks and excessive allocations cause stuttering and eventual crashes. Mobile devices have strict limits.

---

### 3. Entity Counts

| Metric | Definition | Unit | Collection | Target |
|--------|------------|------|------------|--------|
| **entities_total** | Total game objects | count | Every frame | ≤ 500 |
| **entities_enemies_avg** | Average enemy count | count | Every frame | 40-80 |
| **entities_enemies_max** | Maximum enemy count | count | Every frame | ≤ 150 |
| **entities_projectiles_avg** | Average projectile count | count | Every frame | 50-150 |
| **entities_projectiles_max** | Maximum projectile count | count | Every frame | ≤ 300 |
| **entities_collectibles** | Collectibles on screen | count | Every frame | ≤ 100 |
| **entities_effects** | Active visual effects | count | Every frame | ≤ 50 |

**Collection Method**:
```gdscript
var counts = {
    "enemies": get_tree().get_nodes_in_group("enemies").size(),
    "projectiles": get_tree().get_nodes_in_group("projectiles").size(),
    "collectibles": get_tree().get_nodes_in_group("collectibles").size(),
    "effects": get_tree().get_nodes_in_group("effects").size(),
}
```

**Why it matters**: Entity count directly correlates with performance. More entities = more physics, collision checks, rendering.

---

### 4. Physics Performance

| Metric | Definition | Unit | Collection | Target |
|--------|------------|------|------------|--------|
| **physics_time_avg** | Avg physics frame time | ms | Every physics frame | ≤ 4 |
| **physics_time_max** | Max physics frame time | ms | Every physics frame | ≤ 8 |
| **physics_bodies_active** | Active physics bodies | count | Every physics frame | ≤ 200 |
| **physics_collision_pairs** | Collision pairs checked | count | Every physics frame | ≤ 5000 |
| **physics_islands** | Simulation islands | count | Every physics frame | N/A |

**Collection Method**:
```gdscript
var physics_stats = {
    "time": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
    "bodies": PhysicsServer2D.get_process_info(PhysicsServer2D.INFO_ACTIVE_OBJECTS),
    "islands": PhysicsServer2D.get_process_info(PhysicsServer2D.INFO_ISLAND_COUNT),
}
```

**Why it matters**: Physics is often the bottleneck in entity-heavy games. Too many collision checks kills performance.

---

### 5. Rendering Performance

| Metric | Definition | Unit | Collection | Target |
|--------|------------|------|------------|--------|
| **render_time_avg** | Avg render frame time | ms | Every frame | ≤ 8 |
| **render_time_max** | Max render frame time | ms | Every frame | ≤ 12 |
| **draw_calls** | Draw calls per frame | count | Every frame | ≤ 50 |
| **vertices_rendered** | Vertices per frame | count | Every frame | ≤ 100k |
| **texture_switches** | Texture bind changes | count | Every frame | ≤ 20 |
| **shader_switches** | Shader program changes | count | Every frame | ≤ 10 |

**Collection Method**:
```gdscript
var render_stats = {
    "time": Performance.get_monitor(Performance.TIME_PROCESS),
    "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
    "objects": Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
}
```

**Why it matters**: Rendering bottlenecks show up as low GPU utilization or high frame times. Batching and texture atlases help.

---

### 6. Gameplay Metrics

| Metric | Definition | Unit | Collection | Target |
|--------|------------|------|------------|--------|
| **session_duration** | Total session time | seconds | End of session | 180-600 |
| **survival_time** | Time until first death | seconds | On death | ≥ 120 |
| **kills_total** | Total enemy kills | count | End of session | ≥ 300 |
| **kills_per_minute** | Kill rate | count/min | End of session | ≥ 50 |
| **damage_dealt** | Total damage output | damage | End of session | ≥ 10000 |
| **damage_taken** | Total damage received | damage | End of session | ≤ 2000 |
| **damage_ratio** | Dealt / Taken ratio | ratio | End of session | ≥ 5.0 |
| **coins_collected** | Total coins picked up | count | End of session | ≥ 200 |
| **coins_per_kill** | Avg coins per kill | ratio | End of session | 0.5-1.0 |
| **powerups_collected** | Powerups obtained | count | End of session | ≥ 5 |
| **deaths** | Number of deaths | count | End of session | ≤ 1 |

**Collection Method**:
```gdscript
# Event-based recording
signal enemy_killed(enemy_type, damage_dealt)
signal damage_received(amount, source)
signal coin_collected(value)

# Aggregate in MetricsCollector
func _on_enemy_killed(enemy_type, damage):
    _kills_total += 1
    _damage_dealt += damage
```

**Why it matters**: Gameplay metrics validate AI is playing effectively. Poor performance might indicate AI issues, not game performance.

---

### 7. AI Performance

| Metric | Definition | Unit | Collection | Target |
|--------|------------|------|------------|--------|
| **ai_decision_time_avg** | Avg AI decision time | ms | Every AI tick | ≤ 1 |
| **ai_decision_time_max** | Max AI decision time | ms | Every AI tick | ≤ 5 |
| **ai_path_recalc_count** | Pathfinding recalculations | count | End of session | N/A |
| **ai_target_switches** | Target changes per minute | count/min | End of session | 10-30 |
| **ai_accuracy** | Shots hit / shots fired | % | End of session | ≥ 40% |
| **ai_damage_efficiency** | Damage / time spent aiming | dmg/s | End of session | ≥ 50 |

**Collection Method**:
```gdscript
func _make_decision():
    var start_time = Time.get_ticks_usec()
    var decision = _compute_decision()
    var elapsed = (Time.get_ticks_usec() - start_time) / 1000.0  # Convert to ms
    MetricsCollector.record_ai_decision_time(elapsed)
    return decision
```

**Why it matters**: AI overhead should be negligible. If AI decisions take >5ms, it's stealing performance from gameplay.

---

## Derived Metrics

Calculated from raw metrics:

| Metric | Formula | Purpose |
|--------|---------|---------|
| **performance_score** | `(fps_avg / 60) * 100` | Overall performance grade |
| **stability_score** | `100 - (fps_stddev * 10)` | Frame time consistency |
| **efficiency_score** | `kills_total / memory_dynamic_peak` | Performance vs resource usage |
| **ai_skill_score** | `(kills_per_min * 0.4) + (damage_ratio * 0.3) + (survival_time / 10 * 0.3)` | AI effectiveness |

---

## Metric Thresholds & Alerts

### Critical Thresholds (Fail Build)
- `fps_avg < 50` → Build fails
- `fps_p95 < 45` → Build fails
- `memory_dynamic_peak > 400MB` → Build fails (mobile target)
- `session_duration < 60s` → AI is dying too fast (bad AI or game bug)

### Warning Thresholds (Alert Only)
- `fps_avg < 55` → Warning
- `memory_dynamic_peak > 300MB` → Warning
- `physics_time_avg > 5ms` → Warning
- `ai_decision_time_max > 3ms` → Warning

### Regression Detection
- `fps_avg drops by >5%` vs previous version → Regression
- `memory_dynamic_peak increases by >20%` → Regression
- `kills_per_minute drops by >10%` → AI or balance issue

---

## Sample Session Output

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2025-11-08T10:30:00Z",
  "git_commit": "abc123def456",
  "metrics": {
    "frame_performance": {
      "fps_avg": 58.3,
      "fps_min": 47.2,
      "fps_max": 60.0,
      "fps_p95": 59.8,
      "fps_p99": 59.2,
      "fps_stddev": 3.1,
      "frame_time_avg": 17.2,
      "frame_time_max": 42.0
    },
    "memory": {
      "memory_static": 185.2,
      "memory_dynamic": 142.5,
      "memory_dynamic_peak": 198.7,
      "memory_texture": 320.1,
      "memory_total": 527.8,
      "allocations_per_sec": 45
    },
    "entities": {
      "entities_total": 312,
      "entities_enemies_avg": 52,
      "entities_enemies_max": 98,
      "entities_projectiles_avg": 125,
      "entities_projectiles_max": 201,
      "entities_collectibles": 35,
      "entities_effects": 22
    },
    "physics": {
      "physics_time_avg": 3.8,
      "physics_time_max": 6.2,
      "physics_bodies_active": 178,
      "physics_collision_pairs": 3420,
      "physics_islands": 12
    },
    "rendering": {
      "render_time_avg": 7.5,
      "render_time_max": 11.3,
      "draw_calls": 38,
      "vertices_rendered": 42000,
      "texture_switches": 12,
      "shader_switches": 5
    },
    "gameplay": {
      "session_duration": 320.5,
      "survival_time": 320.5,
      "kills_total": 485,
      "kills_per_minute": 90.8,
      "damage_dealt": 18250,
      "damage_taken": 1850,
      "damage_ratio": 9.86,
      "coins_collected": 340,
      "coins_per_kill": 0.70,
      "powerups_collected": 8,
      "deaths": 0
    },
    "ai": {
      "ai_decision_time_avg": 0.82,
      "ai_decision_time_max": 2.1,
      "ai_path_recalc_count": 145,
      "ai_target_switches": 18.5,
      "ai_accuracy": 52.3,
      "ai_damage_efficiency": 57.0
    },
    "derived": {
      "performance_score": 97.2,
      "stability_score": 69.0,
      "efficiency_score": 2.44,
      "ai_skill_score": 68.5
    }
  }
}
```

---

## Visualization Recommendations

### Time Series Charts
- FPS over time (line chart with min/avg/max bands)
- Memory usage over time (area chart)
- Entity count over time (stacked area: enemies, projectiles, effects)

### Distribution Charts
- FPS histogram (show distribution, identify stutters)
- Frame time histogram (spot outliers)

### Correlation Charts
- Entity count vs FPS (scatter plot)
- Memory vs FPS (identify memory pressure threshold)

### Comparison Charts
- Multi-version FPS comparison (box plots)
- Metric radar chart (performance profile)

---

## Collection Performance Impact

The metrics collection system itself should have minimal overhead:

| Component | Overhead | Mitigation |
|-----------|----------|------------|
| Frame time recording | ~0.1ms/frame | Array append only |
| Entity counting | ~0.5ms/frame | Group iteration (cached) |
| Memory sampling | ~0.2ms/sample | Sample every 1s, not every frame |
| Event recording | ~0.05ms/event | Dictionary append |
| **Total** | **~1-2% FPS impact** | Acceptable for benchmarking |

**Production Mode**: Metrics collection disabled in release builds, zero overhead.

---

**Author**: Claude + Yves
**Date**: 2025-11-08
**Status**: Design complete - ready for implementation
