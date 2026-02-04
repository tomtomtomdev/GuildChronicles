//
//  QuestService.swift
//  GuildChronicles
//
//  Handles quest generation, acceptance, and completion
//

import Foundation

/// Service for managing quests
enum QuestService {

    // MARK: - Quest Generation

    /// Generate available quests based on guild tier and reputation
    static func generateAvailableQuests(
        for guild: Guild,
        count: Int = 8
    ) -> [Quest] {
        var quests: [Quest] = []

        // Mix of quest types based on guild tier
        let stakesDistribution = stakesDistribution(for: guild.tier)

        for _ in 0..<count {
            let type = QuestType.allCases.randomElement()!
            let stakes = weightedRandomStakes(from: stakesDistribution)
            let quest = generateQuest(type: type, stakes: stakes, tier: guild.tier)
            quests.append(quest)
        }

        return quests
    }

    private static func generateQuest(
        type: QuestType,
        stakes: QuestStakes,
        tier: GuildTier
    ) -> Quest {
        let name = generateQuestName(type: type)
        let baseReward = calculateBaseReward(stakes: stakes, tier: tier)

        return Quest(
            id: UUID(),
            name: name,
            description: type.description,
            type: type,
            stakes: stakes,
            status: .available,
            storyPosition: .prologue,
            segmentCount: Int.random(in: 3...8),
            estimatedDurationMinutes: calculateDuration(stakes: stakes),
            minimumPartySize: type.recommendedPartySize.lowerBound,
            maximumPartySize: type.recommendedPartySize.upperBound,
            requiredClasses: [],
            recommendedLevel: recommendedLevel(for: stakes),
            baseGoldReward: baseReward,
            experienceReward: baseReward / 10,
            lootTableID: nil,
            prologueText: "Your guild has received a new mission...",
            successText: "Mission accomplished!",
            failureText: "The mission has failed...",
            partialSuccessText: "The mission was partially successful.",
            result: nil
        )
    }

    private static func generateQuestName(type: QuestType) -> String {
        let prefixes: [QuestType: [String]] = [
            .combat: ["Hunt the", "Slay the", "Destroy the", "Defeat the", "Conquer the"],
            .exploration: ["Explore the", "Map the", "Venture into", "Discover the", "Delve into"],
            .retrieval: ["Retrieve the", "Recover the", "Find the", "Reclaim the", "Secure the"],
            .investigation: ["Investigate the", "Uncover the", "Solve the", "Research the"],
            .escort: ["Escort the", "Protect the", "Guard the", "Accompany the"],
            .defense: ["Defend the", "Protect the", "Hold the", "Guard the"],
            .social: ["Negotiate with", "Persuade the", "Infiltrate the", "Befriend the"],
            .ritual: ["Disrupt the", "Complete the", "Stop the", "Perform the"],
            .siege: ["Assault the", "Storm the", "Breach the", "Capture the"],
            .assassination: ["Eliminate the", "Hunt down the", "Track the", "Neutralize the"]
        ]

        let suffixes: [QuestType: [String]] = [
            .combat: ["Dragon", "Bandit King", "Orc Warband", "Giant Spider Nest", "Werewolf Pack", "Undead Horde"],
            .exploration: ["Forgotten Ruins", "Ancient Tomb", "Mysterious Cave", "Lost Temple", "Hidden Valley"],
            .retrieval: ["Sacred Relic", "Stolen Artifact", "Lost Crown", "Ancient Scroll", "Royal Heirloom"],
            .investigation: ["Murder Mystery", "Disappearances", "Cult Activities", "Smuggling Ring"],
            .escort: ["Merchant Caravan", "Noble Family", "Diplomatic Envoy", "Sacred Pilgrims"],
            .defense: ["Village", "Outpost", "Bridge", "Supply Depot", "Sacred Shrine"],
            .social: ["Rival Guild", "Merchant Prince", "Noble Council", "Thieves Guild"],
            .ritual: ["Dark Summoning", "Blood Moon Rite", "Ancient Binding", "Resurrection Spell"],
            .siege: ["Bandit Fortress", "Enemy Stronghold", "Dark Tower", "Mountain Keep"],
            .assassination: ["Crime Lord", "Corrupt Official", "Cult Leader", "Rival Champion"]
        ]

        let prefix = prefixes[type]?.randomElement() ?? "Complete the"
        let suffix = suffixes[type]?.randomElement() ?? "Quest"

        return "\(prefix) \(suffix)"
    }

    private static func stakesDistribution(for tier: GuildTier) -> [QuestStakes: Int] {
        switch tier {
        case .fledgling:
            return [.low: 50, .medium: 40, .high: 10, .critical: 0]
        case .rising:
            return [.low: 30, .medium: 50, .high: 18, .critical: 2]
        case .established:
            return [.low: 15, .medium: 50, .high: 30, .critical: 5]
        case .elite:
            return [.low: 5, .medium: 35, .high: 45, .critical: 15]
        case .legendary:
            return [.low: 0, .medium: 20, .high: 50, .critical: 30]
        }
    }

    private static func weightedRandomStakes(from distribution: [QuestStakes: Int]) -> QuestStakes {
        let total = distribution.values.reduce(0, +)
        let roll = Int.random(in: 0..<total)
        var cumulative = 0

        for (stakes, weight) in distribution.sorted(by: { $0.value > $1.value }) {
            cumulative += weight
            if roll < cumulative {
                return stakes
            }
        }

        return .medium
    }

    private static func calculateBaseReward(stakes: QuestStakes, tier: GuildTier) -> Int {
        let tierMultiplier: Int = {
            switch tier {
            case .fledgling: return 100
            case .rising: return 250
            case .established: return 500
            case .elite: return 1000
            case .legendary: return 2500
            }
        }()

        let stakesMultiplier: Int = {
            switch stakes {
            case .low: return 1
            case .medium: return 2
            case .high: return 4
            case .critical: return 8
            }
        }()

        let variance = Int.random(in: -20...20)
        return tierMultiplier * stakesMultiplier + variance
    }

    private static func calculateDuration(stakes: QuestStakes) -> Int {
        switch stakes {
        case .low: return Int.random(in: 15...25)
        case .medium: return Int.random(in: 25...40)
        case .high: return Int.random(in: 35...50)
        case .critical: return Int.random(in: 45...60)
        }
    }

    private static func recommendedLevel(for stakes: QuestStakes) -> AdventurerLevel {
        switch stakes {
        case .low: return .apprentice
        case .medium: return .journeyman
        case .high: return .adept
        case .critical: return .expert
        }
    }

    // MARK: - Quest Acceptance

    /// Accept a quest and assign a party to it
    static func acceptQuest(
        _ quest: inout Quest,
        party: QuestParty,
        guild: inout Guild,
        gameState: GameState
    ) -> AcceptResult {
        guard quest.status == .available else {
            return .failure(.questNotAvailable)
        }

        guard party.adventurerIDs.count >= quest.minimumPartySize else {
            return .failure(.partyTooSmall)
        }

        guard party.adventurerIDs.count <= quest.maximumPartySize else {
            return .failure(.partyTooLarge)
        }

        // Verify all party members are available
        for memberId in party.adventurerIDs {
            guard let adventurer = gameState.allAdventurers[memberId] else {
                return .failure(.adventurerNotFound)
            }
            guard adventurer.isAvailableForQuests else {
                return .failure(.adventurerNotAvailable)
            }
        }

        // Accept the quest
        quest.status = .inProgress

        // Log event
        gameState.addEvent(
            .questAccepted,
            message: "Party embarks on: \(quest.name)",
            relatedEntityID: quest.id
        )

        return .success
    }

    // MARK: - Quest Completion (Simplified)

    /// Complete a quest with a given outcome
    static func completeQuest(
        _ quest: inout Quest,
        outcome: QuestOutcome,
        party: QuestParty,
        guild: inout Guild,
        gameState: GameState
    ) -> CompleteResult {
        guard quest.status == .inProgress else {
            return .failure(.questNotInProgress)
        }

        // Calculate rewards
        let goldReward = calculateFinalReward(quest: quest, outcome: outcome)

        // Create result
        let result = QuestResult(
            outcome: outcome,
            goldEarned: goldReward,
            experienceEarned: quest.experienceReward,
            lootObtained: [],
            adventurerRatings: [:],
            injuries: [:],
            deaths: [],
            completedWeek: gameState.totalWeeksElapsed,
            segmentsCompleted: quest.segmentCount,
            totalSegments: quest.segmentCount
        )

        quest.result = result
        quest.status = outcome == .failure || outcome == .catastrophicFailure ? .failed : .completed

        // Award gold
        guild.finances.treasury += goldReward
        guild.finances.seasonIncome += goldReward

        // Record transaction
        let transaction = FinancialTransaction.income(
            week: gameState.totalWeeksElapsed,
            amount: goldReward,
            type: .questReward,
            description: "Quest: \(quest.name)",
            relatedTo: quest.id
        )
        guild.ledger.record(transaction)

        // Update guild stats
        if outcome == .failure || outcome == .catastrophicFailure {
            guild.statistics.totalQuestsFailed += 1
        } else {
            guild.statistics.totalQuestsCompleted += 1
        }
        guild.statistics.totalGoldEarned += goldReward

        // Log event
        let eventType: EventType = outcome == .failure || outcome == .catastrophicFailure
            ? .questFailed
            : .questCompleted
        gameState.addEvent(
            eventType,
            message: "\(quest.name): \(outcome.displayName) (+\(goldReward) gold)",
            relatedEntityID: quest.id
        )

        return .success(result)
    }

    private static func calculateFinalReward(quest: Quest, outcome: QuestOutcome) -> Int {
        let base = quest.effectiveReward
        let multiplier: Double = {
            switch outcome {
            case .perfectVictory: return 1.5
            case .success: return 1.0
            case .partialSuccess: return 0.5
            case .failure: return 0.0
            case .catastrophicFailure: return 0.0
            }
        }()
        return Int(Double(base) * multiplier)
    }
}

// MARK: - Result Types

enum AcceptResult {
    case success
    case failure(AcceptError)
}

enum AcceptError: Error {
    case questNotAvailable
    case partyTooSmall
    case partyTooLarge
    case adventurerNotFound
    case adventurerNotAvailable

    var message: String {
        switch self {
        case .questNotAvailable: return "Quest is not available"
        case .partyTooSmall: return "QuestParty is too small for this quest"
        case .partyTooLarge: return "QuestParty is too large for this quest"
        case .adventurerNotFound: return "Adventurer not found"
        case .adventurerNotAvailable: return "Adventurer is not available"
        }
    }
}

enum CompleteResult {
    case success(QuestResult)
    case failure(CompleteError)
}

enum CompleteError: Error {
    case questNotInProgress

    var message: String {
        switch self {
        case .questNotInProgress: return "Quest is not in progress"
        }
    }
}

