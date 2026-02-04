//
//  BalanceConfig.swift
//  GuildChronicles
//
//  Centralized game balance configuration for easy tuning
//

import Foundation

/// Centralized configuration for game balance values
/// Adjust these values to tune the game economy and difficulty
enum BalanceConfig {

    // MARK: - Economy

    /// Base gold reward per quest stake level
    enum QuestRewards {
        /// Gold rewards per stake level
        static let lowStakesBase = 50
        static let mediumStakesBase = 120
        static let highStakesBase = 300
        static let criticalStakesBase = 600

        /// Reward multipliers by outcome
        static let perfectVictoryMultiplier = 1.5
        static let successMultiplier = 1.0
        static let partialSuccessMultiplier = 0.5
        static let failureMultiplier = 0.0

        /// Experience reward as fraction of gold
        static let experienceToGoldRatio = 0.1  // XP = gold * 0.1
    }

    /// Adventurer wage scaling
    enum Wages {
        static let baseWage = 15  // Apprentice weekly wage
        static let levelMultipliers: [AdventurerLevel: Double] = [
            .apprentice: 1.0,
            .journeyman: 1.5,
            .adept: 2.5,
            .expert: 4.0,
            .master: 6.5,
            .grandmaster: 10.0,
            .legendary: 16.0
        ]
    }

    /// Guild operating costs
    enum GuildCosts {
        static let baseFacilityMaintenance = 10  // Per facility per week
        static let staffWageMultiplier = 1.2  // Staff cost 20% more than adventurers
        static let loanInterestRate = 0.15  // 15% weekly interest
    }

    // MARK: - Progression

    /// XP requirements per level
    enum Experience {
        static let baseXP = 100  // XP to reach Journeyman from Apprentice
        static let scalingFactor = 1.8  // Each level requires 1.8x previous

        static func xpRequired(for level: AdventurerLevel) -> Int {
            switch level {
            case .apprentice: return baseXP
            case .journeyman: return Int(Double(baseXP) * scalingFactor)
            case .adept: return Int(Double(baseXP) * pow(scalingFactor, 2))
            case .expert: return Int(Double(baseXP) * pow(scalingFactor, 3))
            case .master: return Int(Double(baseXP) * pow(scalingFactor, 4))
            case .grandmaster: return Int(Double(baseXP) * pow(scalingFactor, 5))
            case .legendary: return 999999  // Max level
            }
        }
    }

    /// Attribute gains per level up
    enum AttributeGains {
        static let minGainsPerLevel = 2
        static let maxGainsPerLevel = 4
        static let pointsPerGain = 1
    }

    // MARK: - Combat & Quests

    /// Success chance calculation parameters
    enum SuccessChance {
        /// Base success chance when party power equals quest difficulty
        static let baseParity = 0.60

        /// How much each 0.1 power ratio changes success
        static let ratioSensitivity = 0.4

        /// Minimum possible success chance (never auto-fail)
        static let minimum = 0.05

        /// Maximum possible success chance (never auto-success)
        static let maximum = 0.95
    }

    /// Injury probabilities
    enum Injuries {
        /// Base injury chance by outcome
        static let perfectVictoryChance = 0.02
        static let successChance = 0.08
        static let partialSuccessChance = 0.20
        static let failureChance = 0.35
        static let catastrophicFailureChance = 0.60

        /// Injury severity distribution (% chance of each when injured)
        static let minorWoundChance = 0.50
        static let seriousWoundChance = 0.30
        static let criticalWoundChance = 0.15
        static let exhaustionChance = 0.05

        /// Recovery time in weeks by severity
        static let minorRecoveryWeeks = 1...2
        static let moderateRecoveryWeeks = 2...4
        static let seriousRecoveryWeeks = 4...8
    }

    // MARK: - Loot

    /// Loot drop configuration
    enum Loot {
        /// Base item drops by quest stakes
        static let lowStakesDrops = 1
        static let mediumStakesDropsRange = 1...2
        static let highStakesDropsRange = 1...3
        static let criticalStakesDropsRange = 2...4

        /// Bonus drops for perfect victory
        static let perfectVictoryBonusDrops = 1

        /// Rarity weights by loot tier (higher = more common)
        /// Total should sum to 100 for easy percentage reading
        static let commonTierWeights: [ItemRarity: Int] = [
            .common: 80, .uncommon: 15, .rare: 4, .epic: 1, .legendary: 0
        ]
        static let uncommonTierWeights: [ItemRarity: Int] = [
            .common: 50, .uncommon: 35, .rare: 12, .epic: 3, .legendary: 0
        ]
        static let rareTierWeights: [ItemRarity: Int] = [
            .common: 25, .uncommon: 40, .rare: 25, .epic: 8, .legendary: 2
        ]
        static let epicTierWeights: [ItemRarity: Int] = [
            .common: 10, .uncommon: 25, .rare: 35, .epic: 25, .legendary: 5
        ]
        static let legendaryTierWeights: [ItemRarity: Int] = [
            .common: 5, .uncommon: 15, .rare: 30, .epic: 35, .legendary: 15
        ]

        /// Gold value multipliers by rarity
        static let commonValueMultiplier = 1.0
        static let uncommonValueMultiplier = 2.0
        static let rareValueMultiplier = 5.0
        static let epicValueMultiplier = 15.0
        static let legendaryValueMultiplier = 50.0
    }

    // MARK: - Difficulty Modifiers

    /// Game difficulty scaling
    enum Difficulty {
        static func enemyStrengthMultiplier(for level: DifficultyLevel) -> Double {
            switch level {
            case .easy: return 0.7
            case .normal: return 1.0
            case .hard: return 1.3
            case .legendary: return 1.6
            }
        }

        static func rewardMultiplier(for level: DifficultyLevel) -> Double {
            switch level {
            case .easy: return 1.2  // More rewards to compensate
            case .normal: return 1.0
            case .hard: return 0.9
            case .legendary: return 0.8  // Risk vs reward
            }
        }

        static func injuryRateMultiplier(for level: DifficultyLevel) -> Double {
            switch level {
            case .easy: return 0.5
            case .normal: return 1.0
            case .hard: return 1.3
            case .legendary: return 1.7
            }
        }
    }

    // MARK: - Party Synergy

    /// Party size bonuses
    enum PartySynergy {
        static let soloMultiplier = 1.0
        static let duoMultiplier = 1.1
        static let trioMultiplier = 1.15
        static let quadMultiplier = 1.2
        static let quintetMultiplier = 1.22
        static let fullPartyMultiplier = 1.25

        static func multiplier(for size: Int) -> Double {
            switch size {
            case 1: return soloMultiplier
            case 2: return duoMultiplier
            case 3: return trioMultiplier
            case 4: return quadMultiplier
            case 5: return quintetMultiplier
            case 6: return fullPartyMultiplier
            default: return 1.0
            }
        }
    }

    // MARK: - Time & Events

    /// Time progression
    enum Time {
        static let weeksPerMonth = 4
        static let monthsPerSeason = 3
        static let questRefreshCount = 3  // New quests per week
    }

    /// Recruitment pool
    enum Recruitment {
        static let basePoolSize = 5
        static let refreshWeeks = 2  // Pool refreshes every N weeks
        static let hireCostMultiplier = 10.0  // Hiring costs 10x weekly wage
    }
}
