# Change Log

All notable changes to the **SyncWatch** extension are documented here.

## [0.1.0] - 2026-06-05

### Added
- Initial public release.
- Config-driven (`syncwatch.json`) inspection of custom thread and semaphore
  structures during GDB (`cppdbg`) debugging.
- Two traversal modes: `linked_list` (head pointer + `next` field) and `array`
  (`count` elements, with `.`/`->` element access).
- Arbitrary `root` expressions (e.g. `g_kernel.pools[0]->thread_list`).
- Tabbed Webview panel with colored state badges, depleted/waiter highlighting,
  and per-tab summaries.
- Live refresh on debugger `stopped`/`continued` events.
- Settings: `syncwatch.configPath`, `syncwatch.debugTypes`.
