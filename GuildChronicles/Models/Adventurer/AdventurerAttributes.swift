//
//  AdventurerAttributes.swift
//  GuildChronicles
//
//  Attribute storage and access (Section 3.1)
//  All attributes rated 1-20
//

import Foundation

/// Stores all adventurer attributes (rated 1-20)
struct AdventurerAttributes: Codable, Equatable {
    // MARK: - Combat Attributes
    var meleeCombat: Int
    var rangedCombat: Int
    var spellcasting: Int
    var defense: Int
    var parrying: Int
    var criticalStrikes: Int
    var initiative: Int
    var dualWielding: Int
    var shieldMastery: Int
    var armorProficiency: Int
    var weaponSpecialization: Int
    var battleTactics: Int
    var mountedCombat: Int
    var unarmedCombat: Int

    // MARK: - Mental Attributes
    var wisdom: Int
    var perception: Int
    var willpower: Int
    var creativity: Int
    var decisionMaking: Int
    var determination: Int
    var cunning: Int
    var leadership: Int
    var awareness: Int
    var tacticalSense: Int
    var teamwork: Int
    var morale: Int

    // MARK: - Physical Attributes
    var strength: Int
    var dexterity: Int
    var constitution: Int
    var agility: Int
    var endurance: Int
    var speed: Int
    var stamina: Int
    var fortitude: Int
    var charisma: Int

    // MARK: - Spellcaster Attributes
    var arcanePower: Int
    var divineConnection: Int
    var spellResistance: Int
    var manaPool: Int
    var channeling: Int
    var ritualCasting: Int
    var counterspelling: Int
    var spellRecovery: Int
    var concentration: Int
    var wildMagicAffinity: Int

    // MARK: - Hidden Attributes (not visible without scouting)
    var consistency: Int
    var clutchPerformance: Int
    var injuryProneness: Int
    var classVersatility: Int
    var realmAdaptability: Int
    var ambition: Int
    var guildLoyalty: Int
    var pressureHandling: Int
    var professionalism: Int
    var honorCode: Int
    var temperament: Int
    var greedFactor: Int

    // MARK: - Subscript Access

    subscript(attribute: AttributeType) -> Int {
        get {
            switch attribute {
            case .meleeCombat: return meleeCombat
            case .rangedCombat: return rangedCombat
            case .spellcasting: return spellcasting
            case .defense: return defense
            case .parrying: return parrying
            case .criticalStrikes: return criticalStrikes
            case .initiative: return initiative
            case .dualWielding: return dualWielding
            case .shieldMastery: return shieldMastery
            case .armorProficiency: return armorProficiency
            case .weaponSpecialization: return weaponSpecialization
            case .battleTactics: return battleTactics
            case .mountedCombat: return mountedCombat
            case .unarmedCombat: return unarmedCombat
            case .wisdom: return wisdom
            case .perception: return perception
            case .willpower: return willpower
            case .creativity: return creativity
            case .decisionMaking: return decisionMaking
            case .determination: return determination
            case .cunning: return cunning
            case .leadership: return leadership
            case .awareness: return awareness
            case .tacticalSense: return tacticalSense
            case .teamwork: return teamwork
            case .morale: return morale
            case .strength: return strength
            case .dexterity: return dexterity
            case .constitution: return constitution
            case .agility: return agility
            case .endurance: return endurance
            case .speed: return speed
            case .stamina: return stamina
            case .fortitude: return fortitude
            case .charisma: return charisma
            case .arcanePower: return arcanePower
            case .divineConnection: return divineConnection
            case .spellResistance: return spellResistance
            case .manaPool: return manaPool
            case .channeling: return channeling
            case .ritualCasting: return ritualCasting
            case .counterspelling: return counterspelling
            case .spellRecovery: return spellRecovery
            case .concentration: return concentration
            case .wildMagicAffinity: return wildMagicAffinity
            case .consistency: return consistency
            case .clutchPerformance: return clutchPerformance
            case .injuryProneness: return injuryProneness
            case .classVersatility: return classVersatility
            case .realmAdaptability: return realmAdaptability
            case .ambition: return ambition
            case .guildLoyalty: return guildLoyalty
            case .pressureHandling: return pressureHandling
            case .professionalism: return professionalism
            case .honorCode: return honorCode
            case .temperament: return temperament
            case .greedFactor: return greedFactor
            }
        }
        set {
            let clampedValue = max(1, min(20, newValue))
            switch attribute {
            case .meleeCombat: meleeCombat = clampedValue
            case .rangedCombat: rangedCombat = clampedValue
            case .spellcasting: spellcasting = clampedValue
            case .defense: defense = clampedValue
            case .parrying: parrying = clampedValue
            case .criticalStrikes: criticalStrikes = clampedValue
            case .initiative: initiative = clampedValue
            case .dualWielding: dualWielding = clampedValue
            case .shieldMastery: shieldMastery = clampedValue
            case .armorProficiency: armorProficiency = clampedValue
            case .weaponSpecialization: weaponSpecialization = clampedValue
            case .battleTactics: battleTactics = clampedValue
            case .mountedCombat: mountedCombat = clampedValue
            case .unarmedCombat: unarmedCombat = clampedValue
            case .wisdom: wisdom = clampedValue
            case .perception: perception = clampedValue
            case .willpower: willpower = clampedValue
            case .creativity: creativity = clampedValue
            case .decisionMaking: decisionMaking = clampedValue
            case .determination: determination = clampedValue
            case .cunning: cunning = clampedValue
            case .leadership: leadership = clampedValue
            case .awareness: awareness = clampedValue
            case .tacticalSense: tacticalSense = clampedValue
            case .teamwork: teamwork = clampedValue
            case .morale: morale = clampedValue
            case .strength: strength = clampedValue
            case .dexterity: dexterity = clampedValue
            case .constitution: constitution = clampedValue
            case .agility: agility = clampedValue
            case .endurance: endurance = clampedValue
            case .speed: speed = clampedValue
            case .stamina: stamina = clampedValue
            case .fortitude: fortitude = clampedValue
            case .charisma: charisma = clampedValue
            case .arcanePower: arcanePower = clampedValue
            case .divineConnection: divineConnection = clampedValue
            case .spellResistance: spellResistance = clampedValue
            case .manaPool: manaPool = clampedValue
            case .channeling: channeling = clampedValue
            case .ritualCasting: ritualCasting = clampedValue
            case .counterspelling: counterspelling = clampedValue
            case .spellRecovery: spellRecovery = clampedValue
            case .concentration: concentration = clampedValue
            case .wildMagicAffinity: wildMagicAffinity = clampedValue
            case .consistency: consistency = clampedValue
            case .clutchPerformance: clutchPerformance = clampedValue
            case .injuryProneness: injuryProneness = clampedValue
            case .classVersatility: classVersatility = clampedValue
            case .realmAdaptability: realmAdaptability = clampedValue
            case .ambition: ambition = clampedValue
            case .guildLoyalty: guildLoyalty = clampedValue
            case .pressureHandling: pressureHandling = clampedValue
            case .professionalism: professionalism = clampedValue
            case .honorCode: honorCode = clampedValue
            case .temperament: temperament = clampedValue
            case .greedFactor: greedFactor = clampedValue
            }
        }
    }

    // MARK: - Factory

    /// Creates random attributes within a range, weighted by class
    static func random(
        forClass adventurerClass: AdventurerClass,
        race: AdventurerRace,
        level: AdventurerLevel = .journeyman,
        using rng: inout RandomNumberGenerator
    ) -> AdventurerAttributes {
        let baseRange = level.attributeRange
        let primaryBonus = 3

        var attrs = AdventurerAttributes.base(range: baseRange, using: &rng)

        // Apply class bonuses to primary attributes
        for attrType in adventurerClass.primaryAttributes {
            attrs[attrType] = min(20, attrs[attrType] + primaryBonus)
        }

        // Apply racial modifiers
        let mods = race.attributeModifiers
        attrs.strength = max(1, min(20, attrs.strength + mods.strength))
        attrs.dexterity = max(1, min(20, attrs.dexterity + mods.dexterity))
        attrs.constitution = max(1, min(20, attrs.constitution + mods.constitution))
        attrs.wisdom = max(1, min(20, attrs.wisdom + mods.wisdom))
        attrs.charisma = max(1, min(20, attrs.charisma + mods.charisma))

        return attrs
    }

    /// Base attributes with random values in range
    private static func base(range: ClosedRange<Int>, using rng: inout RandomNumberGenerator) -> AdventurerAttributes {
        func rand() -> Int { Int.random(in: range, using: &rng) }

        return AdventurerAttributes(
            meleeCombat: rand(), rangedCombat: rand(), spellcasting: rand(),
            defense: rand(), parrying: rand(), criticalStrikes: rand(),
            initiative: rand(), dualWielding: rand(), shieldMastery: rand(),
            armorProficiency: rand(), weaponSpecialization: rand(), battleTactics: rand(),
            mountedCombat: rand(), unarmedCombat: rand(),
            wisdom: rand(), perception: rand(), willpower: rand(),
            creativity: rand(), decisionMaking: rand(), determination: rand(),
            cunning: rand(), leadership: rand(), awareness: rand(),
            tacticalSense: rand(), teamwork: rand(), morale: rand(),
            strength: rand(), dexterity: rand(), constitution: rand(),
            agility: rand(), endurance: rand(), speed: rand(),
            stamina: rand(), fortitude: rand(), charisma: rand(),
            arcanePower: rand(), divineConnection: rand(), spellResistance: rand(),
            manaPool: rand(), channeling: rand(), ritualCasting: rand(),
            counterspelling: rand(), spellRecovery: rand(), concentration: rand(),
            wildMagicAffinity: rand(),
            consistency: rand(), clutchPerformance: rand(), injuryProneness: rand(),
            classVersatility: rand(), realmAdaptability: rand(), ambition: rand(),
            guildLoyalty: rand(), pressureHandling: rand(), professionalism: rand(),
            honorCode: rand(), temperament: rand(), greedFactor: rand()
        )
    }

    // MARK: - Aggregates

    /// Average of all combat attributes
    var combatAverage: Double {
        let attrs: [Int] = [
            meleeCombat, rangedCombat, spellcasting, defense, parrying,
            criticalStrikes, initiative, dualWielding, shieldMastery,
            armorProficiency, weaponSpecialization, battleTactics,
            mountedCombat, unarmedCombat
        ]
        return Double(attrs.reduce(0, +)) / Double(attrs.count)
    }

    /// Average of all mental attributes
    var mentalAverage: Double {
        let attrs: [Int] = [
            wisdom, perception, willpower, creativity, decisionMaking,
            determination, cunning, leadership, awareness, tacticalSense,
            teamwork, morale
        ]
        return Double(attrs.reduce(0, +)) / Double(attrs.count)
    }

    /// Average of all physical attributes
    var physicalAverage: Double {
        let attrs: [Int] = [
            strength, dexterity, constitution, agility, endurance,
            speed, stamina, fortitude
        ]
        return Double(attrs.reduce(0, +)) / Double(attrs.count)
    }

    /// Overall attribute average (visible attributes only)
    var overallAverage: Double {
        (combatAverage + mentalAverage + physicalAverage) / 3.0
    }
}

// MARK: - Adventurer Level

enum AdventurerLevel: String, Codable, CaseIterable, Comparable {
    case apprentice
    case journeyman
    case adept
    case expert
    case master
    case grandmaster
    case legendary

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// Base attribute range for this level
    var attributeRange: ClosedRange<Int> {
        switch self {
        case .apprentice: return 1...8
        case .journeyman: return 4...12
        case .adept: return 7...14
        case .expert: return 10...16
        case .master: return 12...18
        case .grandmaster: return 14...19
        case .legendary: return 16...20
        }
    }

    static func < (lhs: AdventurerLevel, rhs: AdventurerLevel) -> Bool {
        let order: [AdventurerLevel] = [.apprentice, .journeyman, .adept, .expert, .master, .grandmaster, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}
