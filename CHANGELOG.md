# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Interface.GetBytecode() may now return nil to indicate that the module is not yet ready to load.

## [0.1.3] - 2025-11-13

### Fixed

- Fiu now syncs in correctly to Roblox

## [0.1.2] - 2025-11-12

### Fixed

- Fiu is now included as a build file on Roblox targets (should fix issue with it not syncing in)

## [0.1.1] - 2025-11-06

### Changed

- Changed type exports to include impl and proto

### Fixed

- Fixed type for .new()

## [0.1.0] - 2025-11-06

- Initial release

[unreleased]: https://github.com/ewd3v/luau_graft/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/ewd3v/luau_graft/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/ewd3v/luau_graft/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/ewd3v/luau_graft/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/ewd3v/luau_graft/compare/788bbe1f83576f7f9edc294f9f9b63d9d2583070...v0.1.0
