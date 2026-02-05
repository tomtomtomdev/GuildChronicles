# GuildChronicles

A guild management game for iOS/macOS built with SwiftUI. Take on the role of a guild master, recruiting adventurers, dispatching them on quests, and building your guild's reputation across the realm.

## Features

- **Adventurer Management** - Recruit heroes of various races and classes, each with unique attributes and abilities
- **Quest System** - Accept contracts from the quest board, form parties, and send them on adventures
- **Guild Operations** - Manage facilities, staff, finances, and guild council
- **Progression** - Adventurers gain experience and level up from successful quests
- **Loot & Equipment** - Collect weapons, armor, accessories, and consumables from completed quests
- **Save/Load** - Full save system with quick save support

## Requirements

- Xcode 16+
- iOS 26.0+ / macOS 15.0+
- Swift 6.0+

## Getting Started

1. Clone the repository
2. Open `GuildChronicles.xcodeproj` in Xcode
3. Select your target device/simulator
4. Build and run (Cmd+R)

## Project Structure

```
GuildChronicles/
├── Models/
│   ├── Adventurer/      # Adventurer, AdventurerAttributes
│   ├── Guild/           # Guild, Staff, Facilities, Council, Finances
│   ├── Quest/           # Quest, QuestChain, Party, QuestEvent
│   ├── Item/            # Item, Equipment, Consumable, LootTable
│   └── Enums/           # AdventurerClass, AdventurerRace, Realm, etc.
├── Views/
│   ├── MainMenu/        # MainMenuView, NewCampaignView, SettingsView
│   ├── Game/            # MainGameView, DashboardView
│   ├── Roster/          # RosterListView, AdventurerDetailView, RecruitmentView
│   ├── Quest/           # QuestBoardView, QuestDetailView
│   ├── Guild/           # GuildManagementView
│   └── Inventory/       # InventoryView
└── Services/
    ├── QuestService             # Quest generation and management
    ├── QuestExecutionService    # Quest resolution and success calculation
    ├── RecruitmentService       # Adventurer generation
    ├── LevelingService          # XP and level progression
    ├── LootService              # Loot generation from quests
    ├── GuildService             # Guild operations
    ├── TimeService              # In-game time management
    ├── SaveManager              # Save/load persistence
    ├── HapticService            # Tactile feedback
    ├── AudioService             # Sound effects
    └── BalanceConfig            # Game balance tuning values
```

## Architecture

- **Models** are value types (structs) with `Codable` conformance for persistence
- **Services** are stateless enums with static methods
- **Views** use SwiftUI with `@Observable` for state management
- **AppState** manages navigation and holds references to game state

## Running Tests

```bash
xcodebuild -scheme GuildChronicles \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

## License

MIT License
