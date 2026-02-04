//
//  LootServiceTests.swift
//  GuildChroniclesTests
//
//  Tests for LootService loot generation
//

import Testing
import Foundation
@testable import GuildChronicles

struct LootServiceTests {

    // MARK: - Helper

    private func createTestQuest(stakes: QuestStakes, type: QuestType = .combat) -> Quest {
        Quest(
            id: UUID(),
            name: "Test Quest",
            description: "A test quest",
            type: type,
            stakes: stakes,
            status: .available,
            storyPosition: .prologue,
            segmentCount: 3,
            estimatedDurationMinutes: 30,
            minimumPartySize: 2,
            maximumPartySize: 4,
            requiredClasses: [],
            recommendedLevel: .journeyman,
            baseGoldReward: 100,
            experienceReward: 10,
            lootTableID: nil,
            prologueText: "Test prologue",
            successText: "Test success",
            failureText: "Test failure",
            partialSuccessText: "Test partial",
            result: nil
        )
    }

    @MainActor
    private func createTestGuild() -> Guild {
        Guild.create(
            name: "Test Guild",
            motto: "Testing",
            homeRealm: .theEmpire,
            homeRegion: "Test Region",
            tier: .fledgling,
            isPlayerControlled: true
        )
    }

    // MARK: - Loot Generation Tests

    @Test @MainActor func generateQuestLootOnSuccess() async throws {
        var guild = createTestGuild()
        let quest = createTestQuest(stakes: .medium)

        let loot = LootService.generateQuestLoot(
            quest: quest,
            outcome: .success,
            guild: &guild
        )

        // Success should generate some loot
        #expect(!loot.isEmpty)
    }

    @Test @MainActor func generateQuestLootOnFailure() async throws {
        var guild = createTestGuild()
        let quest = createTestQuest(stakes: .medium)

        let loot = LootService.generateQuestLoot(
            quest: quest,
            outcome: .failure,
            guild: &guild
        )

        // Failure should generate no loot
        #expect(loot.isEmpty)
    }

    @Test @MainActor func perfectVictoryBonusLoot() async throws {
        let quest = createTestQuest(stakes: .high)

        // Run multiple times to account for RNG
        var totalLoot = 0
        for _ in 0..<10 {
            var testGuild = createTestGuild()
            let loot = LootService.generateQuestLoot(
                quest: quest,
                outcome: .perfectVictory,
                guild: &testGuild
            )
            totalLoot += loot.count
        }

        // Perfect victory on high stakes should average more than 1 item
        #expect(totalLoot > 10)
    }

    @Test @MainActor func lootAddedToInventory() async throws {
        var guild = createTestGuild()

        let initialWeapons = guild.inventory.weapons.count
        let initialArmors = guild.inventory.armors.count
        let initialAccessories = guild.inventory.accessories.count
        let initialConsumables = guild.inventory.consumables.count
        let initialValuables = guild.inventory.valuables.count
        let initialTotal = initialWeapons + initialArmors + initialAccessories + initialConsumables + initialValuables

        let quest = createTestQuest(stakes: .critical)

        // Generate loot on perfect victory for higher chance of items
        let loot = LootService.generateQuestLoot(
            quest: quest,
            outcome: .perfectVictory,
            guild: &guild
        )

        let finalWeapons = guild.inventory.weapons.count
        let finalArmors = guild.inventory.armors.count
        let finalAccessories = guild.inventory.accessories.count
        let finalConsumables = guild.inventory.consumables.count
        let finalValuables = guild.inventory.valuables.count
        let finalTotal = finalWeapons + finalArmors + finalAccessories + finalConsumables + finalValuables

        // Loot count should match inventory increase
        #expect(finalTotal - initialTotal == loot.count)
    }

    @Test @MainActor func generatedLootDisplayName() async throws {
        var guild = createTestGuild()
        let quest = createTestQuest(stakes: .critical)

        let loot = LootService.generateQuestLoot(
            quest: quest,
            outcome: .perfectVictory,
            guild: &guild
        )

        // All loot should have display names
        for item in loot {
            #expect(!item.displayName.isEmpty)
            #expect(item.value > 0)
        }
    }

    @Test @MainActor func higherStakesYieldBetterLoot() async throws {
        let lowQuest = createTestQuest(stakes: .low)
        let highQuest = createTestQuest(stakes: .critical)

        // Generate loot multiple times
        var lowTotalValue = 0
        var highTotalValue = 0

        for _ in 0..<20 {
            var lowGuild = createTestGuild()
            var highGuild = createTestGuild()

            let lowLoot = LootService.generateQuestLoot(
                quest: lowQuest,
                outcome: .success,
                guild: &lowGuild
            )

            let highLoot = LootService.generateQuestLoot(
                quest: highQuest,
                outcome: .success,
                guild: &highGuild
            )

            lowTotalValue += lowLoot.reduce(0) { $0 + $1.value }
            highTotalValue += highLoot.reduce(0) { $0 + $1.value }
        }

        // Higher stakes should yield more valuable loot on average
        #expect(highTotalValue > lowTotalValue)
    }

    @Test @MainActor func catastrophicFailureNoLoot() async throws {
        var guild = createTestGuild()
        let quest = createTestQuest(stakes: .critical)

        let loot = LootService.generateQuestLoot(
            quest: quest,
            outcome: .catastrophicFailure,
            guild: &guild
        )

        // Catastrophic failure should generate no loot
        #expect(loot.isEmpty)
    }

    @Test @MainActor func partialSuccessYieldsReducedLoot() async throws {
        let quest = createTestQuest(stakes: .high)

        var successLoot = 0
        var partialLoot = 0

        for _ in 0..<20 {
            var successGuild = createTestGuild()
            var partialGuild = createTestGuild()

            let success = LootService.generateQuestLoot(
                quest: quest,
                outcome: .success,
                guild: &successGuild
            )

            let partial = LootService.generateQuestLoot(
                quest: quest,
                outcome: .partialSuccess,
                guild: &partialGuild
            )

            successLoot += success.count
            partialLoot += partial.count
        }

        // Success should yield more loot than partial success on average
        #expect(successLoot >= partialLoot)
    }
}
