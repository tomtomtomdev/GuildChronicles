//
//  AttributeType.swift
//  GuildChronicles
//
//  All adventurer attributes (Section 3.1)
//

import Foundation

/// All attribute types categorized as per spec Section 3.1
enum AttributeType: String, Codable, CaseIterable, Identifiable {
    // MARK: - Combat Attributes
    case meleeCombat
    case rangedCombat
    case spellcasting
    case defense
    case parrying
    case criticalStrikes
    case initiative
    case dualWielding
    case shieldMastery
    case armorProficiency
    case weaponSpecialization
    case battleTactics
    case mountedCombat
    case unarmedCombat

    // MARK: - Mental Attributes
    case wisdom
    case perception
    case willpower
    case creativity
    case decisionMaking
    case determination
    case cunning
    case leadership
    case awareness
    case tacticalSense
    case teamwork
    case morale

    // MARK: - Physical Attributes
    case strength
    case dexterity
    case constitution
    case agility
    case endurance
    case speed
    case stamina
    case fortitude

    // MARK: - Spellcaster Attributes
    case arcanePower
    case divineConnection
    case spellResistance
    case manaPool
    case channeling
    case ritualCasting
    case counterspelling
    case spellRecovery
    case concentration
    case wildMagicAffinity

    // MARK: - Hidden Attributes
    case consistency
    case clutchPerformance
    case injuryProneness
    case classVersatility
    case realmAdaptability
    case ambition
    case guildLoyalty
    case pressureHandling
    case professionalism
    case honorCode
    case temperament
    case greedFactor

    // For racial charisma modifier
    case charisma

    var id: String { rawValue }

    var displayName: String {
        // Convert camelCase to Title Case
        let result = rawValue.unicodeScalars.reduce("") { result, scalar in
            if CharacterSet.uppercaseLetters.contains(scalar) {
                return result + " " + String(scalar)
            }
            return result + String(scalar)
        }
        return result.prefix(1).uppercased() + result.dropFirst()
    }

    var category: AttributeCategory {
        switch self {
        case .meleeCombat, .rangedCombat, .spellcasting, .defense, .parrying,
             .criticalStrikes, .initiative, .dualWielding, .shieldMastery,
             .armorProficiency, .weaponSpecialization, .battleTactics,
             .mountedCombat, .unarmedCombat:
            return .combat

        case .wisdom, .perception, .willpower, .creativity, .decisionMaking,
             .determination, .cunning, .leadership, .awareness, .tacticalSense,
             .teamwork, .morale:
            return .mental

        case .strength, .dexterity, .constitution, .agility, .endurance,
             .speed, .stamina, .fortitude, .charisma:
            return .physical

        case .arcanePower, .divineConnection, .spellResistance, .manaPool,
             .channeling, .ritualCasting, .counterspelling, .spellRecovery,
             .concentration, .wildMagicAffinity:
            return .spellcaster

        case .consistency, .clutchPerformance, .injuryProneness, .classVersatility,
             .realmAdaptability, .ambition, .guildLoyalty, .pressureHandling,
             .professionalism, .honorCode, .temperament, .greedFactor:
            return .hidden
        }
    }

    var isHidden: Bool {
        category == .hidden
    }
}

enum AttributeCategory: String, Codable, CaseIterable {
    case combat
    case mental
    case physical
    case spellcaster
    case hidden

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}
