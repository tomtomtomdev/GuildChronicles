//
//  Quest.swift
//  GuildChronicles
//
//  Individual quest model (Sections 3.3, 17.3)
//

import Foundation

/// Types of quests within chains (Section 17.3)
enum QuestType: String, Codable, CaseIterable {
    case investigation
    case combat
    case exploration
    case social
    case ritual
    case siege
    case escort
    case retrieval
    case assassination
    case defense

    var displayName: String {
        switch self {
        case .investigation: return "Investigation"
        case .combat: return "Combat"
        case .exploration: return "Exploration"
        case .social: return "Social Encounter"
        case .ritual: return "Ritual"
        case .siege: return "Siege/Assault"
        case .escort: return "Escort Mission"
        case .retrieval: return "Retrieval"
        case .assassination: return "Assassination"
        case .defense: return "Defense"
        }
    }

    var description: String {
        switch self {
        case .investigation:
            return "Gather information through interviews and exploration"
        case .combat:
            return "Direct confrontation with enemies"
        case .exploration:
            return "Navigate dangerous terrain, dungeons, ruins"
        case .social:
            return "Negotiate, persuade, or infiltrate"
        case .ritual:
            return "Time-sensitive magical challenges"
        case .siege:
            return "Assault fortification or protect location"
        case .escort:
            return "Protect a VIP during travel"
        case .retrieval:
            return "Recover an important item or person"
        case .assassination:
            return "Eliminate a specific target"
        case .defense:
            return "Hold a position against attackers"
        }
    }

    /// Primary attributes that affect success
    var primaryAttributes: [AttributeType] {
        switch self {
        case .investigation:
            return [.perception, .wisdom, .awareness, .cunning]
        case .combat:
            return [.meleeCombat, .rangedCombat, .defense, .battleTactics]
        case .exploration:
            return [.perception, .endurance, .awareness, .dexterity]
        case .social:
            return [.charisma, .cunning, .leadership, .willpower]
        case .ritual:
            return [.arcanePower, .concentration, .ritualCasting, .manaPool]
        case .siege:
            return [.battleTactics, .leadership, .fortitude, .teamwork]
        case .escort:
            return [.awareness, .perception, .speed, .defense]
        case .retrieval:
            return [.dexterity, .cunning, .perception, .speed]
        case .assassination:
            return [.cunning, .dexterity, .criticalStrikes, .awareness]
        case .defense:
            return [.defense, .fortitude, .endurance, .morale]
        }
    }

    var recommendedPartySize: ClosedRange<Int> {
        switch self {
        case .investigation: return 2...4
        case .combat: return 4...6
        case .exploration: return 3...5
        case .social: return 1...3
        case .ritual: return 2...4
        case .siege: return 5...6
        case .escort: return 4...6
        case .retrieval: return 2...4
        case .assassination: return 1...3
        case .defense: return 4...6
        }
    }
}

/// Danger level / stakes of a quest
enum QuestStakes: String, Codable, Comparable {
    case low
    case medium
    case high
    case critical

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var deathRiskMultiplier: Double {
        switch self {
        case .low: return 0.02
        case .medium: return 0.05
        case .high: return 0.10
        case .critical: return 0.20
        }
    }

    var rewardMultiplier: Double {
        switch self {
        case .low: return 0.5
        case .medium: return 1.0
        case .high: return 1.5
        case .critical: return 2.5
        }
    }

    static func < (lhs: QuestStakes, rhs: QuestStakes) -> Bool {
        let order: [QuestStakes] = [.low, .medium, .high, .critical]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

/// Quest outcome status
enum QuestStatus: String, Codable {
    case locked
    case available
    case inProgress
    case completed
    case partialSuccess
    case failed

    var displayName: String {
        switch self {
        case .locked: return "Locked"
        case .available: return "Available"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .partialSuccess: return "Partial Success"
        case .failed: return "Failed"
        }
    }
}

/// An individual quest within a chain
struct Quest: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var type: QuestType
    var stakes: QuestStakes
    var status: QuestStatus

    // Structure
    var storyPosition: StoryPosition
    var segmentCount: Int  // Number of segments in quest
    var estimatedDurationMinutes: Int

    // Requirements
    var minimumPartySize: Int
    var maximumPartySize: Int
    var requiredClasses: [AdventurerClass]  // Must have at least one
    var recommendedLevel: AdventurerLevel

    // Rewards
    var baseGoldReward: Int
    var experienceReward: Int
    var lootTableID: UUID?

    // Narrative
    var prologueText: String
    var successText: String
    var failureText: String
    var partialSuccessText: String?

    // Result (after completion)
    var result: QuestResult?

    // MARK: - Computed Properties

    var isComplete: Bool {
        status == .completed || status == .partialSuccess
    }

    var isFailed: Bool {
        status == .failed
    }

    var canStart: Bool {
        status == .available
    }

    var effectiveReward: Int {
        Int(Double(baseGoldReward) * stakes.rewardMultiplier)
    }

    // MARK: - Factory

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func create(
        name: String,
        description: String,
        type: QuestType,
        stakes: QuestStakes,
        storyPosition: StoryPosition,
        baseGoldReward: Int,
        prologueText: String = "",
        successText: String = "",
        failureText: String = ""
    ) -> Quest {
        Quest(
            id: UUID(),
            name: name,
            description: description,
            type: type,
            stakes: stakes,
            status: .locked,
            storyPosition: storyPosition,
            segmentCount: Int.random(in: 5...15),
            estimatedDurationMinutes: Int.random(in: 5...15),
            minimumPartySize: type.recommendedPartySize.lowerBound,
            maximumPartySize: type.recommendedPartySize.upperBound,
            requiredClasses: [],
            recommendedLevel: .journeyman,
            baseGoldReward: baseGoldReward,
            experienceReward: baseGoldReward / 10,
            lootTableID: nil,
            prologueText: prologueText,
            successText: successText,
            failureText: failureText,
            partialSuccessText: nil,
            result: nil
        )
    }
}

/// Position in story structure (Section 17.1)
enum StoryPosition: String, Codable {
    case prologue
    case risingAction
    case midpoint
    case complication
    case climax
    case resolution

    var displayName: String {
        switch self {
        case .prologue: return "Prologue"
        case .risingAction: return "Rising Action"
        case .midpoint: return "Midpoint"
        case .complication: return "Complication"
        case .climax: return "Climax"
        case .resolution: return "Resolution"
        }
    }
}

/// Result of a completed quest
struct QuestResult: Codable, Equatable {
    var outcome: QuestOutcome
    var goldEarned: Int
    var experienceEarned: Int
    var lootObtained: [UUID]  // Item IDs
    var adventurerRatings: [UUID: Double]  // Adventurer ID -> Rating (1-10)
    var injuries: [UUID: InjuryType]  // Adventurer ID -> Injury
    var deaths: [UUID]  // Adventurer IDs who died
    var completedWeek: Int
    var segmentsCompleted: Int
    var totalSegments: Int
}

enum QuestOutcome: String, Codable {
    case success
    case partialSuccess
    case failure
    case catastrophicFailure
    case perfectVictory

    var displayName: String {
        switch self {
        case .success: return "Success"
        case .partialSuccess: return "Partial Success"
        case .failure: return "Failure"
        case .catastrophicFailure: return "Catastrophic Failure"
        case .perfectVictory: return "Perfect Victory"
        }
    }

    var reputationModifier: Int {
        switch self {
        case .perfectVictory: return 5
        case .success: return 2
        case .partialSuccess: return 0
        case .failure: return -3
        case .catastrophicFailure: return -10
        }
    }
}
