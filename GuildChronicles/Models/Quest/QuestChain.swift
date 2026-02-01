//
//  QuestChain.swift
//  GuildChronicles
//
//  Quest Chain system - the core feature (Section 4.2, 17)
//

import Foundation

/// Quest chain tier/category (Section 4.2)
enum QuestChainTier: Int, Codable, CaseIterable, Comparable {
    case regional = 1    // 4-8 quests, one season
    case realm = 2       // 7-12 quests, 1-2 seasons
    case continental = 3 // 12-20 quests, 2-4 seasons
    case legendary = 4   // 20-30 quests, multi-year

    var displayName: String {
        switch self {
        case .regional: return "Regional Story Arc"
        case .realm: return "Realm-Spanning Campaign"
        case .continental: return "Continental Saga"
        case .legendary: return "Legendary Campaign"
        }
    }

    var questCountRange: ClosedRange<Int> {
        switch self {
        case .regional: return 4...8
        case .realm: return 7...12
        case .continental: return 12...20
        case .legendary: return 20...30
        }
    }

    var estimatedSeasons: String {
        switch self {
        case .regional: return "1 season"
        case .realm: return "1-2 seasons"
        case .continental: return "2-4 seasons"
        case .legendary: return "Multiple years"
        }
    }

    var baseGoldReward: Int {
        switch self {
        case .regional: return 2000
        case .realm: return 10000
        case .continental: return 50000
        case .legendary: return 200000
        }
    }

    static func < (lhs: QuestChainTier, rhs: QuestChainTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Status of a quest chain
enum QuestChainStatus: String, Codable {
    case locked        // Prerequisites not met
    case available     // Can be started
    case inProgress    // Currently being pursued
    case completed     // Successfully finished
    case failed        // Failed catastrophically
    case abandoned     // Player chose to abandon

    var displayName: String {
        switch self {
        case .locked: return "Locked"
        case .available: return "Available"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .abandoned: return "Abandoned"
        }
    }
}

/// A quest chain - multi-quest storyline (Section 17.1)
struct QuestChain: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var tier: QuestChainTier
    var realm: Realm?  // nil for continental/legendary
    var status: QuestChainStatus

    // Quests
    var quests: [Quest]
    var currentQuestIndex: Int

    // Prerequisites
    var prerequisiteChainIDs: [UUID]
    var requiredGuildTier: GuildTier
    var requiredReputation: Int  // Minimum local reputation

    // Branching (Section 17.4)
    var branchingPoints: [BranchingPoint]
    var choicesMade: [UUID: BranchChoice]  // BranchingPoint ID -> Choice

    // Consequences (Section 17.4)
    var worldConsequences: [WorldConsequence]

    // Rewards
    var goldReward: Int
    var legendaryItemID: UUID?
    var reputationReward: Int
    var unlocksChainIDs: [UUID]

    // Timing
    var startedWeek: Int?
    var completedWeek: Int?
    var hasDeadline: Bool
    var deadlineWeek: Int?

    // MARK: - Computed Properties

    var currentQuest: Quest? {
        guard currentQuestIndex >= 0 && currentQuestIndex < quests.count else { return nil }
        return quests[currentQuestIndex]
    }

    var questCount: Int {
        quests.count
    }

    var completedQuestCount: Int {
        quests.filter { $0.status == .completed }.count
    }

    var progressPercent: Double {
        guard questCount > 0 else { return 0 }
        return Double(completedQuestCount) / Double(questCount)
    }

    var isComplete: Bool {
        status == .completed
    }

    var isFailed: Bool {
        status == .failed || status == .abandoned
    }

    var canStart: Bool {
        status == .available
    }

    var isActive: Bool {
        status == .inProgress
    }

    // MARK: - Story Structure (Section 17.1)

    var prologueQuest: Quest? {
        quests.first
    }

    var climaxQuest: Quest? {
        guard quests.count >= 3 else { return nil }
        return quests[quests.count - 2]  // Second to last
    }

    var resolutionQuest: Quest? {
        quests.last
    }

    // MARK: - Factory

    static func create(
        name: String,
        description: String,
        tier: QuestChainTier,
        realm: Realm? = nil,
        quests: [Quest],
        requiredGuildTier: GuildTier = .fledgling,
        goldReward: Int? = nil,
        reputationReward: Int = 10
    ) -> QuestChain {
        QuestChain(
            id: UUID(),
            name: name,
            description: description,
            tier: tier,
            realm: realm,
            status: .locked,
            quests: quests,
            currentQuestIndex: 0,
            prerequisiteChainIDs: [],
            requiredGuildTier: requiredGuildTier,
            requiredReputation: 0,
            branchingPoints: [],
            choicesMade: [:],
            worldConsequences: [],
            goldReward: goldReward ?? tier.baseGoldReward,
            legendaryItemID: nil,
            reputationReward: reputationReward,
            unlocksChainIDs: [],
            startedWeek: nil,
            completedWeek: nil,
            hasDeadline: false,
            deadlineWeek: nil
        )
    }
}

// MARK: - Branching System (Section 17.4)

/// A point in the story where player makes a choice
struct BranchingPoint: Identifiable, Codable, Equatable {
    let id: UUID
    var questIndex: Int  // Which quest this occurs during
    var description: String
    var choices: [BranchChoice]
    var isMoralChoice: Bool
    var isStrategicChoice: Bool
}

/// A choice at a branching point
struct BranchChoice: Identifiable, Codable, Equatable {
    let id: UUID
    var label: String
    var description: String
    var consequences: [ChoiceConsequence]
    var unlocksQuestID: UUID?  // Alternative quest path
    var blocksQuestID: UUID?   // Quest that becomes unavailable
}

/// Consequence of a choice (Section 17.4)
struct ChoiceConsequence: Codable, Equatable {
    var type: ConsequenceType
    var value: Int
    var description: String
    var targetID: UUID?  // Faction, NPC, etc.
}

enum ConsequenceType: String, Codable {
    case immediate       // This quest only
    case chainLocal      // Rest of this chain
    case realmWide       // Permanent realm effect
    case worldShaping    // Campaign-defining
    case factionReputation
    case npcRelationship
    case resourceGain
    case resourceLoss
}

/// World-level consequence of quest chain outcome
struct WorldConsequence: Identifiable, Codable, Equatable {
    let id: UUID
    var description: String
    var type: WorldConsequenceType
    var magnitude: ConsequenceMagnitude
    var affectedRealm: Realm?
    var isPermanent: Bool
}

enum WorldConsequenceType: String, Codable {
    case kingdomFalls
    case factionDestroyed
    case npcDeath
    case newThreatEmerges
    case allianceFormed
    case resourceDiscovered
    case curseLifted
    case artifactObtained
}

enum ConsequenceMagnitude: String, Codable {
    case minor
    case moderate
    case major
    case catastrophic
}
