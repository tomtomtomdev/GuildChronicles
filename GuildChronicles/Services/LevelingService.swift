//
//  LevelingService.swift
//  GuildChronicles
//
//  Handles experience awards and level-up mechanics
//

import Foundation

/// Service for managing adventurer experience and leveling
enum LevelingService {

    // MARK: - Experience Awards

    /// Award experience to an adventurer
    static func awardExperience(
        _ amount: Int,
        to adventurer: inout Adventurer,
        gameState: GameState
    ) -> LevelUpResult? {
        guard amount > 0 else { return nil }

        adventurer.currentExperience += amount
        adventurer.totalExperienceEarned += amount

        // Check for level up
        if adventurer.canLevelUp {
            return levelUp(adventurer: &adventurer, gameState: gameState)
        }

        return nil
    }

    /// Award experience to multiple adventurers from quest completion
    static func awardQuestExperience(
        baseExperience: Int,
        to adventurerIds: [UUID],
        outcome: QuestOutcome,
        gameState: GameState
    ) -> [UUID: LevelUpResult] {
        var levelUps: [UUID: LevelUpResult] = [:]

        // Outcome multiplier
        let multiplier: Double = {
            switch outcome {
            case .perfectVictory: return 1.5
            case .success: return 1.0
            case .partialSuccess: return 0.6
            case .failure: return 0.2
            case .catastrophicFailure: return 0.1
            }
        }()

        let xpPerAdventurer = Int(Double(baseExperience) * multiplier)

        for adventurerId in adventurerIds {
            if var adventurer = gameState.allAdventurers[adventurerId] {
                if let levelUp = awardExperience(xpPerAdventurer, to: &adventurer, gameState: gameState) {
                    levelUps[adventurerId] = levelUp
                }
                gameState.allAdventurers[adventurerId] = adventurer
            }
        }

        return levelUps
    }

    // MARK: - Level Up

    /// Process a level up for an adventurer
    private static func levelUp(
        adventurer: inout Adventurer,
        gameState: GameState
    ) -> LevelUpResult {
        guard let newLevel = adventurer.level.nextLevel else {
            return LevelUpResult(
                adventurerId: adventurer.id,
                previousLevel: adventurer.level,
                newLevel: adventurer.level,
                attributeGains: [:],
                wageIncrease: 0
            )
        }

        let previousLevel = adventurer.level

        // Deduct XP cost
        adventurer.currentExperience -= adventurer.level.experienceRequired

        // Advance level
        adventurer.level = newLevel

        // Calculate attribute gains (2-4 random attributes get +1)
        let attributeGains = calculateAttributeGains(for: adventurer)
        applyAttributeGains(attributeGains, to: &adventurer)

        // Increase wage
        let previousWage = adventurer.weeklyWage
        adventurer.weeklyWage = calculateNewWage(adventurer: adventurer)
        let wageIncrease = adventurer.weeklyWage - previousWage

        // Log event
        gameState.addEvent(
            .adventurerLevelUp,
            message: "\(adventurer.fullName) reached \(newLevel.displayName) level!",
            relatedEntityID: adventurer.id
        )

        // Haptic feedback for level up
        HapticService.levelUp()

        // Check for chain level-ups (rare but possible with large XP awards)
        if adventurer.canLevelUp {
            // Recursively level up
            let chainResult = levelUp(adventurer: &adventurer, gameState: gameState)
            // Merge results
            var mergedGains = attributeGains
            for (attr, value) in chainResult.attributeGains {
                mergedGains[attr, default: 0] += value
            }
            return LevelUpResult(
                adventurerId: adventurer.id,
                previousLevel: previousLevel,
                newLevel: chainResult.newLevel,
                attributeGains: mergedGains,
                wageIncrease: wageIncrease + chainResult.wageIncrease
            )
        }

        return LevelUpResult(
            adventurerId: adventurer.id,
            previousLevel: previousLevel,
            newLevel: newLevel,
            attributeGains: attributeGains,
            wageIncrease: wageIncrease
        )
    }

    // MARK: - Attribute Gains

    private static func calculateAttributeGains(for adventurer: Adventurer) -> [AttributeType: Int] {
        var gains: [AttributeType: Int] = [:]

        // Get primary attributes for adventurer's class
        let primaryAttributes = adventurer.primaryClass.primaryAttributes

        // Always boost 1-2 primary attributes
        let primaryCount = Int.random(in: 1...2)
        for attr in primaryAttributes.shuffled().prefix(primaryCount) {
            gains[attr] = 1
        }

        // Boost 1-2 random other attributes
        let otherAttributes = AttributeType.allCases.filter { !primaryAttributes.contains($0) }
        let otherCount = Int.random(in: 1...2)
        for attr in otherAttributes.shuffled().prefix(otherCount) {
            gains[attr] = 1
        }

        return gains
    }

    private static func applyAttributeGains(_ gains: [AttributeType: Int], to adventurer: inout Adventurer) {
        for (attribute, amount) in gains {
            let currentValue = adventurer.attributes[attribute]
            let newValue = min(currentValue + amount, 20) // Cap at 20
            adventurer.attributes[attribute] = newValue
        }
    }

    // MARK: - Wage Calculation

    private static func calculateNewWage(adventurer: Adventurer) -> Int {
        let baseWage = adventurer.level.baseWeeklyWage

        // Add variance based on attributes
        let attributeBonus = Int(adventurer.attributes.overallAverage * 0.5)

        // Add experience bonus
        let experienceBonus = adventurer.statistics.questsCompleted * 2

        return baseWage + attributeBonus + experienceBonus
    }
}

// MARK: - Result Types

struct LevelUpResult {
    let adventurerId: UUID
    let previousLevel: AdventurerLevel
    let newLevel: AdventurerLevel
    let attributeGains: [AttributeType: Int]
    let wageIncrease: Int

    var isLevelUp: Bool {
        previousLevel != newLevel
    }
}

