//
//  GuildChroniclesTests.swift
//  GuildChroniclesTests
//
//  Created by tomtomtom on 2/1/26.
//

import Testing
import Foundation
@testable import GuildChronicles

struct GuildChroniclesTests {

    // MARK: - Adventurer Race Tests

    @Test func raceAttributeModifiers() async throws {
        let elfMods = AdventurerRace.elf.attributeModifiers
        #expect(elfMods.dexterity == 2)
        #expect(elfMods.strength == -1)
        #expect(elfMods.special == .darkvision)

        let dwarfMods = AdventurerRace.dwarf.attributeModifiers
        #expect(dwarfMods.constitution == 2)
        #expect(dwarfMods.special == .poisonResistance)
    }

    @Test func allRacesHaveModifiers() async throws {
        for race in AdventurerRace.allCases {
            let mods = race.attributeModifiers
            #expect(mods.special != nil)
        }
    }

    // MARK: - Adventurer Class Tests

    @Test func classCategories() async throws {
        #expect(AdventurerClass.fighter.category == .martial)
        #expect(AdventurerClass.wizard.category == .spellcasting)
        #expect(AdventurerClass.eldritchKnight.category == .hybrid)
    }

    @Test func spellcasterDetection() async throws {
        #expect(AdventurerClass.wizard.isSpellcaster == true)
        #expect(AdventurerClass.cleric.isSpellcaster == true)
        #expect(AdventurerClass.eldritchKnight.isSpellcaster == true)
        #expect(AdventurerClass.fighter.isSpellcaster == false)
        #expect(AdventurerClass.rogue.isSpellcaster == false)
    }

    @Test func primaryAttributesExist() async throws {
        for adventurerClass in AdventurerClass.allCases {
            #expect(adventurerClass.primaryAttributes.count >= 3)
        }
    }

    // MARK: - Attribute Type Tests

    @Test func attributeCategories() async throws {
        #expect(AttributeType.meleeCombat.category == .combat)
        #expect(AttributeType.wisdom.category == .mental)
        #expect(AttributeType.strength.category == .physical)
        #expect(AttributeType.arcanePower.category == .spellcaster)
        #expect(AttributeType.consistency.category == .hidden)
    }

    @Test func hiddenAttributeDetection() async throws {
        #expect(AttributeType.clutchPerformance.isHidden == true)
        #expect(AttributeType.guildLoyalty.isHidden == true)
        #expect(AttributeType.strength.isHidden == false)
        #expect(AttributeType.meleeCombat.isHidden == false)
    }

    // MARK: - Realm Tests

    @Test func realmTiers() async throws {
        #expect(Realm.theEmpire.tier == .tier1)
        #expect(Realm.theDragonWastes.tier == .tier2)
        #expect(Realm.theFrozenReaches.tier == .tier3)
    }

    @Test func tier1RealmsHaveMultipleRegions() async throws {
        #expect(Realm.theEmpire.regionCount == 6)
        #expect(Realm.theFreeCities.regionCount == 5)
    }

    // MARK: - Adventurer Attributes Tests

    @Test func attributeSubscriptAccess() async throws {
        var rng: RandomNumberGenerator = SystemRandomNumberGenerator()
        var attrs = AdventurerAttributes.random(
            forClass: .fighter,
            race: .human,
            level: .journeyman,
            using: &rng
        )

        attrs[.strength] = 15
        #expect(attrs[.strength] == 15)
        #expect(attrs.strength == 15)

        // Test clamping
        attrs[.strength] = 25
        #expect(attrs[.strength] == 20) // Should be clamped

        attrs[.strength] = -5
        #expect(attrs[.strength] == 1) // Should be clamped
    }

    @Test func attributeAverages() async throws {
        var rng: RandomNumberGenerator = SystemRandomNumberGenerator()
        let attrs = AdventurerAttributes.random(
            forClass: .fighter,
            race: .human,
            level: .expert,
            using: &rng
        )

        #expect(attrs.combatAverage >= 1.0)
        #expect(attrs.combatAverage <= 20.0)
        #expect(attrs.mentalAverage >= 1.0)
        #expect(attrs.physicalAverage >= 1.0)
        #expect(attrs.overallAverage >= 1.0)
    }

    // MARK: - Adventurer Tests

    @Test func randomAdventurerGeneration() async throws {
        let adventurer = Adventurer.random(level: .adept)

        #expect(!adventurer.firstName.isEmpty)
        #expect(!adventurer.lastName.isEmpty)
        #expect(adventurer.level == .adept)
        #expect(adventurer.contractStatus == .freeAgent)
    }

    @Test func adventurerFullName() async throws {
        let adventurer = Adventurer.random()
        #expect(adventurer.fullName == "\(adventurer.firstName) \(adventurer.lastName)")
    }

    @Test func adventurerEstimatedValue() async throws {
        let apprentice = Adventurer.random(level: .apprentice)
        let legendary = Adventurer.random(level: .legendary)

        // Legendary should always be worth more
        #expect(legendary.estimatedValue > apprentice.estimatedValue)
    }

    @Test func adventurerAvailability() async throws {
        var adventurer = Adventurer.random()
        #expect(adventurer.isAvailableForQuests == true)

        adventurer.currentCondition = .injured
        #expect(adventurer.isAvailableForQuests == false)

        adventurer.currentCondition = .healthy
        adventurer.injuries = [Injury(
            id: UUID(),
            type: .minorWound,
            severity: .minor,
            recoveryWeeksRemaining: 1,
            attributeEffects: [:]
        )]
        #expect(adventurer.isAvailableForQuests == false)
    }

    // MARK: - Adventurer Level Tests

    @Test func levelComparison() async throws {
        #expect(AdventurerLevel.apprentice < AdventurerLevel.journeyman)
        #expect(AdventurerLevel.master < AdventurerLevel.legendary)
        #expect(!(AdventurerLevel.expert < AdventurerLevel.adept))
    }

    @Test func levelAttributeRanges() async throws {
        let apprenticeRange = AdventurerLevel.apprentice.attributeRange
        let legendaryRange = AdventurerLevel.legendary.attributeRange

        #expect(apprenticeRange.lowerBound < legendaryRange.lowerBound)
        #expect(apprenticeRange.upperBound < legendaryRange.upperBound)
    }

    // MARK: - Guild Tier Tests

    @Test func guildTierProgression() async throws {
        #expect(GuildTier.fledgling < GuildTier.rising)
        #expect(GuildTier.rising < GuildTier.established)
        #expect(GuildTier.established < GuildTier.elite)
        #expect(GuildTier.elite < GuildTier.legendary)
    }

    @Test func guildTierBudgets() async throws {
        let fledglingBudget = GuildTier.fledgling.baseBudget
        let legendaryBudget = GuildTier.legendary.baseBudget
        let fledglingRoster = GuildTier.fledgling.maxRosterSize
        let legendaryRoster = GuildTier.legendary.maxRosterSize

        #expect(fledglingBudget < legendaryBudget)
        #expect(fledglingRoster < legendaryRoster)
    }

    // MARK: - Game State Tests

    @MainActor
    @Test func gameStateInitialization() async throws {
        let state = GameState()
        #expect(state.currentSeason == 1)
        #expect(state.currentMonth == 1)
        #expect(state.totalWeeksElapsed == 0)
        #expect(state.seasonPhase == .springThaw)
    }

    @MainActor
    @Test func gameStateTimeProgression() async throws {
        let state = GameState()
        state.advanceWeek()
        #expect(state.totalWeeksElapsed == 1)

        // Advance through a full month (4 weeks)
        for _ in 0..<3 {
            state.advanceWeek()
        }
        #expect(state.currentMonth == 2)
    }

    @MainActor
    @Test func gameStateFreeAgentManagement() async throws {
        let state = GameState()
        state.generateInitialFreeAgents(count: 10)

        #expect(state.allAdventurers.count == 10)
        #expect(state.freeAgents.count == 10)
        #expect(state.freeAgentAdventurers.count == 10)
    }

    @MainActor
    @Test func seasonPhaseMapping() async throws {
        let state = GameState()

        state.currentMonth = 1
        #expect(state.seasonPhase == .springThaw)

        state.currentMonth = 5
        #expect(state.seasonPhase == .summerCampaign)

        state.currentMonth = 8
        #expect(state.seasonPhase == .autumnHarvest)

        state.currentMonth = 11
        #expect(state.seasonPhase == .wintersEnd)
    }

    // MARK: - Statistics Tests

    @Test func adventurerStatisticsCalculations() async throws {
        var stats = AdventurerStatistics()
        #expect(stats.averagePerformanceRating == 0.0)
        #expect(stats.successRate == 0.0)

        stats.questsCompleted = 8
        stats.questsFailed = 2
        #expect(stats.successRate == 0.8)

        stats.totalPerformanceRatings = 75.5
        stats.performanceRatingCount = 10
        #expect(stats.averagePerformanceRating == 7.55)
    }
}
