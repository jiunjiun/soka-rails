# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2025-08-05

### Added
- Support for Ruby 3.1, 3.2, and 3.3

### Changed
- Updated CI/CD workflows to test all supported Ruby versions
- Adjusted RuboCop target version to minimum supported version (3.1)
- Updated gemspec minimum Ruby version requirement
- Upgraded soka dependency to 0.0.5

## [0.0.4] - 2025-08-04

### Added
- Support for dynamic instructions in Soka v0.0.4
- Ability to generate agent instructions dynamically via methods
- Context-aware behavior based on runtime conditions (environment, time, user, etc.)
- Updated README with dynamic instructions examples
- Enhanced agent generator template with dynamic instructions examples

## [0.0.3] - 2025-08-04

### Added
- Upgrade to Soka v0.0.3 with custom instructions and multilingual support

## [0.0.2] - 2025-08-01

### Fixed
- Comment out private keyword in agent template
- Resolve Rails autoloading issues for agents and tools

### Changed
- Add link to full changelog in release notes

## [0.0.1] - 2025-08-01

### Added
- Extract version-specific changelog for GitHub releases

### Changed
- Release workflow now parses CHANGELOG.md to extract entries for specific versions
- GitHub releases use extracted content as release notes instead of auto-generated notes

## [0.0.1.beta4] - 2025-08-01

### Fixed
- Correct version constant namespace in release workflow

## [0.0.1.beta3] - 2025-08-01

### Fixed
- Corrected version file path in release workflow

## [0.0.1.beta2] - 2025-08-01

### Added
- GitHub Actions workflows for CI/CD

### Changed
- Initial implementation improvements and refinements

## [0.0.1.beta1] - 2025-07-29

### Added
- Initial release of Soka Rails
- Rails integration with automatic loading of agents and tools from `app/soka`
- Configuration system with DSL support
- ApplicationAgent base class with Rails hooks integration
- ApplicationTool base class with helper methods
- RailsInfoTool for querying Rails application information
- Rails generators:
  - `soka:install` - Initial setup generator
  - `soka:agent` - Agent generator
  - `soka:tool` - Tool generator
- RSpec test helpers and integration
- Comprehensive error handling
- Full documentation and examples
