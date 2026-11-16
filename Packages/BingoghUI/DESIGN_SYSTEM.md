# BingoghUI — configuration

The `BingoghUI` package holds the design system of `Bingogh`, generated from a Claude Design design system, and the components built on it.
Feature views only add these components. They never set colors, fonts, spacing or corner radii themselves.

## Source of truth

- `tokens.json` (this folder) is the tokens export of the Claude Design design system. In Claude Design it is `project/tokens.json`.
- `Sources/BingoghUI/Tokens/*.swift` and `Sources/BingoghUI/Resources/Colors.xcassets` are **generated** from it. Do not edit them by hand.
- To update the design system, replace `tokens.json` and run:

```
python3 scripts/codegen/design_tokens.py Packages/BingoghUI/tokens.json Packages/BingoghUI
```

## Tokens

| Swift type | Contents |
|---|---|
| `DSPalette` | Every color token, with light and dark values, from the asset catalog. |
| `DSColor` | Semantic roles used by the components: `background`, `surface`, `textPrimary`, `textSecondary`, `accent`, `onAccent`, `fillSecondary`, `destructive`, `onDestructive`, `separator`. |
| `DSTypeScale` / `DSFont` | Every type style / semantic fonts: `largeTitle`, `title`, `headline`, `body`, `bodyStrong`, `footnote`, `caption`. |
| `DSSpacing` | Every spacing token, plus `xSmall`, `small`, `medium`, `large`, `xLarge` and `tapMin`. |
| `DSRadius` | Every radius token, plus `small`, `control` and `card`. |

Custom fonts named in the tokens must be added to the app bundle (`.ttf`/`.otf`) and registered under `UIAppFonts` (iOS) or `ATSApplicationFontsPath` (macOS). Until then, SwiftUI falls back to the system font.

## Components

| Component | Use |
|---|---|
| `DSScreen { … }` | Root container of every screen: scroll view, background and margins. |
| `DSText(_:style:color:)` | Any text. `.counter` is the rounded style of counters such as "24 de 90". |
| `DSNightScreen { … }` | Root container of screens over the night sky that do not scroll (Inicio). Forces the dark appearance. |
| `DSNightSky()` | The `gradiente-noche-luna` background with moon, texture, swirls and stars. Used by `DSNightScreen`. |
| `DSWordmark(_:)` | The app's name as a serif wordmark: 64 pt on iPhone, 120 pt on iPad. |
| `DSButton(_:systemImage:style:action:)` | Actions, as capsules with an optional SF Symbol. Styles: `.primary`, `.secondary`, `.destructive`, `.translucent` (over the night sky). |
| `DSNavigationButton(_:value:systemImage:style:)` | A `DSButton` that pushes a route with `NavigationLink(value:)`. |
| `DSButtonGroup { … }` | Stacked buttons: full width on iPhone, 380 pt centred on iPad. |
| `DSTextField(_:value:)` | Text input. The first parameter is the placeholder. |
| `DSToggle(_:isOn:)` | Switch with a label. |
| `DSSectionHeader(_:)` | Header above a group of rows. |
| `DSListRow(_:subtitle:showsChevron:)` | Row in a list. |
| `DSCard { … }` | Groups content on a surface. |
| `DSGameScreen { … }` | Root container of the game (iPhone, iPad and TV): noche-900 to noche-800 gradient, dark appearance, no margins. |
| `DSSegmentedControl(selection:options:)` | Capsule segmented control over the night (Bombo / Tablero). Titles come localised. |
| `DSIconButton(systemImage:accessibilityLabel:action:)` | Round icon-only button beside a `DSButton` over the night. |
| `DSDrum(radius:turns:)` | The bingo drum. Raising `turns` spins it for 3 s. Radius 150 pt iPhone, 170 pt iPad, 260 pt TV. |
| `DSCallerBoard(title:counter:drawnNumbers:lastNumber:layout:size:)` | Board of the 90 numbers; drawn ones as balls, the last one ringed. `.portrait` 9×10 or `.landscape` 10×9; sizes `.compact`, `.regular`, `.television`. |
| `DSBall(number:diameter:)` | The ball that has just come out of the drum, with its number on a cream disc. 180 pt iPhone, 260 pt iPad, 520 pt TV. |
| `DSBallTone(number:)` | Tone of a ball from 1 to 90, one per ten, with the color of its number. |

New components go in `Sources/BingoghUI/Components/`, use only tokens, are `public` and include a `#Preview`. A component that shows a single text conforms to `DSLocalizableText`; components with several texts take them already localised.

## Localisation: `.localized(_:)`

Every component that shows text conforms to `DSLocalizableText` and gets a public `localized` extension. It receives a key, localises it and returns the component with the localised text:

```swift
DSText(style: .largeTitle).localized("profile.title")
DSButton { viewModel.save() }.localized("profile.save")
DSTextField(value: $email).localized("login.email.placeholder")
```

Keys are looked up in the app's `Localizable.xcstrings` (`Bundle.main`). Pass `table:` and `bundle:` to use another catalog. Because the key is passed as a value, Xcode does not extract it automatically, so add every new key to the String Catalog.
