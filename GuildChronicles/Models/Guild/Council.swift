//
//  Council.swift
//  GuildChronicles
//
//  Council/Patron system (Section 15)
//

import Foundation

/// Types of council patrons (Section 15.1)
enum PatronType: String, Codable, CaseIterable, Identifiable {
    case benefactor
    case veteran
    case representative
    case chronicler
    case arbiter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .benefactor: return "The Benefactor"
        case .veteran: return "The Veteran"
        case .representative: return "The Representative"
        case .chronicler: return "The Chronicler"
        case .arbiter: return "The Arbiter"
        }
    }

    var description: String {
        switch self {
        case .benefactor:
            return "Primary financial backer (merchant prince, noble house, or temple)"
        case .veteran:
            return "Retired legendary adventurer who provides tactical insight"
        case .representative:
            return "Speaks for the common adventurers' interests"
        case .chronicler:
            return "Keeper of guild history and reputation"
        case .arbiter:
            return "Ensures guild charter compliance"
        }
    }
}

/// Patron personality types affecting their priorities (Section 15.6)
enum PatronPersonality: String, Codable, CaseIterable {
    case ambitious
    case pragmatic
    case traditional
    case mercantile
    case glorySeeker
    case cautious

    var displayName: String {
        switch self {
        case .ambitious: return "Ambitious"
        case .pragmatic: return "Pragmatic"
        case .traditional: return "Traditional"
        case .mercantile: return "Mercantile"
        case .glorySeeker: return "Glory-Seeker"
        case .cautious: return "Cautious"
        }
    }

    var focus: String {
        switch self {
        case .ambitious: return "Trophies, prestige"
        case .pragmatic: return "Sustainable success"
        case .traditional: return "Youth development"
        case .mercantile: return "Profit generation"
        case .glorySeeker: return "Spectacular victories"
        case .cautious: return "Stability, no risks"
        }
    }

    var patience: PatronPatience {
        switch self {
        case .ambitious: return .low
        case .pragmatic: return .medium
        case .traditional: return .high
        case .mercantile: return .medium
        case .glorySeeker: return .veryLow
        case .cautious: return .high
        }
    }

    var generosity: PatronGenerosity {
        switch self {
        case .ambitious: return .high
        case .pragmatic: return .medium
        case .traditional: return .low
        case .mercantile: return .low
        case .glorySeeker: return .veryHigh
        case .cautious: return .veryLow
        }
    }
}

enum PatronPatience: String, Codable {
    case veryLow
    case low
    case medium
    case high

    var confidenceDecayRate: Double {
        switch self {
        case .veryLow: return 2.0
        case .low: return 1.5
        case .medium: return 1.0
        case .high: return 0.5
        }
    }
}

enum PatronGenerosity: String, Codable {
    case veryLow
    case low
    case medium
    case high
    case veryHigh

    var budgetMultiplier: Double {
        switch self {
        case .veryLow: return 0.6
        case .low: return 0.8
        case .medium: return 1.0
        case .high: return 1.3
        case .veryHigh: return 1.6
        }
    }
}

/// A council patron
struct Patron: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: PatronType
    var personality: PatronPersonality
    var influence: Int  // 1-100, affects voting weight
    var satisfaction: Int  // 1-100, current happiness with guild master
    var relationshipWithGuildMaster: Int  // -50 to 50

    var votingWeight: Double {
        Double(influence) / 100.0
    }

    var effectiveSatisfaction: Int {
        // Relationship modifies how satisfaction affects votes
        let modifier = relationshipWithGuildMaster / 10
        return max(0, min(100, satisfaction + modifier))
    }

    static func random(type: PatronType) -> Patron {
        Patron(
            id: UUID(),
            name: PatronNameGenerator.generate(for: type),
            type: type,
            personality: PatronPersonality.allCases.randomElement()!,
            influence: Int.random(in: 40...80),
            satisfaction: Int.random(in: 50...70),
            relationshipWithGuildMaster: Int.random(in: -10...10)
        )
    }
}

/// The guild council
struct Council: Codable, Equatable {
    var patrons: [Patron]
    var overallConfidence: Int  // 0-100 (Section 15.3)
    var lastReviewWeek: Int
    var activeUltimatum: Ultimatum?
    var protectedUntilWeek: Int?  // From successful vote of confidence

    /// Average patron satisfaction weighted by influence
    var weightedSatisfaction: Double {
        let totalWeight = patrons.reduce(0.0) { $0 + $1.votingWeight }
        let weightedSum = patrons.reduce(0.0) { $0 + Double($1.effectiveSatisfaction) * $1.votingWeight }
        return weightedSum / totalWeight
    }

    /// Confidence status based on thresholds (Section 15.3)
    var confidenceStatus: ConfidenceStatus {
        switch overallConfidence {
        case 80...100: return .secure
        case 60..<80: return .stable
        case 40..<60: return .concerning
        case 20..<40: return .critical
        default: return .failing
        }
    }

    var isProtected: Bool {
        guard let protectedUntil = protectedUntilWeek else { return false }
        return protectedUntil > lastReviewWeek
    }

    static func starter() -> Council {
        Council(
            patrons: PatronType.allCases.map { Patron.random(type: $0) },
            overallConfidence: 60,
            lastReviewWeek: 0,
            activeUltimatum: nil,
            protectedUntilWeek: nil
        )
    }
}

/// Confidence thresholds (Section 15.3)
enum ConfidenceStatus: String, Codable {
    case secure      // 80-100%
    case stable      // 60-79%
    case concerning  // 40-59%
    case critical    // 20-39%
    case failing     // 0-19%

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var description: String {
        switch self {
        case .secure: return "Bonus budget, contract extension offers"
        case .stable: return "Normal operations"
        case .concerning: return "Warning issued, reduced budget"
        case .critical: return "Ultimatum issued"
        case .failing: return "Dismissal imminent"
        }
    }
}

/// Ultimatum types (Section 15.4)
enum UltimatumType: String, Codable, CaseIterable {
    case completeQuestChain
    case consecutiveSuccesses
    case beginCampaign
    case reduceExpenditure
    case signMarqueeAdventurer
    case developApprentices
    case recoverReputation

    var displayName: String {
        switch self {
        case .completeQuestChain: return "Complete Current Quest Chain"
        case .consecutiveSuccesses: return "Achieve Consecutive Quest Successes"
        case .beginCampaign: return "Begin Higher Tier Campaign"
        case .reduceExpenditure: return "Reduce Wage Expenditure"
        case .signMarqueeAdventurer: return "Sign Marquee Adventurer"
        case .developApprentices: return "Develop Apprentices"
        case .recoverReputation: return "Recover Guild Reputation"
        }
    }
}

/// An active ultimatum from the council
struct Ultimatum: Codable, Equatable {
    let id: UUID
    var type: UltimatumType
    var description: String
    var targetValue: Int  // e.g., 3 for "3 consecutive successes"
    var currentProgress: Int
    var deadlineWeek: Int
    var issuedWeek: Int

    var isComplete: Bool {
        currentProgress >= targetValue
    }

    var weeksRemaining: Int {
        max(0, deadlineWeek - issuedWeek)
    }

    var progressPercent: Double {
        Double(currentProgress) / Double(targetValue)
    }

    static func random(type: UltimatumType, currentWeek: Int) -> Ultimatum {
        let (target, deadline, desc) = type.parameters
        return Ultimatum(
            id: UUID(),
            type: type,
            description: desc,
            targetValue: target,
            currentProgress: 0,
            deadlineWeek: currentWeek + deadline,
            issuedWeek: currentWeek
        )
    }
}

extension UltimatumType {
    var parameters: (target: Int, deadlineWeeks: Int, description: String) {
        switch self {
        case .completeQuestChain:
            return (1, 12, "Complete the current quest chain or face dismissal")
        case .consecutiveSuccesses:
            return (3, 8, "Achieve 3 consecutive quest successes")
        case .beginCampaign:
            return (1, 8, "Begin a Tier 2 campaign within 2 months")
        case .reduceExpenditure:
            return (20, 4, "Reduce wage expenditure by 20% immediately")
        case .signMarqueeAdventurer:
            return (1, 12, "Sign a marquee adventurer this recruitment window")
        case .developApprentices:
            return (2, 16, "Develop at least 2 apprentices to journeyman status")
        case .recoverReputation:
            return (1, 12, "Recover guild reputation to acceptable levels")
        }
    }
}

/// Simple name generator for patrons
struct PatronNameGenerator {
    static func generate(for type: PatronType) -> String {
        let titles: [PatronType: [String]] = [
            .benefactor: ["Lord", "Lady", "Baron", "Countess", "Duke", "Duchess"],
            .veteran: ["Sir", "Dame", "Captain", "Commander", "Marshal"],
            .representative: ["Elder", "Guildsman", "Veteran", "Speaker"],
            .chronicler: ["Sage", "Lorekeeper", "Archivist", "Scribe"],
            .arbiter: ["Judge", "Magistrate", "Justicar", "Lawkeeper"]
        ]

        let names = ["Aldric", "Beatrix", "Conrad", "Diana", "Edmund", "Fiona",
                     "Gerald", "Helena", "Ivan", "Julia", "Klaus", "Lydia",
                     "Magnus", "Nora", "Otto", "Petra", "Quentin", "Rosa",
                     "Sebastian", "Thea", "Ulrich", "Victoria", "Wilhelm", "Zara"]

        let surnames = ["Ashworth", "Blackstone", "Cromwell", "Darkwood", "Elderwood",
                        "Fairweather", "Goldwyn", "Highcastle", "Ironforge", "Kingsley",
                        "Lightfoot", "Moorewood", "Northcott", "Oakenshield", "Proudfoot"]

        let title = titles[type]?.randomElement() ?? ""
        let name = names.randomElement()!
        let surname = surnames.randomElement()!

        return "\(title) \(name) \(surname)".trimmingCharacters(in: .whitespaces)
    }
}
