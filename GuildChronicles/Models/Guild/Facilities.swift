//
//  Facilities.swift
//  GuildChronicles
//
//  Guild facilities and their ratings (Section 3.8)
//

import Foundation

/// Quality rating for facilities (Section 3.8)
enum FacilityRating: Int, Codable, CaseIterable, Comparable {
    case ramshackle = 1
    case poor = 2
    case adequate = 3
    case good = 4
    case excellent = 5
    case masterwork = 6
    case legendary = 7

    var displayName: String {
        switch self {
        case .ramshackle: return "Ramshackle"
        case .poor: return "Poor"
        case .adequate: return "Adequate"
        case .good: return "Good"
        case .excellent: return "Excellent"
        case .masterwork: return "Masterwork"
        case .legendary: return "Legendary"
        }
    }

    /// Effectiveness multiplier for facility operations
    var effectivenessMultiplier: Double {
        switch self {
        case .ramshackle: return 0.5
        case .poor: return 0.7
        case .adequate: return 1.0
        case .good: return 1.2
        case .excellent: return 1.4
        case .masterwork: return 1.6
        case .legendary: return 2.0
        }
    }

    /// Weekly maintenance cost multiplier
    var maintenanceCostMultiplier: Double {
        Double(rawValue) * 0.5
    }

    /// Cost to upgrade to this level
    var upgradeCost: Int {
        switch self {
        case .ramshackle: return 0
        case .poor: return 500
        case .adequate: return 2000
        case .good: return 8000
        case .excellent: return 25000
        case .masterwork: return 75000
        case .legendary: return 200000
        }
    }

    static func < (lhs: FacilityRating, rhs: FacilityRating) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Types of facilities a guild can have
enum FacilityType: String, Codable, CaseIterable, Identifiable {
    case guildHall
    case trainingGrounds
    case apprenticeAcademy
    case armory
    case library
    case temple
    case tavern

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .guildHall: return "Guild Hall"
        case .trainingGrounds: return "Training Grounds"
        case .apprenticeAcademy: return "Apprentice Academy"
        case .armory: return "Armory"
        case .library: return "Library & Research"
        case .temple: return "Temple/Shrine"
        case .tavern: return "Guild Tavern"
        }
    }

    var description: String {
        switch self {
        case .guildHall:
            return "Main headquarters determining roster capacity and prestige"
        case .trainingGrounds:
            return "Combat and physical training facility"
        case .apprenticeAcademy:
            return "Develops young apprentices into skilled adventurers"
        case .armory:
            return "Equipment storage and maintenance facility"
        case .library:
            return "Research facility for quest intelligence and lore"
        case .temple:
            return "Healing facility reducing injury recovery time"
        case .tavern:
            return "Generates income and improves adventurer morale"
        }
    }

    var baseMaintenanceCost: Int {
        switch self {
        case .guildHall: return 100
        case .trainingGrounds: return 50
        case .apprenticeAcademy: return 40
        case .armory: return 30
        case .library: return 25
        case .temple: return 60
        case .tavern: return 20
        }
    }
}

/// A single facility with its rating
struct Facility: Codable, Equatable {
    var type: FacilityType
    var rating: FacilityRating
    var condition: Int  // 0-100, degrades over time without maintenance
    var lastUpgraded: Int  // Week number

    var weeklyMaintenanceCost: Int {
        Int(Double(type.baseMaintenanceCost) * rating.maintenanceCostMultiplier)
    }

    var needsRepair: Bool {
        condition < 50
    }

    var effectiveRating: FacilityRating {
        // Poor condition reduces effective rating
        if condition < 25 {
            return FacilityRating(rawValue: max(1, rating.rawValue - 2)) ?? .ramshackle
        } else if condition < 50 {
            return FacilityRating(rawValue: max(1, rating.rawValue - 1)) ?? .ramshackle
        }
        return rating
    }

    static func basic(_ type: FacilityType) -> Facility {
        Facility(
            type: type,
            rating: .adequate,
            condition: 100,
            lastUpgraded: 0
        )
    }
}

/// All facilities owned by a guild
struct GuildFacilities: Codable, Equatable {
    var guildHall: Facility
    var trainingGrounds: Facility
    var apprenticeAcademy: Facility
    var armory: Facility
    var library: Facility
    var temple: Facility
    var tavern: Facility

    var totalWeeklyMaintenance: Int {
        guildHall.weeklyMaintenanceCost +
        trainingGrounds.weeklyMaintenanceCost +
        apprenticeAcademy.weeklyMaintenanceCost +
        armory.weeklyMaintenanceCost +
        library.weeklyMaintenanceCost +
        temple.weeklyMaintenanceCost +
        tavern.weeklyMaintenanceCost
    }

    var allFacilities: [Facility] {
        [guildHall, trainingGrounds, apprenticeAcademy, armory, library, temple, tavern]
    }

    var facilitiesNeedingRepair: [Facility] {
        allFacilities.filter { $0.needsRepair }
    }

    /// Roster capacity based on guild hall rating
    var rosterCapacity: Int {
        switch guildHall.effectiveRating {
        case .ramshackle: return 8
        case .poor: return 12
        case .adequate: return 16
        case .good: return 22
        case .excellent: return 28
        case .masterwork: return 36
        case .legendary: return 50
        }
    }

    /// Training effectiveness based on training grounds
    var trainingBonus: Double {
        trainingGrounds.effectiveRating.effectivenessMultiplier
    }

    /// Recovery time reduction based on temple
    var healingBonus: Double {
        temple.effectiveRating.effectivenessMultiplier
    }

    /// Weekly tavern income
    var tavernIncome: Int {
        Int(50.0 * tavern.effectiveRating.effectivenessMultiplier)
    }

    static var starter: GuildFacilities {
        GuildFacilities(
            guildHall: .basic(.guildHall),
            trainingGrounds: Facility(type: .trainingGrounds, rating: .poor, condition: 80, lastUpgraded: 0),
            apprenticeAcademy: Facility(type: .apprenticeAcademy, rating: .poor, condition: 75, lastUpgraded: 0),
            armory: .basic(.armory),
            library: Facility(type: .library, rating: .poor, condition: 70, lastUpgraded: 0),
            temple: .basic(.temple),
            tavern: .basic(.tavern)
        )
    }
}
