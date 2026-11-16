# Bingogh

SwiftUI app for iOS (iPhone), iPadOS.

The app is written in SwiftUI (Swift 6 language mode) with MVVM and a feature-based architecture, and it is split
into Swift packages.

## Requirements

- Xcode with the SDKs of the app's platforms (the deployment targets are in `project.yml`).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) and [SwiftLint](https://github.com/realm/SwiftLint).

## Getting started

```bash
brew install xcodegen swiftlint
xcodegen generate
open Bingogh.xcodeproj
```

The Xcode project is generated from `project.yml` and is not committed. Run `xcodegen generate` again after you pull
changes that add, move or remove files.

## Tests and lint

```bash
(cd Packages/BingoghData && swift test)   # data layer tests
(cd Packages/BingoghUI && swift test)     # design system tests
scripts/lint.sh                            # SwiftLint, the same check as the build
```

SwiftLint runs before every build and the build fails above 3 violations. New code adds none.

## Structure

```
Bingogh/                  App target: App/, Core/, Features/, Resources/ and FEATURES.md
Packages/BingoghData/     Data layer: repositories, DAOs, the Alamofire client and local storage (DATA.md)
Packages/BingoghUI/       Design system: tokens from Claude Design and UI components (DESIGN_SYSTEM.md)
scripts/codegen/           Generators for features, repositories and design tokens
scripts/lint.sh            SwiftLint check used by the build
.claude/skills/            Project skills: bingogh-new-feature, bingogh-new-repo
```

## Features

`Bingogh/FEATURES.md` holds the feature registry and the app map.

## Contributing

- Read `AGENTS.md` first: it lists the architecture rules, and points to the configuration file of each area.
- Create features and repositories with the generators (or the project skills), never by hand:

  ```bash
  python3 scripts/codegen/new_feature.py --name X --parent Y [--repository Z]
  python3 scripts/codegen/new_repo.py --name X --type remote|local [--storage json|swiftdata|userdefaults|keychain]
  ```

- Git flow: `main` holds releases and `develop` is the integration branch. Build each feature on
  `feature/Bingogh-<Feature>`, created from `develop`, and open the pull request against `develop`.
- Add every user-facing text to `Bingogh/Resources/Localizable.xcstrings`.
