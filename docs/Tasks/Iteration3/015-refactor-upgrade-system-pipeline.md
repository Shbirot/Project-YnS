# 015 - Refactor Upgrade System Pipeline

## Goal
Make upgrade system event-driven.

## Why
Polling for pickups wastes CPU.

## Steps
1. UpgradeManager listens for pickup signals.
2. Hero reacts only when event fired.

## Performance
Less per-frame work.

## Tests
- Pickups still activate correctly.
