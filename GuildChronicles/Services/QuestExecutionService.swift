//
//  QuestExecutionService.swift
//  GuildChronicles
//
//  Handles quest execution simulation and outcome resolution
//

import Foundation

/// Service for simulating quest execution and determining outcomes
enum QuestExecutionService {

    // MARK: - Quest Simulation

    /// Simulate a quest and determine the outcome
    static func simulateQuest(
        quest: Quest,
        party: QuestParty,
        adventurers: [Adventurer],
        difficulty: DifficultyLevel
    ) -> QuestSimulationResult {
        // Calculate party power
        let partyPower = calculatePartyPower(
            adventurers: adventurers,
            questType: quest.type
        )

        // Calculate quest difficulty
        let questDifficulty = calculateQuestDifficulty(
            quest: quest,
            difficulty: difficulty
        )

        // Calculate success chance
        let successChance = calculateSuccessChance(
            partyPower: partyPower,
            questDifficulty: questDifficulty
        )

        // Roll for outcome
        let outcome = determineOutcome(successChance: successChance)

        // Calculate rewards
        let rewards = calculateRewards(
            quest: quest,
            outcome: outcome,
            difficulty: difficulty
        )

        // Determine injuries
        let injuries = determineInjuries(
            adventurers: adventurers,
            quest: quest,
            outcome: outcome
        )

        // Calculate performance ratings
        let ratings = calculatePerformanceRatings(
            adventurers: adventurers,
            outcome: outcome,
            partyPower: partyPower,
            questDifficulty: questDifficulty
        )

        return QuestSimulationResult(
            outcome: outcome,
            goldReward: rewards.gold,
            experienceReward: rewards.experience,
            injuries: injuries,
            deaths: [],  // Deaths are rare, handled separately
            performanceRatings: ratings,
            successChance: successChance,
            partyPower: partyPower,
            questDifficulty: questDifficulty
        )
    }

    // MARK: - Party Power Calculation

    private static func calculatePartyPower(
        adventurers: [Adventurer],
        questType: QuestType
    ) -> Double {
        guard !adventurers.isEmpty else { return 0 }

        let relevantAttributes = questType.primaryAttributes

        var totalPower: Double = 0

        for adventurer in adventurers {
            // Calculate relevant attribute average for this adventurer
            var attributeSum: Double = 0
            for attr in relevantAttributes {
                attributeSum += Double(adventurer.attributes[attr])
            }
            let avgAttribute = attributeSum / Double(relevantAttributes.count)

            // Apply level multiplier
            let levelMultiplier = adventurer.level.powerMultiplier

            // Apply condition penalty if injured/fatigued
            let conditionMultiplier = adventurer.isAvailableForQuests ? 1.0 : 0.7

            totalPower += avgAttribute * levelMultiplier * conditionMultiplier
        }

        // Party synergy bonus (larger parties have slight coordination overhead)
        let synergyMultiplier: Double = {
            switch adventurers.count {
            case 1: return 1.0
            case 2: return 1.1
            case 3: return 1.15
            case 4: return 1.2
            case 5: return 1.22
            case 6: return 1.25
            default: return 1.0
            }
        }()

        return totalPower * synergyMultiplier
    }

    // MARK: - Quest Difficulty Calculation

    private static func calculateQuestDifficulty(
        quest: Quest,
        difficulty: DifficultyLevel
    ) -> Double {
        // Base difficulty from stakes
        let baseDifficulty: Double = {
            switch quest.stakes {
            case .low: return 30
            case .medium: return 50
            case .high: return 75
            case .critical: return 100
            }
        }()

        // Apply recommended level modifier
        let levelModifier: Double = {
            switch quest.recommendedLevel {
            case .apprentice: return 0.6
            case .journeyman: return 1.0
            case .adept: return 1.4
            case .expert: return 1.8
            case .master: return 2.5
            case .grandmaster: return 3.5
            case .legendary: return 5.0
            }
        }()

        // Apply game difficulty modifier
        let difficultyModifier = difficulty.enemyStrengthMultiplier

        return baseDifficulty * levelModifier * difficultyModifier
    }

    // MARK: - Success Chance Calculation

    private static func calculateSuccessChance(
        partyPower: Double,
        questDifficulty: Double
    ) -> Double {
        guard questDifficulty > 0 else { return 1.0 }

        // Power ratio determines base success chance
        let powerRatio = partyPower / questDifficulty

        // Convert to success percentage with diminishing returns
        // ratio of 1.0 = 60% success
        // ratio of 1.5 = 80% success
        // ratio of 2.0 = 90% success
        // ratio of 0.5 = 30% success

        let baseChance = 0.6 + (powerRatio - 1.0) * 0.4
        let clampedChance = min(max(baseChance, 0.05), 0.95)

        return clampedChance
    }

    // MARK: - Outcome Determination

    private static func determineOutcome(successChance: Double) -> QuestOutcome {
        let roll = Double.random(in: 0...1)

        // Perfect victory: roll significantly under success chance
        if roll < successChance * 0.3 {
            return .perfectVictory
        }

        // Success: roll under success chance
        if roll < successChance {
            return .success
        }

        // Partial success: roll slightly over success chance
        if roll < successChance + (1 - successChance) * 0.4 {
            return .partialSuccess
        }

        // Failure: roll significantly over
        if roll < successChance + (1 - successChance) * 0.85 {
            return .failure
        }

        // Catastrophic failure: very bad roll
        return .catastrophicFailure
    }

    // MARK: - Rewards Calculation

    private static func calculateRewards(
        quest: Quest,
        outcome: QuestOutcome,
        difficulty: DifficultyLevel
    ) -> (gold: Int, experience: Int) {
        let baseGold = quest.effectiveReward
        let baseExperience = quest.experienceReward

        let outcomeMultiplier: Double = {
            switch outcome {
            case .perfectVictory: return 1.5
            case .success: return 1.0
            case .partialSuccess: return 0.5
            case .failure: return 0.0
            case .catastrophicFailure: return 0.0
            }
        }()

        let difficultyMultiplier = difficulty.rewardMultiplier

        let finalGold = Int(Double(baseGold) * outcomeMultiplier * difficultyMultiplier)
        let finalExperience = Int(Double(baseExperience) * outcomeMultiplier)

        return (gold: finalGold, experience: finalExperience)
    }

    // MARK: - Injury Determination

    private static func determineInjuries(
        adventurers: [Adventurer],
        quest: Quest,
        outcome: QuestOutcome
    ) -> [UUID: InjuryType] {
        var injuries: [UUID: InjuryType] = [:]

        // Base injury chance depends on outcome
        let baseInjuryChance: Double = {
            switch outcome {
            case .perfectVictory: return 0.02
            case .success: return 0.08
            case .partialSuccess: return 0.20
            case .failure: return 0.35
            case .catastrophicFailure: return 0.60
            }
        }()

        // Stakes modifier
        let stakesModifier = quest.stakes.deathRiskMultiplier * 5  // Scale up for injuries

        for adventurer in adventurers {
            let injuryChance = baseInjuryChance * stakesModifier

            if Double.random(in: 0...1) < injuryChance {
                // Determine injury type based on severity roll
                let severityRoll = Double.random(in: 0...1)
                let injuryType: InjuryType = {
                    if severityRoll < 0.5 {
                        return .minorWound
                    } else if severityRoll < 0.8 {
                        return .seriousWound
                    } else if severityRoll < 0.95 {
                        return .criticalWound
                    } else {
                        return .exhaustion
                    }
                }()

                injuries[adventurer.id] = injuryType
            }
        }

        return injuries
    }

    // MARK: - Performance Ratings

    private static func calculatePerformanceRatings(
        adventurers: [Adventurer],
        outcome: QuestOutcome,
        partyPower: Double,
        questDifficulty: Double
    ) -> [UUID: Double] {
        var ratings: [UUID: Double] = [:]

        // Base rating from outcome
        let baseRating: Double = {
            switch outcome {
            case .perfectVictory: return 9.0
            case .success: return 7.0
            case .partialSuccess: return 5.0
            case .failure: return 3.0
            case .catastrophicFailure: return 1.0
            }
        }()

        for adventurer in adventurers {
            // Add some variance
            let variance = Double.random(in: -1.0...1.0)
            let rating = min(max(baseRating + variance, 1.0), 10.0)
            ratings[adventurer.id] = rating
        }

        return ratings
    }

    // MARK: - Apply Results

    /// Apply simulation results to game state
    static func applyQuestResults(
        quest: inout Quest,
        result: QuestSimulationResult,
        party: QuestParty,
        guild: inout Guild,
        gameState: GameState
    ) {
        // Create quest result
        let questResult = QuestResult(
            outcome: result.outcome,
            goldEarned: result.goldReward,
            experienceEarned: result.experienceReward,
            lootObtained: [],
            adventurerRatings: result.performanceRatings,
            injuries: result.injuries,
            deaths: result.deaths,
            completedWeek: gameState.totalWeeksElapsed,
            segmentsCompleted: quest.segmentCount,
            totalSegments: quest.segmentCount
        )

        quest.result = questResult
        quest.status = result.outcome.isSuccess ? .completed : .failed

        // Award gold
        if result.goldReward > 0 {
            guild.finances.treasury += result.goldReward
            guild.finances.seasonIncome += result.goldReward

            let transaction = FinancialTransaction.income(
                week: gameState.totalWeeksElapsed,
                amount: result.goldReward,
                type: .questReward,
                description: "Quest: \(quest.name)"
            )
            guild.ledger.record(transaction)
        }

        // Update guild statistics
        if result.outcome.isSuccess {
            guild.statistics.totalQuestsCompleted += 1
        } else {
            guild.statistics.totalQuestsFailed += 1
        }
        guild.statistics.totalGoldEarned += result.goldReward

        // Apply injuries to adventurers
        for (adventurerId, injuryType) in result.injuries {
            if var adventurer = gameState.allAdventurers[adventurerId] {
                let injury = Injury(
                    id: UUID(),
                    type: injuryType,
                    severity: injuryType.defaultSeverity,
                    recoveryWeeksRemaining: injuryType.defaultSeverity.recoveryTimeRange.randomElement() ?? 2,
                    attributeEffects: [:]
                )
                adventurer.injuries.append(injury)
                adventurer.currentCondition = .injured
                gameState.allAdventurers[adventurerId] = adventurer

                gameState.addEvent(
                    .adventurerInjured,
                    message: "\(adventurer.fullName) was injured on quest",
                    relatedEntityID: adventurerId
                )
            }
        }

        // Update adventurer statistics
        for adventurerId in party.adventurerIDs {
            if var adventurer = gameState.allAdventurers[adventurerId] {
                if result.outcome.isSuccess {
                    adventurer.statistics.questsCompleted += 1
                } else {
                    adventurer.statistics.questsFailed += 1
                }

                if let rating = result.performanceRatings[adventurerId] {
                    adventurer.statistics.totalPerformanceRatings += rating
                    adventurer.statistics.performanceRatingCount += 1
                }

                gameState.allAdventurers[adventurerId] = adventurer
            }
        }

        // Award experience to party members
        _ = LevelingService.awardQuestExperience(
            baseExperience: result.experienceReward,
            to: party.adventurerIDs,
            outcome: result.outcome,
            gameState: gameState
        )

        // Generate loot drops
        let lootDrops = LootService.generateQuestLoot(
            quest: quest,
            outcome: result.outcome,
            guild: &guild
        )

        // Log loot obtained
        for loot in lootDrops {
            gameState.addEvent(
                .lootObtained,
                message: "Found: \(loot.displayName)",
                relatedEntityID: quest.id
            )
        }

        // Log completion event
        let eventType: EventType = result.outcome.isSuccess ? .questCompleted : .questFailed
        gameState.addEvent(
            eventType,
            message: "\(quest.name): \(result.outcome.displayName) (+\(result.goldReward) gold)",
            relatedEntityID: quest.id
        )
    }
}

// MARK: - Supporting Types

struct QuestSimulationResult {
    let outcome: QuestOutcome
    let goldReward: Int
    let experienceReward: Int
    let injuries: [UUID: InjuryType]
    let deaths: [UUID]
    let performanceRatings: [UUID: Double]
    let successChance: Double
    let partyPower: Double
    let questDifficulty: Double
}

// MARK: - Extensions

extension QuestOutcome {
    var isSuccess: Bool {
        switch self {
        case .perfectVictory, .success, .partialSuccess:
            return true
        case .failure, .catastrophicFailure:
            return false
        }
    }
}

extension AdventurerLevel {
    var powerMultiplier: Double {
        switch self {
        case .apprentice: return 0.6
        case .journeyman: return 1.0
        case .adept: return 1.5
        case .expert: return 2.2
        case .master: return 3.0
        case .grandmaster: return 4.0
        case .legendary: return 5.5
        }
    }
}

extension InjuryType {
    var defaultSeverity: InjurySeverity {
        switch self {
        case .minorWound: return .minor
        case .seriousWound: return .moderate
        case .criticalWound: return .serious
        case .curse: return .serious
        case .exhaustion: return .minor
        case .poison: return .moderate
        case .disease: return .moderate
        }
    }
}
