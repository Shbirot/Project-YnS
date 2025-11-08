# AI Tools & Performance Infrastructure

## Overview

This directory contains design documentation and tooling for **AI-driven performance testing and optimization** for Nightfall Survivor. The goal is to build an infrastructure that can:

1. **Play the game autonomously** using trained AI agents
2. **Collect performance metrics** across different versions
3. **Benchmark and compare** performance over time
4. **Guide architectural decisions** with data-driven insights

## Purpose

As a bullet-heaven game targeting 60+ FPS with hundreds of entities on screen, performance is critical. This infrastructure provides:

- **Automated testing**: AI agents play the game to stress-test systems
- **Regression detection**: Catch performance drops between versions
- **Optimization guidance**: Identify bottlenecks and validate improvements
- **Version tracking**: Historical metrics tied to git commits

## Directory Structure

```
ai_tools/
├── README.md                          # This file
├── architecture_refactor.md           # Object hierarchy redesign plan
├── ai_infrastructure.md               # AI training & testing system design
├── metrics_schema.md                  # Performance metrics definitions
├── implementation_roadmap.md          # Step-by-step implementation plan
├── diagrams/
│   ├── object_hierarchy.md            # New object hierarchy diagram
│   ├── ai_system_architecture.md      # AI infrastructure diagram
│   └── data_flow.md                   # Metrics collection flow
└── scripts/                           # Future: automation scripts
    ├── benchmark_runner.py
    ├── metrics_analyzer.py
    └── version_comparer.py
```

## Key Documents

### 1. [AI Infrastructure](./ai_infrastructure.md)
Design for AI training and performance testing system:
- AI agent that learns to play optimally
- Session recording and replay
- Metrics collection pipeline
- Performance analysis tools

### 3. [Metrics Schema](./metrics_schema.md)
Defines what we measure:
- Frame time (avg, min, max, p95, p99)
- Memory usage (heap, static, peak)
- Entity counts (enemies, projectiles, particles)
- Physics performance
- Render performance
- AI decision time

### 4. [Implementation Roadmap](./implementation_roadmap.md)
Step-by-step plan to implement both systems incrementally without breaking existing game.

## Design Principles

### Performance First
- Minimize node count and tree traversal
- Pool frequently created objects
- Use collision layers/masks efficiently
- Static systems for cross-entity logic
- Batch processing where possible

### Maintainability
- Clear separation of concerns
- Composition over deep inheritance
- Well-documented interfaces
- Extensive test coverage

### Measurability
- Everything performance-critical is measured
- Metrics tied to git commits
- Automated benchmarks on every significant change
- Historical tracking and visualization

## Vision: The Development Loop

```
1. Developer makes changes
   ↓
2. AI agent plays the game (100 sessions)
   ↓
3. Metrics collected automatically
   ↓
4. Performance compared to previous version
   ↓
5. Report generated:
   - FPS change: +5% ✅
   - Memory: +10MB ⚠️
   - Entity count: +20% (new feature) ℹ️
   ↓
6. Developer decides: ship, optimize, or revert
```

## Getting Started

1. **Read the architecture refactor plan** to understand the proposed object hierarchy
2. **Review the AI infrastructure design** to see how automated testing will work
3. **Check the metrics schema** to understand what we're measuring
4. **Follow the implementation roadmap** to build incrementally

## Status

- ✅ Design phase (current)
- ⏳ Object hierarchy refactor
- ⏳ Metrics collection infrastructure
- ⏳ AI agent implementation
- ⏳ Performance analysis tools
- ⏳ Historical tracking system

## Future Extensions

- **ML-based optimization**: Train models to suggest code optimizations
- **Auto-balancing**: AI adjusts game balance based on playtest data
- **Procedural content**: AI-driven level generation and testing
- **Quality metrics**: Beyond performance - fun, difficulty, progression pacing

---

**Last Updated**: 2025-11-08
**Status**: Design phase - architecture planning in progress
