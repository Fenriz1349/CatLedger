# CatLedger

A privacy-focused personal finance and expense tracking app for iOS/macOS/visionOS, built with SwiftUI and Clean Architecture.

## Status

Early setup — Domain layer and features are being built incrementally.

## Architecture

- **Clean Architecture** per feature: `Data` / `Domain` (+ `UseCases`) / `Presentation`
- **Core** modules shared across features (branding, lifecycle rules, sync, graphs, etc.)

## Versioning

The app version is tracked in `CatLedger/Resources/Version.xcconfig` and bumped automatically
by [release-please](https://github.com/googleapis/release-please) based on
[Conventional Commits](https://www.conventionalcommits.org/) merged into `main`.

## Branching model

- `main` — production, tagged releases
- `dev` — integration branch
- feature branches — merged into `dev` via pull request
