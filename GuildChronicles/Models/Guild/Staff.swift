//
//  Staff.swift
//  GuildChronicles
//
//  Guild staff members (Section 3.8)
//

import Foundation

/// Types of staff that can be hired by a guild
enum StaffRole: String, Codable, CaseIterable, Identifiable {
    case secondInCommand
    case combatInstructor
    case magicInstructor
    case healerOnRetainer
    case scoutMaster
    case apprenticeMaster
    case quartermaster
    case chronicler

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .secondInCommand: return "Second-in-Command"
        case .combatInstructor: return "Combat Instructor"
        case .magicInstructor: return "Magic Instructor"
        case .healerOnRetainer: return "Healer on Retainer"
        case .scoutMaster: return "Scout Master"
        case .apprenticeMaster: return "Apprentice Master"
        case .quartermaster: return "Quartermaster"
        case .chronicler: return "Chronicler"
        }
    }

    var description: String {
        switch self {
        case .secondInCommand:
            return "Manages daily operations and can act in your absence"
        case .combatInstructor:
            return "Trains adventurers in martial combat skills"
        case .magicInstructor:
            return "Trains adventurers in spellcasting and arcane arts"
        case .healerOnRetainer:
            return "Provides healing services and reduces recovery time"
        case .scoutMaster:
            return "Leads intelligence network and recruitment scouting"
        case .apprenticeMaster:
            return "Develops apprentices into journeyman adventurers"
        case .quartermaster:
            return "Manages equipment, supplies, and logistics"
        case .chronicler:
            return "Records guild history and manages reputation"
        }
    }

    var baseWeeklySalary: Int {
        switch self {
        case .secondInCommand: return 200
        case .combatInstructor: return 100
        case .magicInstructor: return 120
        case .healerOnRetainer: return 150
        case .scoutMaster: return 80
        case .apprenticeMaster: return 90
        case .quartermaster: return 70
        case .chronicler: return 60
        }
    }

    /// Whether multiple staff of this role can be hired
    var allowsMultiple: Bool {
        switch self {
        case .secondInCommand, .quartermaster, .chronicler:
            return false
        case .combatInstructor, .magicInstructor, .healerOnRetainer,
             .scoutMaster, .apprenticeMaster:
            return true
        }
    }
}

/// Specialization for combat instructors
enum CombatSpecialization: String, Codable, CaseIterable {
    case melee
    case ranged
    case defense
    case tactics
    case dualWield
    case mounted

    var displayName: String {
        switch self {
        case .melee: return "Melee Combat"
        case .ranged: return "Ranged Combat"
        case .defense: return "Defensive Techniques"
        case .tactics: return "Battle Tactics"
        case .dualWield: return "Dual Wielding"
        case .mounted: return "Mounted Combat"
        }
    }

    var trainedAttributes: [AttributeType] {
        switch self {
        case .melee: return [.meleeCombat, .strength, .weaponSpecialization]
        case .ranged: return [.rangedCombat, .dexterity, .perception]
        case .defense: return [.defense, .parrying, .shieldMastery, .armorProficiency]
        case .tactics: return [.battleTactics, .tacticalSense, .leadership]
        case .dualWield: return [.dualWielding, .agility, .initiative]
        case .mounted: return [.mountedCombat, .speed, .endurance]
        }
    }
}

/// Specialization for magic instructors
enum MagicSpecialization: String, Codable, CaseIterable {
    case arcane
    case divine
    case ritual
    case combat
    case defense

    var displayName: String {
        switch self {
        case .arcane: return "Arcane Magic"
        case .divine: return "Divine Magic"
        case .ritual: return "Ritual Casting"
        case .combat: return "Combat Spellcasting"
        case .defense: return "Magical Defense"
        }
    }

    var trainedAttributes: [AttributeType] {
        switch self {
        case .arcane: return [.arcanePower, .manaPool, .wildMagicAffinity]
        case .divine: return [.divineConnection, .channeling, .willpower]
        case .ritual: return [.ritualCasting, .concentration, .wisdom]
        case .combat: return [.spellcasting, .initiative, .criticalStrikes]
        case .defense: return [.spellResistance, .counterspelling, .fortitude]
        }
    }
}

/// A staff member employed by the guild
struct StaffMember: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var role: StaffRole
    var skillLevel: Int  // 1-20, affects training effectiveness
    var weeklySalary: Int
    var combatSpecialization: CombatSpecialization?
    var magicSpecialization: MagicSpecialization?
    var assignedRegion: Realm?  // For scouts
    var hiredDate: Int  // Week number when hired
    var morale: Int  // 1-100

    var isSpecialized: Bool {
        combatSpecialization != nil || magicSpecialization != nil
    }

    /// Training effectiveness multiplier based on skill level
    var trainingEffectiveness: Double {
        Double(skillLevel) / 20.0
    }

    static func random(role: StaffRole, skillLevel: Int? = nil) -> StaffMember {
        let level = skillLevel ?? Int.random(in: 8...16)
        let salaryVariance = Int.random(in: -20...20)

        return StaffMember(
            id: UUID(),
            name: StaffNameGenerator.generate(for: role),
            role: role,
            skillLevel: level,
            weeklySalary: role.baseWeeklySalary + salaryVariance,
            combatSpecialization: role == .combatInstructor ? CombatSpecialization.allCases.randomElement() : nil,
            magicSpecialization: role == .magicInstructor ? MagicSpecialization.allCases.randomElement() : nil,
            assignedRegion: nil,
            hiredDate: 0,
            morale: Int.random(in: 60...90)
        )
    }
}

/// Simple name generator for staff
struct StaffNameGenerator {
    static func generate(for role: StaffRole) -> String {
        let firstNames = ["Aldric", "Beatrix", "Conrad", "Diana", "Edmund", "Fiona",
                          "Gerald", "Helena", "Ivan", "Julia", "Klaus", "Lydia",
                          "Magnus", "Nora", "Otto", "Petra", "Quentin", "Rosa"]
        let lastNames = ["Ashford", "Blackwell", "Crawford", "Dunmore", "Everhart",
                         "Fletcher", "Grimshaw", "Holloway", "Ironside", "Jarvis",
                         "Kincaid", "Langley", "Montague", "Northwood", "Oakley"]

        let first = firstNames.randomElement()!
        let last = lastNames.randomElement()!
        return "\(first) \(last)"
    }
}
