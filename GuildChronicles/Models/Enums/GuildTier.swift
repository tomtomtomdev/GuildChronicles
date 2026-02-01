//
//  GuildTier.swift
//  GuildChronicles
//
//  Guild reputation tiers (Section 3.8)
//

import Foundation

enum GuildTier: String, Codable, CaseIterable, Comparable {
    case fledgling
    case rising
    case established
    case elite
    case legendary

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// Minimum quest success rate expected by council
    var minimumSuccessRate: Double {
        switch self {
        case .fledgling: return 0.50
        case .rising: return 0.70
        case .established: return 0.75
        case .elite: return 0.80
        case .legendary: return 0.85
        }
    }

    /// Maximum roster size
    var maxRosterSize: Int {
        switch self {
        case .fledgling: return 12
        case .rising: return 18
        case .established: return 24
        case .elite: return 30
        case .legendary: return 40
        }
    }

    /// Base seasonal budget
    var baseBudget: Int {
        switch self {
        case .fledgling: return 1000
        case .rising: return 5000
        case .established: return 20000
        case .elite: return 75000
        case .legendary: return 250000
        }
    }

    static func < (lhs: GuildTier, rhs: GuildTier) -> Bool {
        let order: [GuildTier] = [.fledgling, .rising, .established, .elite, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

/// Council expectations based on guild tier (Section 3.8)
struct CouncilExpectation: Codable {
    let tier: GuildTier
    let minimumRequirement: String
    let acceptableOutcome: String
    let exceedsExpectations: String

    static let expectations: [GuildTier: CouncilExpectation] = [
        .legendary: CouncilExpectation(
            tier: .legendary,
            minimumRequirement: "Complete Tier 3 Campaign",
            acceptableOutcome: "Begin Tier 4 Campaign",
            exceedsExpectations: "Complete Legendary Campaign"
        ),
        .elite: CouncilExpectation(
            tier: .elite,
            minimumRequirement: "Complete 2 Realm Campaigns",
            acceptableOutcome: "Begin Continental Saga",
            exceedsExpectations: "Complete Tier 3 Campaign"
        ),
        .established: CouncilExpectation(
            tier: .established,
            minimumRequirement: "Complete Regional Arc",
            acceptableOutcome: "Begin Realm Campaign",
            exceedsExpectations: "Complete Realm Campaign"
        ),
        .rising: CouncilExpectation(
            tier: .rising,
            minimumRequirement: "70% Quest Success Rate",
            acceptableOutcome: "Complete Regional Arc",
            exceedsExpectations: "Begin Realm Campaign"
        ),
        .fledgling: CouncilExpectation(
            tier: .fledgling,
            minimumRequirement: "50% Quest Success Rate",
            acceptableOutcome: "Complete First Arc",
            exceedsExpectations: "Positive Reputation"
        )
    ]
}
