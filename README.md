# CardGameByMahu

A macOS SwiftUI card-guessing game with a Hardcore mode, history, and leaderboard.

---

**Features**
- SwiftUI macOS app with Touch Bar support
- Persistent storage with SwiftData for history, scores and hardcore results
- Two play modes: regular and Hardcore (timed, scored runs)
- Match history and Hardcore leaderboard
- Voice command support for dealing and guesses

---

**Requirements**
- macOS (latest recommended)
- Xcode 15+ (or the version that supports SwiftData & Observation)

---

**Build & Run**
1. Open the project in Xcode: CardGameByMahu.xcodeproj or the workspace in the project folder.
2. Select the `CardGameByMahu` target and run on My Mac.
3. For UI tests, the app looks for the `-uitesting` launch argument (the UI tests set this automatically).

Optional terminal test command (may require adjusting the scheme/destination):

```
# Run unit tests via xcodebuild (example)
xcodebuild test -project CardGameByMahu.xcodeproj -scheme CardGameByMahu -destination 'platform=macOS'
```

---

**Project Structure (high level)**
- `Assets.xcassets/` — app icons, card images and backgrounds
- `Data/` — SwiftData models and deck/settings logic
  - [DeckOfCards.swift](CardGameByMahu/Data/DeckOfCards.swift)
  - [DeckSettings.swift](CardGameByMahu/Data/DeckSettings.swift)
  - [RoundHistory.swift](CardGameByMahu/Data/RoundHistory.swift)
  - [HardcoreResult.swift](CardGameByMahu/Data/HardcoreResult.swift)
- `View/` — SwiftUI views
  - [ContentView.swift](CardGameByMahu/View/ContentView.swift)
  - [GameView.swift](CardGameByMahu/View/GameView.swift)
  - [SetupView.swift](CardGameByMahu/View/SetupView.swift)
  - [HistoryView.swift](CardGameByMahu/View/HistoryView.swift)
  - [LeaderboardView.swift](CardGameByMahu/View/LeaderboardView.swift)
- `ViewModel/` — view models and app logic
  - [CardGameViewModel.swift](CardGameByMahu/ViewModel/CardGameViewModel.swift)
  - [HardcoreGameViewModel.swift](CardGameByMahu/ViewModel/HardcoreGameViewModel.swift)
  - [SetupViewModel.swift](CardGameByMahu/ViewModel/SetupViewModel.swift)
  - [TouchBarViewModel.swift](CardGameByMahu/ViewModel/TouchBarViewModel.swift)
- `CardGameByMahuApp.swift` — app entry and SwiftData container setup

---

**Important Notes**
- The app uses a local SwiftData store. On schema incompatibility the app currently attempts to delete the store and fall back to an in-memory store (see `CardGameByMahuApp.swift`). Consider adding proper migrations for production use.
- Touch Bar integration is implemented for macOS in `View/TouchBarView.swift` and coordinated via `TouchBarViewModel`.
- Voice command support is implemented in `ViewModel/VoiceCommandService.swift` and used from `GameView`.

---

**Testing**
- Unit tests are in `CardGameByMahuUnitTests/` (examples: `CardGameViewModelTest.swift`, `HardcoreGameViewModelTest.swift`). Tests use in-memory SwiftData containers for isolation.
- UI tests are in `CardGameByMahuUITests/` and exercise common flows. They launch the app with `-uitesting`.

---

**Contributing**
- Fork the repo and open a PR with a clear description and tests for behavior changes.

---

If you want, I can: add screenshots, expand the developer setup steps, or include a sample release workflow.
