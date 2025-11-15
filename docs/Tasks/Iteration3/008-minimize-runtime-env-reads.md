# 008 - Minimize Runtime ENV Reads

## Goal
Load ENV values once.

## Why
Repeated cfg.get_env_value is slow.

## Steps
1. Cache all ENV into Globals.env_cache at boot.
2. Replace runtime calls with cached values.

## Performance
Small but consistent savings.

## Tests
- ENV still respected.
