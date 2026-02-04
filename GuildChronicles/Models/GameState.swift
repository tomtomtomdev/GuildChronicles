//
//  GameState.swift
//  GuildChronicles
//
//  Core game state container
//

import Foundation

/// Central game state for a campaign
@Observable
final class GameState {
    // MARK: - Campaign Info
    var campaignName: String
    var currentSeason: Int
    var currentMonth: Int  // 1-12 within season
    var totalWeeksElapsed: Int

    // MARK: - Player Guild
    var playerGuildID: UUID?

    // MARK: - World State
    var allAdventurers: [UUID: Adventurer]
    var freeAgents: [UUID]

    // MARK: - Quest State
    var availableQuests: [Quest] = []
    var activeQuests: [Quest] = []
    var completedQuests: [Quest] = []

    // MARK: - Event History
    var events: [GameEvent] = []

    // MARK: - Game Settings
    var settings: GameSettings

    // MARK: - Computed

    var weekInSeason: Int {
        (currentMonth - 1) * 4 + 1
    }

    var seasonPhase: SeasonPhase {
        switch currentMonth {
        case 1...3: return .springThaw
        case 4...6: return .summerCampaign
        case 7...9: return .autumnHarvest
        case 10...12: return .wintersEnd
        default: return .springThaw
        }
    }

    var freeAgentAdventurers: [Adventurer] {
        freeAgents.compactMap { allAdventurers[$0] }
    }

    var currentTimestamp: GameTimestamp {
        GameTimestamp(
            season: currentSeason,
            month: currentMonth,
            week: weekInSeason
        )
    }

    var recentEvents: [GameEvent] {
        Array(events.suffix(20))
    }

    // MARK: - Init

    init() {
        self.campaignName = "New Campaign"
        self.currentSeason = 1
        self.currentMonth = 1
        self.totalWeeksElapsed = 0
        self.playerGuildID = nil
        self.allAdventurers = [:]
        self.freeAgents = []
        self.settings = GameSettings()
    }

    // MARK: - Time Progression

    func advanceWeek() {
        totalWeeksElapsed += 1

        // 4 weeks per month, 12 months per season
        let weekInMonth = (totalWeeksElapsed % 4)
        if weekInMonth == 0 {
            currentMonth += 1
            if currentMonth > 12 {
                currentMonth = 1
                currentSeason += 1
            }
        }
    }

    // MARK: - Adventurer Management

    func addAdventurer(_ adventurer: Adventurer) {
        allAdventurers[adventurer.id] = adventurer
        if adventurer.contractStatus == .freeAgent {
            freeAgents.append(adventurer.id)
        }
    }

    func getAdventurer(by id: UUID) -> Adventurer? {
        allAdventurers[id]
    }

    /// Generate initial free agents for game start
    func generateInitialFreeAgents(count: Int = 50) {
        for _ in 0..<count {
            let level = AdventurerLevel.allCases.randomElement()!
            let adventurer = Adventurer.random(level: level)
            addAdventurer(adventurer)
        }
    }

    // MARK: - Event Management

    func addEvent(_ type: EventType, message: String, relatedEntityID: UUID? = nil) {
        let event = GameEvent(
            type: type,
            message: message,
            timestamp: currentTimestamp,
            relatedEntityID: relatedEntityID
        )
        events.append(event)
    }

    func clearOldEvents(keepCount: Int = 100) {
        if events.count > keepCount {
            events = Array(events.suffix(keepCount))
        }
    }
}

// MARK: - Supporting Types

enum SeasonPhase: String, Codable {
    case springThaw       // Months 1-3: Season begins, recruitment
    case summerCampaign   // Months 4-6: Peak adventuring
    case autumnHarvest    // Months 7-9: Championship push
    case wintersEnd       // Months 10-12: Season conclusion

    var displayName: String {
        switch self {
        case .springThaw: return "Spring Thaw"
        case .summerCampaign: return "Summer Campaign"
        case .autumnHarvest: return "Autumn Harvest"
        case .wintersEnd: return "Winter's End"
        }
    }
}

struct GameSettings: Codable {
    var attributeMaskingEnabled: Bool = true  // Fog of war (Section 3.2)
    var permadeathEnabled: Bool = false       // Section 18.2
    var ironmanMode: Bool = false             // Single save
    var difficultyLevel: DifficultyLevel = .normal
    var autoSaveEnabled: Bool = true
    var tutorialEnabled: Bool = true
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy
    case normal
    case hard
    case legendary

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// Multiplier for enemy strength
    var enemyStrengthMultiplier: Double {
        switch self {
        case .easy: return 0.75
        case .normal: return 1.0
        case .hard: return 1.25
        case .legendary: return 1.5
        }
    }

    /// Multiplier for gold rewards
    var rewardMultiplier: Double {
        switch self {
        case .easy: return 1.25
        case .normal: return 1.0
        case .hard: return 0.9
        case .legendary: return 0.75
        }
    }
}
