//
//  QuestEvent.swift
//  GuildChronicles
//
//  Quest events during simulation (Section 3.3)
//

import Foundation

/// Types of events that can occur during a quest (Section 3.3)
enum QuestEventType: String, Codable, CaseIterable {
    // Combat
    case combatMinor
    case combatMajor
    case combatBoss
    case ambush

    // Hazards
    case trap
    case environmentalHazard
    case poisonGas
    case collapsing

    // Puzzles
    case puzzle
    case riddle
    case magicalBarrier

    // Social
    case negotiation
    case intimidation
    case persuasion
    case deception

    // Discovery
    case treasureDiscovery
    case secretPassage
    case loreDiscovery
    case artifactFound

    // Random
    case randomEncounter
    case divineIntervention
    case partyConflict
    case moralDilemma

    // Challenges
    case skillCheck
    case enduranceCheck
    case magicChallenge

    var displayName: String {
        switch self {
        case .combatMinor: return "Minor Combat"
        case .combatMajor: return "Major Combat"
        case .combatBoss: return "Boss Fight"
        case .ambush: return "Ambush"
        case .trap: return "Trap"
        case .environmentalHazard: return "Environmental Hazard"
        case .poisonGas: return "Poison Gas"
        case .collapsing: return "Collapsing Structure"
        case .puzzle: return "Puzzle"
        case .riddle: return "Riddle"
        case .magicalBarrier: return "Magical Barrier"
        case .negotiation: return "Negotiation"
        case .intimidation: return "Intimidation"
        case .persuasion: return "Persuasion"
        case .deception: return "Deception"
        case .treasureDiscovery: return "Treasure Discovery"
        case .secretPassage: return "Secret Passage"
        case .loreDiscovery: return "Lore Discovery"
        case .artifactFound: return "Artifact Found"
        case .randomEncounter: return "Random Encounter"
        case .divineIntervention: return "Divine Intervention"
        case .partyConflict: return "Party Conflict"
        case .moralDilemma: return "Moral Dilemma"
        case .skillCheck: return "Skill Check"
        case .enduranceCheck: return "Endurance Check"
        case .magicChallenge: return "Magic Challenge"
        }
    }

    var category: QuestEventCategory {
        switch self {
        case .combatMinor, .combatMajor, .combatBoss, .ambush:
            return .combat
        case .trap, .environmentalHazard, .poisonGas, .collapsing:
            return .hazard
        case .puzzle, .riddle, .magicalBarrier:
            return .puzzle
        case .negotiation, .intimidation, .persuasion, .deception:
            return .social
        case .treasureDiscovery, .secretPassage, .loreDiscovery, .artifactFound:
            return .discovery
        case .randomEncounter, .divineIntervention, .partyConflict, .moralDilemma:
            return .random
        case .skillCheck, .enduranceCheck, .magicChallenge:
            return .challenge
        }
    }

    /// Primary attributes for success
    var primaryAttributes: [AttributeType] {
        switch self {
        case .combatMinor, .combatMajor:
            return [.meleeCombat, .rangedCombat, .defense]
        case .combatBoss:
            return [.meleeCombat, .battleTactics, .clutchPerformance]
        case .ambush:
            return [.initiative, .awareness, .perception]
        case .trap:
            return [.perception, .dexterity, .awareness]
        case .environmentalHazard:
            return [.endurance, .constitution, .fortitude]
        case .poisonGas:
            return [.constitution, .fortitude, .endurance]
        case .collapsing:
            return [.speed, .agility, .perception]
        case .puzzle:
            return [.wisdom, .creativity, .perception]
        case .riddle:
            return [.wisdom, .cunning, .creativity]
        case .magicalBarrier:
            return [.arcanePower, .counterspelling, .manaPool]
        case .negotiation:
            return [.charisma, .wisdom, .perception]
        case .intimidation:
            return [.strength, .charisma, .willpower]
        case .persuasion:
            return [.charisma, .cunning, .creativity]
        case .deception:
            return [.cunning, .charisma, .perception]
        case .treasureDiscovery:
            return [.perception, .awareness, .cunning]
        case .secretPassage:
            return [.perception, .awareness, .wisdom]
        case .loreDiscovery:
            return [.wisdom, .perception, .creativity]
        case .artifactFound:
            return [.arcanePower, .wisdom, .perception]
        case .randomEncounter:
            return [.awareness, .perception, .initiative]
        case .divineIntervention:
            return [.divineConnection, .willpower, .morale]
        case .partyConflict:
            return [.leadership, .teamwork, .charisma]
        case .moralDilemma:
            return [.wisdom, .honorCode, .willpower]
        case .skillCheck:
            return [.dexterity, .wisdom, .concentration]
        case .enduranceCheck:
            return [.endurance, .stamina, .constitution]
        case .magicChallenge:
            return [.arcanePower, .spellcasting, .manaPool]
        }
    }

    /// Base difficulty (1-20)
    var baseDifficulty: Int {
        switch self {
        case .combatMinor, .trap, .skillCheck: return 8
        case .combatMajor, .puzzle, .negotiation: return 12
        case .combatBoss, .magicalBarrier: return 16
        case .ambush, .environmentalHazard, .riddle: return 10
        case .moralDilemma, .partyConflict, .divineIntervention: return 14
        default: return 10
        }
    }

    /// Can this event cause injury?
    var canCauseInjury: Bool {
        switch category {
        case .combat, .hazard:
            return true
        default:
            return false
        }
    }
}

enum QuestEventCategory: String, Codable {
    case combat
    case hazard
    case puzzle
    case social
    case discovery
    case random
    case challenge
}

/// An event that occurs during quest simulation
struct QuestEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var type: QuestEventType
    var segmentIndex: Int
    var description: String
    var difficulty: Int
    var wasSuccessful: Bool?
    var participantIDs: [UUID]  // Adventurers involved
    var outcome: QuestEventOutcome?
}

/// Outcome of a quest event
struct QuestEventOutcome: Codable, Equatable {
    var success: Bool
    var description: String
    var goldFound: Int
    var experienceGained: Int
    var injuredAdventurerIDs: [UUID]
    var itemsFound: [UUID]
    var attributeChecks: [AttributeCheck]
}

/// A single attribute check during an event
struct AttributeCheck: Codable, Equatable {
    var adventurerID: UUID
    var attribute: AttributeType
    var targetValue: Int
    var rolledValue: Int  // d20 + attribute modifier
    var success: Bool
}

/// Quest segment - one portion of a quest
struct QuestSegment: Identifiable, Codable, Equatable {
    let id: UUID
    var index: Int
    var description: String
    var events: [QuestEvent]
    var isCompleted: Bool
    var narrationText: String
}

/// A full quest simulation log
struct QuestLog: Codable, Equatable {
    var questID: UUID
    var startWeek: Int
    var endWeek: Int
    var segments: [QuestSegment]
    var partyIDs: [UUID]
    var totalGoldFound: Int
    var totalExperienceGained: Int
    var outcome: QuestOutcome
    var chroniclerNotes: String

    var eventCount: Int {
        segments.reduce(0) { $0 + $1.events.count }
    }

    var successfulEventCount: Int {
        segments.reduce(0) { total, segment in
            total + segment.events.filter { $0.wasSuccessful == true }.count
        }
    }
}
