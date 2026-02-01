//
//  Adventurer.swift
//  GuildChronicles
//
//  Core adventurer model (Sections 3.1, 6.4, 18, 19)
//

import Foundation

struct Adventurer: Identifiable, Codable, Equatable {
    let id: UUID
    var firstName: String
    var lastName: String
    var race: AdventurerRace
    var primaryClass: AdventurerClass
    var secondaryClass: AdventurerClass?
    var level: AdventurerLevel
    var age: Int
    var homeRealm: Realm

    // Core attributes
    var attributes: AdventurerAttributes

    // Contract & Status
    var contractStatus: ContractStatus
    var currentGuildID: UUID?
    var weeklyWage: Int
    var lootSharePercent: Double

    // Career Statistics (Section 6.4)
    var statistics: AdventurerStatistics

    // Current State
    var currentCondition: AdventurerCondition
    var injuries: [Injury]

    // Visibility (Section 3.2 - Attribute Masking)
    var isFullyKnown: Bool

    // MARK: - Computed Properties

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var classDescription: String {
        if let secondary = secondaryClass {
            return "\(primaryClass.displayName)/\(secondary.displayName)"
        }
        return primaryClass.displayName
    }

    var isInjured: Bool {
        !injuries.isEmpty
    }

    var isAvailableForQuests: Bool {
        currentCondition == .healthy && !isInjured
    }

    /// Estimated market value based on attributes and level
    var estimatedValue: Int {
        let baseValue = Int(attributes.overallAverage * 1000)
        let levelMultiplier: Double = {
            switch level {
            case .apprentice: return 0.3
            case .journeyman: return 0.6
            case .adept: return 1.0
            case .expert: return 1.5
            case .master: return 2.5
            case .grandmaster: return 4.0
            case .legendary: return 7.0
            }
        }()
        return Int(Double(baseValue) * levelMultiplier)
    }

    // MARK: - Factory

    static func random(
        level: AdventurerLevel = .journeyman,
        race: AdventurerRace? = nil,
        primaryClass: AdventurerClass? = nil,
        homeRealm: Realm? = nil
    ) -> Adventurer {
        var rng: RandomNumberGenerator = SystemRandomNumberGenerator()
        return random(level: level, race: race, primaryClass: primaryClass, homeRealm: homeRealm, using: &rng)
    }

    static func random(
        level: AdventurerLevel = .journeyman,
        race: AdventurerRace? = nil,
        primaryClass: AdventurerClass? = nil,
        homeRealm: Realm? = nil,
        using rng: inout RandomNumberGenerator
    ) -> Adventurer {
        let chosenRace = race ?? AdventurerRace.allCases.randomElement(using: &rng)!
        let chosenClass = primaryClass ?? AdventurerClass.allCases.randomElement(using: &rng)!
        let chosenRealm = homeRealm ?? Realm.allCases.randomElement(using: &rng)!

        let names = NameGenerator.generate(for: chosenRace, using: &rng)
        let age = Int.random(in: chosenRace.ageRange, using: &rng)

        let attributes = AdventurerAttributes.random(
            forClass: chosenClass,
            race: chosenRace,
            level: level,
            using: &rng
        )

        let baseWage = level.baseWeeklyWage
        let wageVariance = Int.random(in: -baseWage/4...baseWage/4, using: &rng)

        return Adventurer(
            id: UUID(),
            firstName: names.first,
            lastName: names.last,
            race: chosenRace,
            primaryClass: chosenClass,
            secondaryClass: nil,
            level: level,
            age: age,
            homeRealm: chosenRealm,
            attributes: attributes,
            contractStatus: .freeAgent,
            currentGuildID: nil,
            weeklyWage: baseWage + wageVariance,
            lootSharePercent: 0.05,
            statistics: AdventurerStatistics(),
            currentCondition: .healthy,
            injuries: [],
            isFullyKnown: false
        )
    }
}

// MARK: - Supporting Types

enum ContractStatus: String, Codable {
    case freeAgent
    case underContract
    case onLoan
    case retiring
}

enum AdventurerCondition: String, Codable, CaseIterable {
    case healthy
    case fatigued
    case recovering
    case injured
    case cursed
    case deceased
}

struct AdventurerStatistics: Codable, Equatable {
    var questsCompleted: Int = 0
    var questsFailed: Int = 0
    var monstersSlain: Int = 0
    var treasureValueAcquired: Int = 0
    var dungeonsCleared: Int = 0
    var injuriesSustained: Int = 0
    var deathsSurvived: Int = 0  // Resurrections
    var totalPerformanceRatings: Double = 0.0
    var performanceRatingCount: Int = 0

    /// Average performance rating (1-10 scale, 2 decimal places)
    var averagePerformanceRating: Double {
        guard performanceRatingCount > 0 else { return 0.0 }
        return (totalPerformanceRatings / Double(performanceRatingCount) * 100).rounded() / 100
    }

    var successRate: Double {
        let total = questsCompleted + questsFailed
        guard total > 0 else { return 0.0 }
        return Double(questsCompleted) / Double(total)
    }
}

// MARK: - Injury System (Section 18)

struct Injury: Identifiable, Codable, Equatable {
    let id: UUID
    let type: InjuryType
    let severity: InjurySeverity
    var recoveryWeeksRemaining: Int
    let attributeEffects: [AttributeType: Int]

    var isHealed: Bool {
        recoveryWeeksRemaining <= 0
    }
}

enum InjuryType: String, Codable, CaseIterable {
    case minorWound
    case seriousWound
    case criticalWound
    case curse
    case exhaustion
    case poison
    case disease
}

enum InjurySeverity: String, Codable {
    case minor
    case moderate
    case serious
    case critical
    case permanent

    var recoveryTimeRange: ClosedRange<Int> {
        switch self {
        case .minor: return 1...2
        case .moderate: return 2...4
        case .serious: return 3...6
        case .critical: return 8...16
        case .permanent: return 0...0  // Never heals naturally
        }
    }
}

// MARK: - Extensions

extension AdventurerLevel {
    var baseWeeklyWage: Int {
        switch self {
        case .apprentice: return 5
        case .journeyman: return 25
        case .adept: return 75
        case .expert: return 200
        case .master: return 500
        case .grandmaster: return 1500
        case .legendary: return 5000
        }
    }
}

extension AdventurerRace {
    var ageRange: ClosedRange<Int> {
        switch self {
        case .human: return 18...65
        case .elf: return 100...750
        case .dwarf: return 50...350
        case .halfling: return 20...150
        case .halfOrc: return 14...60
        case .tiefling: return 18...100
        case .dragonborn: return 15...80
        }
    }
}

// MARK: - Name Generator

struct NameGenerator {
    static func generate(for race: AdventurerRace, using rng: inout RandomNumberGenerator) -> (first: String, last: String) {
        let first = firstNames[race]?.randomElement(using: &rng) ?? "Unknown"
        let last = lastNames[race]?.randomElement(using: &rng) ?? "Stranger"
        return (first, last)
    }

    private static let firstNames: [AdventurerRace: [String]] = [
        .human: ["Marcus", "Elena", "Thomas", "Sarah", "William", "Anna", "James", "Maria", "Robert", "Catherine"],
        .elf: ["Aelindra", "Thalion", "Elowen", "Caelum", "Sylvara", "Fenris", "Liriel", "Aerith", "Valen", "Nimue"],
        .dwarf: ["Thorin", "Brunhilda", "Grimnar", "Helga", "Dwalin", "Thora", "Balin", "Sigrid", "Gorin", "Astrid"],
        .halfling: ["Pippin", "Rosie", "Merry", "Lily", "Frodo", "Daisy", "Sam", "Poppy", "Bilbo", "Petunia"],
        .halfOrc: ["Grok", "Shara", "Thrak", "Urzul", "Korg", "Baggi", "Dench", "Yevelda", "Krusk", "Neega"],
        .tiefling: ["Malachai", "Lilith", "Mordecai", "Seraphina", "Damien", "Ravenna", "Asmodeus", "Jezebel", "Zagan", "Nemeia"],
        .dragonborn: ["Kriv", "Biri", "Medrash", "Kava", "Shedinn", "Mishann", "Torinn", "Harann", "Arjhan", "Jheri"]
    ]

    private static let lastNames: [AdventurerRace: [String]] = [
        .human: ["Smith", "Blackwood", "Rivers", "Stone", "Hart", "Vale", "Cross", "Shaw", "Ward", "Cole"],
        .elf: ["Starweaver", "Moonwhisper", "Dawnstrider", "Silverleaf", "Nightwind", "Sunshadow", "Mistwalker", "Thornwood", "Brightblade", "Starfall"],
        .dwarf: ["Ironforge", "Stonehammer", "Battleborn", "Deepdelver", "Goldvein", "Firebeard", "Mountainheart", "Steelgrip", "Boulderback", "Craghelm"],
        .halfling: ["Goodbarrel", "Tealeaf", "Underbough", "Thorngage", "Bramblefoot", "Highhill", "Greenbottle", "Proudfoot", "Burrows", "Took"],
        .halfOrc: ["Skullcrusher", "Bonegnawer", "Ironhide", "Bloodfist", "Doomhammer", "Gorefang", "Wartooth", "Grimjaw", "Stonefist", "Axebiter"],
        .tiefling: ["Shadowmend", "Hellfire", "Darkbloom", "Crimsonveil", "Ashborn", "Nightflame", "Duskwalker", "Soulrender", "Voidtouched", "Demonbane"],
        .dragonborn: ["Clethtinthiallor", "Daardendrian", "Delmirev", "Drachedandion", "Fenkenkabradon", "Kepeshkmolik", "Kerrhylon", "Kimbatuul", "Linxakasendalor", "Myastan"]
    ]
}
