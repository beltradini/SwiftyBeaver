# Fix: make `BaseDestination.queue` non-optional and remove crash risk

## Summary

This patch ensures `BaseDestination.queue` is always initialized in `init()`, removing the possibility of a `fatalError("Queue not set")` crash when destinations are created concurrently or used immediately after creation. The behavior is maintained (queue remains a private serial queue with `.utility` QoS) but is now safe in concurrent creation scenarios.

## Changes

- **Sources:**
  - `Sources/BaseDestination.swift` — `queue` is now non-optional and initialized in `init()`.
  - `Sources/SwiftyBeaver.swift` — minor adjustments to use `dest.queue` directly.

- **Tests:**
  - `Tests/SwiftyBeaverTests/BaseDestinationQueueTests.swift` — unit tests for async/sync execution, ordering, and error propagation.
  - `Tests/SwiftyBeaverTests/StressTests.swift` — added stress/concurrency tests (`testConcurrentAsyncNoCrashStress`, `testMixedSyncAsyncNoDeadlock`, `testNoFatalErrorUnderRace`).

- **CI / Changelog:**
  - `.github/workflows/ci.yml` — runs `swift test` on macOS and Ubuntu; Linux job will run `./test_in_docker.sh` if Docker is available.
  - `CHANGELOG.md` — added `Unreleased` entry describing the fix.

## Test Evidence

- Local: `swift test` → **226 tests, 0 failures** (includes new stress tests).
- Stress tests validate concurrent creation and mixed sync/async usage to prevent regressions.
