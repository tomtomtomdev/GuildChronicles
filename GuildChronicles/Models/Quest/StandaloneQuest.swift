//
//  StandaloneQuest.swift
//  GuildChronicles
//
//  Standalone quest types (Section 17.6)
//

import Foundation

/// Types of standalone quests (not part of chains)
enum StandaloneQuestType: String, Codable, CaseIterable {
    case bountyHunt
    case patronRequest
    case emergencyResponse
    case dungeonExpedition
    case rivalGuildEncounter

    var displayName: String {
        switch self {
        case .bountyHunt: return "Bounty Hunt"
        case .patronRequest: return "Patron Request"
        case .emergencyResponse: return "Emergency Response"
        case .dungeonExpedition: return "Dungeon Expedition"
        case .rivalGuildEncounter: return "Rival Guild Encounter"
        }
    }

    var description: String {
        switch self {
        case .bountyHunt:
            return "Repeatable monster hunts for quick gold and experience"
        case .patronRequest:
            return "Personal favors for council members to build relationships"
        case .emergencyResponse:
            return "Time-limited crisis quests with high risk/reward"
        case .dungeonExpedition:
            return "Open-ended exploration with procedural encounters"
        case .rivalGuildEncounter:
            return "Compete against other guilds for objectives"
        }
    }

    var isRepeatable: Bool {
        switch self {
        case .bountyHunt, .dungeonExpedition:
            return true
        case .patronRequest, .emergencyResponse, .rivalGuildEncounter:
            return false
        }
    }

    var hasTimePressure: Bool {
        self == .emergencyResponse
    }

    var affectsNarrative: Bool {
        switch self {
        case .bountyHunt, .dungeonExpedition:
            return false
        case .patronRequest, .emergencyResponse, .rivalGuildEncounter:
            return true
        }
    }

    var baseRewardMultiplier: Double {
        switch self {
        case .bountyHunt: return 0.5
        case .patronRequest: return 0.3
        case .emergencyResponse: return 2.0
        case .dungeonExpedition: return 1.5
        case .rivalGuildEncounter: return 1.0
        }
    }
}

/// A standalone quest (not part of a chain)
struct StandaloneQuest: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var standaloneType: StandaloneQuestType
    var baseQuest: Quest

    // Type-specific data
    var bountyTarget: BountyTarget?
    var patronID: UUID?  // For patron requests
    var deadlineWeek: Int?  // For emergency response
    var rivalGuildID: UUID?  // For rival encounters
    var dungeonDepth: Int?  // For expeditions

    // State
    var isAvailable: Bool
    var timesCompleted: Int

    var effectiveReward: Int {
        Int(Double(baseQuest.baseGoldReward) * standaloneType.baseRewardMultiplier)
    }

    static func bounty(
        name: String,
        target: BountyTarget,
        reward: Int
    ) -> StandaloneQuest {
        StandaloneQuest(
            id: UUID(),
            name: name,
            description: "Hunt and eliminate \(target.displayName)",
            standaloneType: .bountyHunt,
            baseQuest: Quest.create(
                name: name,
                description: "Bounty hunt for \(target.displayName)",
                type: .combat,
                stakes: target.stakes,
                storyPosition: .prologue,
                baseGoldReward: reward
            ),
            bountyTarget: target,
            patronID: nil,
            deadlineWeek: nil,
            rivalGuildID: nil,
            dungeonDepth: nil,
            isAvailable: true,
            timesCompleted: 0
        )
    }

    static func patronFavor(
        name: String,
        patronID: UUID,
        reward: Int
    ) -> StandaloneQuest {
        StandaloneQuest(
            id: UUID(),
            name: name,
            description: "A personal request from one of your patrons",
            standaloneType: .patronRequest,
            baseQuest: Quest.create(
                name: name,
                description: "Patron request",
                type: .social,
                stakes: .low,
                storyPosition: .prologue,
                baseGoldReward: reward
            ),
            bountyTarget: nil,
            patronID: patronID,
            deadlineWeek: nil,
            rivalGuildID: nil,
            dungeonDepth: nil,
            isAvailable: true,
            timesCompleted: 0
        )
    }

    static func emergency(
        name: String,
        description: String,
        deadlineWeek: Int,
        reward: Int
    ) -> StandaloneQuest {
        StandaloneQuest(
            id: UUID(),
            name: name,
            description: description,
            standaloneType: .emergencyResponse,
            baseQuest: Quest.create(
                name: name,
                description: description,
                type: .combat,
                stakes: .high,
                storyPosition: .climax,
                baseGoldReward: reward
            ),
            bountyTarget: nil,
            patronID: nil,
            deadlineWeek: deadlineWeek,
            rivalGuildID: nil,
            dungeonDepth: nil,
            isAvailable: true,
            timesCompleted: 0
        )
    }

    static func dungeon(
        name: String,
        depth: Int,
        reward: Int
    ) -> StandaloneQuest {
        StandaloneQuest(
            id: UUID(),
            name: name,
            description: "Explore a dangerous dungeon with \(depth) levels",
            standaloneType: .dungeonExpedition,
            baseQuest: Quest.create(
                name: name,
                description: "Dungeon expedition",
                type: .exploration,
                stakes: depth > 5 ? .high : .medium,
                storyPosition: .prologue,
                baseGoldReward: reward
            ),
            bountyTarget: nil,
            patronID: nil,
            deadlineWeek: nil,
            rivalGuildID: nil,
            dungeonDepth: depth,
            isAvailable: true,
            timesCompleted: 0
        )
    }
}

/// Bounty target types
struct BountyTarget: Codable, Equatable {
    var name: String
    var type: BountyTargetType
    var threat: ThreatLevel
    var realm: Realm
    var region: String
    var baseReward: Int

    var displayName: String {
        "\(name) the \(type.displayName)"
    }

    var stakes: QuestStakes {
        switch threat {
        case .minor: return .low
        case .moderate: return .medium
        case .dangerous: return .high
        case .deadly: return .critical
        }
    }
}

enum BountyTargetType: String, Codable, CaseIterable {
    case banditLeader
    case monsterAlpha
    case undeadLord
    case cultLeader
    case rogueWizard
    case beastMaster
    case assassin
    case necromancer

    var displayName: String {
        switch self {
        case .banditLeader: return "Bandit Leader"
        case .monsterAlpha: return "Monster Alpha"
        case .undeadLord: return "Undead Lord"
        case .cultLeader: return "Cult Leader"
        case .rogueWizard: return "Rogue Wizard"
        case .beastMaster: return "Beast Master"
        case .assassin: return "Assassin"
        case .necromancer: return "Necromancer"
        }
    }
}

enum ThreatLevel: String, Codable, CaseIterable {
    case minor
    case moderate
    case dangerous
    case deadly

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var rewardMultiplier: Double {
        switch self {
        case .minor: return 0.5
        case .moderate: return 1.0
        case .dangerous: return 2.0
        case .deadly: return 4.0
        }
    }
}
