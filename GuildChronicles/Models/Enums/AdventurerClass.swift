//
//  AdventurerClass.swift
//  GuildChronicles
//
//  Adventurer classes (Section 19.1)
//

import Foundation

enum AdventurerClass: String, Codable, CaseIterable, Identifiable {
    // Martial Classes
    case fighter
    case barbarian
    case paladin
    case ranger
    case monk
    case rogue

    // Spellcasting Classes
    case wizard
    case sorcerer
    case cleric
    case druid
    case warlock
    case bard

    // Hybrid Classes
    case artificer
    case eldritchKnight
    case arcaneTrickster

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fighter: return "Fighter"
        case .barbarian: return "Barbarian"
        case .paladin: return "Paladin"
        case .ranger: return "Ranger"
        case .monk: return "Monk"
        case .rogue: return "Rogue"
        case .wizard: return "Wizard"
        case .sorcerer: return "Sorcerer"
        case .cleric: return "Cleric"
        case .druid: return "Druid"
        case .warlock: return "Warlock"
        case .bard: return "Bard"
        case .artificer: return "Artificer"
        case .eldritchKnight: return "Eldritch Knight"
        case .arcaneTrickster: return "Arcane Trickster"
        }
    }

    var category: ClassCategory {
        switch self {
        case .fighter, .barbarian, .paladin, .ranger, .monk, .rogue:
            return .martial
        case .wizard, .sorcerer, .cleric, .druid, .warlock, .bard:
            return .spellcasting
        case .artificer, .eldritchKnight, .arcaneTrickster:
            return .hybrid
        }
    }

    var isSpellcaster: Bool {
        category == .spellcasting || category == .hybrid
    }

    /// Primary attributes for this class
    var primaryAttributes: [AttributeType] {
        switch self {
        case .fighter:
            return [.strength, .constitution, .meleeCombat]
        case .barbarian:
            return [.strength, .constitution, .endurance]
        case .paladin:
            return [.strength, .charisma, .divineConnection]
        case .ranger:
            return [.dexterity, .wisdom, .rangedCombat]
        case .monk:
            return [.dexterity, .wisdom, .unarmedCombat]
        case .rogue:
            return [.dexterity, .cunning, .perception]
        case .wizard:
            return [.wisdom, .arcanePower, .manaPool]
        case .sorcerer:
            return [.charisma, .arcanePower, .wildMagicAffinity]
        case .cleric:
            return [.wisdom, .divineConnection, .channeling]
        case .druid:
            return [.wisdom, .divineConnection, .constitution]
        case .warlock:
            return [.charisma, .arcanePower, .willpower]
        case .bard:
            return [.charisma, .creativity, .leadership]
        case .artificer:
            return [.wisdom, .creativity, .arcanePower]
        case .eldritchKnight:
            return [.strength, .wisdom, .meleeCombat]
        case .arcaneTrickster:
            return [.dexterity, .wisdom, .cunning]
        }
    }
}

enum ClassCategory: String, Codable {
    case martial
    case spellcasting
    case hybrid
}
