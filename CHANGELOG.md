# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
