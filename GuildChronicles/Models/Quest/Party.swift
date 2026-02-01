//
//  Party.swift
//  GuildChronicles
//
//  Party composition and tactics (Section 3.4)
//

import Foundation

/// Party formation options (Section 3.4)
enum PartyFormation: String, Codable, CaseIterable {
    case standard           // 2 Front, 2 Middle, 2 Back
    case defensiveWall      // 4 Front, 2 Back
    case skirmishLine       // 3-3 Split
    case spearhead          // 1-2-3 Formation
    case protectiveCircle   // Surround formation
    case ambushFormation    // Stealth positions
    case rangedFocus        // 1 Front, 2 Middle, 3 Back
    case magicSupport       // 2 Front, 1 Middle, 3 Back

    var displayName: String {
        switch self {
        case .standard: return "Standard (2-2-2)"
        case .defensiveWall: return "Defensive Wall (4-0-2)"
        case .skirmishLine: return "Skirmish Line (3-3)"
        case .spearhead: return "Spearhead (1-2-3)"
        case .protectiveCircle: return "Protective Circle"
        case .ambushFormation: return "Ambush Formation"
        case .rangedFocus: return "Ranged Focus (1-2-3)"
        case .magicSupport: return "Magic Support (2-1-3)"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "Balanced formation for general encounters"
        case .defensiveWall:
            return "Maximum frontline protection for dangerous foes"
        case .skirmishLine:
            return "Flexible formation for mobile combat"
        case .spearhead:
            return "Aggressive breakthrough formation"
        case .protectiveCircle:
            return "Defensive formation protecting center"
        case .ambushFormation:
            return "Stealth positions for surprise attacks"
        case .rangedFocus:
            return "Maximizes ranged attackers' effectiveness"
        case .magicSupport:
            return "Protects spellcasters while they cast"
        }
    }

    var frontPositions: Int {
        switch self {
        case .standard: return 2
        case .defensiveWall: return 4
        case .skirmishLine: return 3
        case .spearhead: return 1
        case .protectiveCircle: return 3
        case .ambushFormation: return 2
        case .rangedFocus: return 1
        case .magicSupport: return 2
        }
    }

    var backPositions: Int {
        switch self {
        case .standard: return 2
        case .defensiveWall: return 2
        case .skirmishLine: return 3
        case .spearhead: return 3
        case .protectiveCircle: return 3
        case .ambushFormation: return 2
        case .rangedFocus: return 3
        case .magicSupport: return 3
        }
    }
}

/// Tactical settings (Section 3.4)
struct TacticalSettings: Codable, Equatable {
    var aggression: AggressionLevel
    var explorationStyle: ExplorationStyle
    var combatEngagement: CombatEngagement
    var resourceUsage: ResourceUsage
    var formationSpacing: FormationSpacing
    var trapDetection: TrapDetection
    var useStealth: Bool

    static var balanced: TacticalSettings {
        TacticalSettings(
            aggression: .normal,
            explorationStyle: .thorough,
            combatEngagement: .balanced,
            resourceUsage: .moderate,
            formationSpacing: .normal,
            trapDetection: .activeSearch,
            useStealth: false
        )
    }

    static var cautious: TacticalSettings {
        TacticalSettings(
            aggression: .veryCautious,
            explorationStyle: .thorough,
            combatEngagement: .avoid,
            resourceUsage: .conservative,
            formationSpacing: .tight,
            trapDetection: .activeSearch,
            useStealth: true
        )
    }

    static var aggressive: TacticalSettings {
        TacticalSettings(
            aggression: .veryAggressive,
            explorationStyle: .speedRun,
            combatEngagement: .seek,
            resourceUsage: .liberal,
            formationSpacing: .spread,
            trapDetection: .passive,
            useStealth: false
        )
    }
}

enum AggressionLevel: String, Codable, CaseIterable {
    case veryCautious
    case cautious
    case normal
    case aggressive
    case veryAggressive

    var displayName: String {
        switch self {
        case .veryCautious: return "Very Cautious"
        case .cautious: return "Cautious"
        case .normal: return "Normal"
        case .aggressive: return "Aggressive"
        case .veryAggressive: return "Very Aggressive"
        }
    }

    var combatBonusMultiplier: Double {
        switch self {
        case .veryCautious: return 0.8
        case .cautious: return 0.9
        case .normal: return 1.0
        case .aggressive: return 1.1
        case .veryAggressive: return 1.2
        }
    }

    var injuryRiskMultiplier: Double {
        switch self {
        case .veryCautious: return 0.6
        case .cautious: return 0.8
        case .normal: return 1.0
        case .aggressive: return 1.3
        case .veryAggressive: return 1.6
        }
    }
}

enum ExplorationStyle: String, Codable, CaseIterable {
    case thorough
    case balanced
    case speedRun

    var displayName: String {
        switch self {
        case .thorough: return "Thorough"
        case .balanced: return "Balanced"
        case .speedRun: return "Speed Run"
        }
    }

    var lootFindMultiplier: Double {
        switch self {
        case .thorough: return 1.5
        case .balanced: return 1.0
        case .speedRun: return 0.5
        }
    }

    var timeMultiplier: Double {
        switch self {
        case .thorough: return 1.5
        case .balanced: return 1.0
        case .speedRun: return 0.6
        }
    }
}

enum CombatEngagement: String, Codable, CaseIterable {
    case avoid
    case defensive
    case balanced
    case offensive
    case seek

    var displayName: String {
        switch self {
        case .avoid: return "Avoid Combat"
        case .defensive: return "Defensive"
        case .balanced: return "Balanced"
        case .offensive: return "Offensive"
        case .seek: return "Seek Combat"
        }
    }
}

enum ResourceUsage: String, Codable, CaseIterable {
    case conservative
    case moderate
    case liberal

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var potionUsageThreshold: Double {
        switch self {
        case .conservative: return 0.3  // Use when at 30% health
        case .moderate: return 0.5
        case .liberal: return 0.7
        }
    }
}

enum FormationSpacing: String, Codable, CaseIterable {
    case tight
    case normal
    case spread

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var aoeVulnerability: Double {
        switch self {
        case .tight: return 1.5  // More vulnerable to area attacks
        case .normal: return 1.0
        case .spread: return 0.6
        }
    }
}

enum TrapDetection: String, Codable, CaseIterable {
    case passive
    case activeSearch

    var displayName: String {
        switch self {
        case .passive: return "Passive Detection"
        case .activeSearch: return "Active Search"
        }
    }

    var detectionBonus: Int {
        switch self {
        case .passive: return 0
        case .activeSearch: return 5
        }
    }

    var timeMultiplier: Double {
        switch self {
        case .passive: return 1.0
        case .activeSearch: return 1.3
        }
    }
}

/// Individual adventurer instructions within party
struct AdventurerInstructions: Codable, Equatable {
    var adventurerID: UUID
    var role: PartyRole
    var position: PartyPosition
    var targetPriority: TargetPriority
    var abilityUsage: AbilityUsage
    var retreatCondition: RetreatCondition
}

enum PartyRole: String, Codable, CaseIterable {
    case tank
    case damage
    case healer
    case support
    case scout

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

enum PartyPosition: String, Codable, CaseIterable {
    case front
    case middle
    case back

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

enum TargetPriority: String, Codable, CaseIterable {
    case weakest
    case strongest
    case casters
    case nearest
    case leader

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

enum AbilityUsage: String, Codable, CaseIterable {
    case conserve
    case balanced
    case aggressive

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

enum RetreatCondition: String, Codable, CaseIterable {
    case never
    case critical      // Below 20% health
    case wounded       // Below 50% health
    case partyFailing  // Party taking heavy losses

    var displayName: String {
        switch self {
        case .never: return "Never Retreat"
        case .critical: return "When Critical"
        case .wounded: return "When Wounded"
        case .partyFailing: return "When Party Failing"
        }
    }
}

/// A configured party for a quest
struct QuestParty: Codable, Equatable {
    var adventurerIDs: [UUID]
    var formation: PartyFormation
    var tactics: TacticalSettings
    var instructions: [AdventurerInstructions]
    var leaderID: UUID?

    var size: Int {
        adventurerIDs.count
    }

    var hasLeader: Bool {
        leaderID != nil
    }

    static func create(adventurerIDs: [UUID]) -> QuestParty {
        QuestParty(
            adventurerIDs: adventurerIDs,
            formation: .standard,
            tactics: .balanced,
            instructions: adventurerIDs.map { id in
                AdventurerInstructions(
                    adventurerID: id,
                    role: .damage,
                    position: .middle,
                    targetPriority: .nearest,
                    abilityUsage: .balanced,
                    retreatCondition: .critical
                )
            },
            leaderID: adventurerIDs.first
        )
    }
}
