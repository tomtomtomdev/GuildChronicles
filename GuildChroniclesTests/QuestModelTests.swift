//
//  QuestModelTests.swift
//  GuildChroniclesTests
//
//  Tests for Quest, QuestChain, Party, and related models
//

import Testing
import Foundation
@testable import GuildChronicles

struct QuestModelTests {

    // MARK: - Quest Chain Tests

    @Test func questChainTierProgression() async throws {
        #expect(QuestChainTier.regional < QuestChainTier.legendary)
        #expect(QuestChainTier.regional.questCountRange.lowerBound == 4)
        #expect(QuestChainTier.legendary.questCountRange.upperBound == 30)
    }

    @Test func questChainCreation() async throws {
        let quests = [
            Quest.create(name: "Quest 1", description: "First quest",
                        type: .investigation, stakes: .low,
                        storyPosition: .prologue, baseGoldReward: 100),
            Quest.create(name: "Quest 2", description: "Second quest",
                        type: .combat, stakes: .medium,
                        storyPosition: .risingAction, baseGoldReward: 200),
            Quest.create(name: "Quest 3", description: "Final quest",
                        type: .combat, stakes: .high,
                        storyPosition: .climax, baseGoldReward: 500)
        ]

        let chain = QuestChain.create(
            name: "Test Chain",
            description: "A test quest chain",
            tier: .regional,
            quests: quests
        )

        #expect(chain.questCount == 3)
        #expect(chain.tier == .regional)
        #expect(chain.status == .locked)
        #expect(chain.currentQuestIndex == 0)
    }

    @Test func questChainProgress() async throws {
        var chain = QuestChain.create(
            name: "Test Chain",
            description: "Test",
            tier: .regional,
            quests: [
                Quest.create(name: "Q1", description: "", type: .combat,
                            stakes: .low, storyPosition: .prologue, baseGoldReward: 100),
                Quest.create(name: "Q2", description: "", type: .combat,
                            stakes: .medium, storyPosition: .climax, baseGoldReward: 200)
            ]
        )

        #expect(chain.progressPercent == 0.0)

        // Manually mark first quest complete
        chain.quests[0].status = .completed
        #expect(chain.completedQuestCount == 1)
        #expect(chain.progressPercent == 0.5)
    }

    @Test func questChainStoryPositions() async throws {
        let chain = QuestChain.create(
            name: "Story Chain",
            description: "Test",
            tier: .regional,
            quests: [
                Quest.create(name: "Prologue", description: "", type: .investigation,
                            stakes: .low, storyPosition: .prologue, baseGoldReward: 100),
                Quest.create(name: "Rising", description: "", type: .combat,
                            stakes: .medium, storyPosition: .risingAction, baseGoldReward: 200),
                Quest.create(name: "Climax", description: "", type: .combat,
                            stakes: .high, storyPosition: .climax, baseGoldReward: 500),
                Quest.create(name: "Resolution", description: "", type: .social,
                            stakes: .low, storyPosition: .resolution, baseGoldReward: 100)
            ]
        )

        #expect(chain.prologueQuest?.name == "Prologue")
        #expect(chain.climaxQuest?.name == "Climax")
        #expect(chain.resolutionQuest?.name == "Resolution")
    }

    // MARK: - Quest Tests

    @Test func questTypeAttributes() async throws {
        let combatAttrs = QuestType.combat.primaryAttributes
        #expect(combatAttrs.contains(.meleeCombat))
        #expect(combatAttrs.contains(.defense))

        let socialAttrs = QuestType.social.primaryAttributes
        #expect(socialAttrs.contains(.charisma))
        #expect(socialAttrs.contains(.cunning))
    }

    @Test func questStakesComparison() async throws {
        #expect(QuestStakes.low < QuestStakes.critical)
        #expect(QuestStakes.critical.rewardMultiplier > QuestStakes.low.rewardMultiplier)
        #expect(QuestStakes.critical.deathRiskMultiplier > QuestStakes.low.deathRiskMultiplier)
    }

    @Test func questCreation() async throws {
        let quest = Quest.create(
            name: "Test Quest",
            description: "A test quest",
            type: .investigation,
            stakes: .medium,
            storyPosition: .prologue,
            baseGoldReward: 500
        )

        #expect(quest.name == "Test Quest")
        #expect(quest.type == .investigation)
        #expect(quest.stakes == .medium)
        #expect(quest.status == .locked)
        #expect(quest.effectiveReward == 500)  // medium stakes = 1.0x
    }

    @Test func questRewardCalculation() async throws {
        let lowStakesQuest = Quest.create(
            name: "Low", description: "", type: .combat,
            stakes: .low, storyPosition: .prologue, baseGoldReward: 1000
        )
        let criticalQuest = Quest.create(
            name: "Critical", description: "", type: .combat,
            stakes: .critical, storyPosition: .climax, baseGoldReward: 1000
        )

        #expect(criticalQuest.effectiveReward > lowStakesQuest.effectiveReward)
    }

    // MARK: - Quest Event Tests

    @Test func questEventCategories() async throws {
        #expect(QuestEventType.combatMinor.category == .combat)
        #expect(QuestEventType.trap.category == .hazard)
        #expect(QuestEventType.puzzle.category == .puzzle)
        #expect(QuestEventType.negotiation.category == .social)
        #expect(QuestEventType.treasureDiscovery.category == .discovery)
    }

    @Test func questEventInjuryRisk() async throws {
        #expect(QuestEventType.combatBoss.canCauseInjury == true)
        #expect(QuestEventType.trap.canCauseInjury == true)
        #expect(QuestEventType.puzzle.canCauseInjury == false)
        #expect(QuestEventType.negotiation.canCauseInjury == false)
    }

    @Test func questEventAttributes() async throws {
        let bossAttrs = QuestEventType.combatBoss.primaryAttributes
        #expect(bossAttrs.contains(.meleeCombat))
        #expect(bossAttrs.contains(.clutchPerformance))

        let trapAttrs = QuestEventType.trap.primaryAttributes
        #expect(trapAttrs.contains(.perception))
        #expect(trapAttrs.contains(.dexterity))
    }

    // MARK: - Standalone Quest Tests

    @Test func standaloneQuestTypes() async throws {
        #expect(StandaloneQuestType.bountyHunt.isRepeatable == true)
        #expect(StandaloneQuestType.emergencyResponse.isRepeatable == false)
        #expect(StandaloneQuestType.emergencyResponse.hasTimePressure == true)
        #expect(StandaloneQuestType.bountyHunt.affectsNarrative == false)
    }

    @Test func bountyQuestCreation() async throws {
        let target = BountyTarget(
            name: "Grimjaw",
            type: .banditLeader,
            threat: .moderate,
            realm: .theBorderlands,
            region: "Western Frontier",
            baseReward: 500
        )

        let bounty = StandaloneQuest.bounty(
            name: "Hunt Grimjaw",
            target: target,
            reward: 500
        )

        #expect(bounty.standaloneType == .bountyHunt)
        #expect(bounty.bountyTarget?.name == "Grimjaw")
        #expect(bounty.isAvailable == true)
    }

    @Test func dungeonExpeditionCreation() async throws {
        let dungeon = StandaloneQuest.dungeon(
            name: "The Forgotten Crypt",
            depth: 7,
            reward: 2000
        )

        #expect(dungeon.standaloneType == .dungeonExpedition)
        #expect(dungeon.dungeonDepth == 7)
        #expect(dungeon.baseQuest.stakes == .high)  // depth > 5
    }

    // MARK: - Party Formation Tests

    @Test func partyFormationPositions() async throws {
        #expect(PartyFormation.standard.frontPositions == 2)
        #expect(PartyFormation.defensiveWall.frontPositions == 4)
        #expect(PartyFormation.rangedFocus.backPositions == 3)
    }

    @Test func tacticalSettingsPresets() async throws {
        let balanced = TacticalSettings.balanced
        #expect(balanced.aggression == .normal)
        #expect(balanced.explorationStyle == .thorough)

        let cautious = TacticalSettings.cautious
        #expect(cautious.aggression == .veryCautious)
        #expect(cautious.useStealth == true)

        let aggressive = TacticalSettings.aggressive
        #expect(aggressive.aggression == .veryAggressive)
        #expect(aggressive.combatEngagement == .seek)
    }

    @Test func aggressionLevelEffects() async throws {
        #expect(AggressionLevel.veryAggressive.combatBonusMultiplier > AggressionLevel.veryCautious.combatBonusMultiplier)
        #expect(AggressionLevel.veryAggressive.injuryRiskMultiplier > AggressionLevel.veryCautious.injuryRiskMultiplier)
    }

    @Test func questPartyCreation() async throws {
        let adventurerIDs = [UUID(), UUID(), UUID(), UUID()]
        let party = QuestParty.create(adventurerIDs: adventurerIDs)

        #expect(party.size == 4)
        #expect(party.formation == .standard)
        #expect(party.hasLeader == true)
        #expect(party.instructions.count == 4)
    }

    // MARK: - Branching System Tests

    @Test func branchChoiceConsequences() async throws {
        let consequence = ChoiceConsequence(
            type: .realmWide,
            value: 10,
            description: "Reputation increased",
            targetID: nil
        )

        #expect(consequence.type == .realmWide)
        #expect(consequence.value == 10)
    }

    @Test func questOutcomeReputationModifiers() async throws {
        #expect(QuestOutcome.perfectVictory.reputationModifier > QuestOutcome.success.reputationModifier)
        #expect(QuestOutcome.success.reputationModifier > 0)
        #expect(QuestOutcome.failure.reputationModifier < 0)
        #expect(QuestOutcome.catastrophicFailure.reputationModifier < QuestOutcome.failure.reputationModifier)
    }

    // MARK: - World Consequence Tests

    @Test func worldConsequenceTypes() async throws {
        let consequence = WorldConsequence(
            id: UUID(),
            description: "The kingdom has fallen",
            type: .kingdomFalls,
            magnitude: .catastrophic,
            affectedRealm: .theEmpire,
            isPermanent: true
        )

        #expect(consequence.type == .kingdomFalls)
        #expect(consequence.magnitude == .catastrophic)
        #expect(consequence.isPermanent == true)
    }
}
