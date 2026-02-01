//
//  AdventurerRace.swift
//  GuildChronicles
//
//  Core races with attribute modifiers (Section 19.2)
//

import Foundation

enum AdventurerRace: String, Codable, CaseIterable, Identifiable {
    case human
    case elf
    case dwarf
    case halfling
    case halfOrc
    case tiefling
    case dragonborn

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .human: return "Human"
        case .elf: return "Elf"
        case .dwarf: return "Dwarf"
        case .halfling: return "Halfling"
        case .halfOrc: return "Half-Orc"
        case .tiefling: return "Tiefling"
        case .dragonborn: return "Dragonborn"
        }
    }

    /// Attribute modifiers for each race (base adjustment to 1-20 scale)
    var attributeModifiers: RaceAttributeModifiers {
        switch self {
        case .human:
            return RaceAttributeModifiers(
                strength: 0, dexterity: 0, constitution: 0,
                wisdom: 0, charisma: 0,
                special: .versatile
            )
        case .elf:
            return RaceAttributeModifiers(
                strength: -1, dexterity: 2, constitution: -1,
                wisdom: 1, charisma: 0,
                special: .darkvision
            )
        case .dwarf:
            return RaceAttributeModifiers(
                strength: 0, dexterity: -1, constitution: 2,
                wisdom: 0, charisma: -1,
                special: .poisonResistance
            )
        case .halfling:
            return RaceAttributeModifiers(
                strength: -2, dexterity: 2, constitution: 0,
                wisdom: 0, charisma: 1,
                special: .lucky
            )
        case .halfOrc:
            return RaceAttributeModifiers(
                strength: 2, dexterity: 0, constitution: 1,
                wisdom: -1, charisma: -2,
                special: .relentless
            )
        case .tiefling:
            return RaceAttributeModifiers(
                strength: 0, dexterity: 0, constitution: 0,
                wisdom: 0, charisma: 2,
                special: .fireResistance
            )
        case .dragonborn:
            return RaceAttributeModifiers(
                strength: 2, dexterity: 0, constitution: 0,
                wisdom: 0, charisma: 1,
                special: .breathWeapon
            )
        }
    }
}

struct RaceAttributeModifiers: Codable {
    let strength: Int
    let dexterity: Int
    let constitution: Int
    let wisdom: Int
    let charisma: Int
    let special: RacialSpecial
}

enum RacialSpecial: String, Codable {
    case versatile       // Human: Bonus feat/skill
    case darkvision      // Elf: See in darkness
    case poisonResistance // Dwarf: Resist poison
    case lucky           // Halfling: Reroll natural 1s
    case relentless      // Half-Orc: Stay at 1 HP once per quest
    case fireResistance  // Tiefling: Resist fire damage
    case breathWeapon    // Dragonborn: Elemental breath attack
}
