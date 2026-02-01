//
//  Guild.swift
//  GuildChronicles
//
//  Main guild model (Sections 3.7, 3.8)
//

import Foundation

/// An adventurer's guild
struct Guild: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var motto: String
    var foundedSeason: Int
    var homeRealm: Realm
    var homeRegion: String
    var tier: GuildTier

    // Roster
    var rosterIDs: [UUID]  // Adventurer IDs under contract
    var apprenticeIDs: [UUID]  // Apprentice adventurer IDs

    // Staff & Facilities
    var staff: [StaffMember]
    var facilities: GuildFacilities

    // Council & Finances
    var council: Council
    var finances: GuildFinances
    var ledger: FinancialLedger
    var loans: [Loan]

    // Reputation & Statistics
    var reputation: GuildReputation
    var statistics: GuildStatistics

    // State
    var isPlayerControlled: Bool

    // MARK: - Computed Properties

    var rosterCount: Int {
        rosterIDs.count
    }

    var totalRosterCount: Int {
        rosterIDs.count + apprenticeIDs.count
    }

    var rosterCapacity: Int {
        facilities.rosterCapacity
    }

    var hasRosterSpace: Bool {
        totalRosterCount < rosterCapacity
    }

    var weeklyWageBill: Int {
        // This would be calculated from actual adventurer wages
        // Placeholder using average based on tier
        rosterCount * tier.averageWage
    }

    var weeklyStaffSalaries: Int {
        staff.reduce(0) { $0 + $1.weeklySalary }
    }

    var weeklyOperatingCosts: Int {
        weeklyWageBill + weeklyStaffSalaries + facilities.totalWeeklyMaintenance
    }

    var weeklyIncome: Int {
        facilities.tavernIncome
    }

    var isInFinancialTrouble: Bool {
        finances.treasury < weeklyOperatingCosts * 4  // Less than 1 month reserves
    }

    // MARK: - Staff Management

    func hasStaff(role: StaffRole) -> Bool {
        staff.contains { $0.role == role }
    }

    func staffCount(role: StaffRole) -> Int {
        staff.filter { $0.role == role }.count
    }

    var hasSecondInCommand: Bool {
        hasStaff(role: .secondInCommand)
    }

    var combatInstructors: [StaffMember] {
        staff.filter { $0.role == .combatInstructor }
    }

    var magicInstructors: [StaffMember] {
        staff.filter { $0.role == .magicInstructor }
    }

    var scouts: [StaffMember] {
        staff.filter { $0.role == .scoutMaster }
    }

    // MARK: - Factory

    static func create(
        name: String,
        motto: String,
        homeRealm: Realm,
        homeRegion: String,
        tier: GuildTier,
        isPlayerControlled: Bool
    ) -> Guild {
        Guild(
            id: UUID(),
            name: name,
            motto: motto,
            foundedSeason: 1,
            homeRealm: homeRealm,
            homeRegion: homeRegion,
            tier: tier,
            rosterIDs: [],
            apprenticeIDs: [],
            staff: Guild.starterStaff(),
            facilities: .starter,
            council: .starter(),
            finances: .starter,
            ledger: .empty,
            loans: [],
            reputation: GuildReputation(local: 50, regional: 20, continental: 0),
            statistics: GuildStatistics(),
            isPlayerControlled: isPlayerControlled
        )
    }

    private static func starterStaff() -> [StaffMember] {
        [
            .random(role: .combatInstructor, skillLevel: 10),
            .random(role: .healerOnRetainer, skillLevel: 8),
            .random(role: .quartermaster, skillLevel: 9)
        ]
    }

    /// Generate a random AI-controlled guild
    static func randomAI(in realm: Realm, tier: GuildTier) -> Guild {
        let names = [
            "The Silver Blades", "Iron Wolves Guild", "The Crimson Order",
            "Phoenix Rising", "The Shadow Consortium", "Golden Shield Company",
            "The Emerald Brotherhood", "Storm Riders Guild", "The Obsidian Circle",
            "Dawn Seekers", "The Azure Covenant", "Raven's Watch"
        ]

        let mottos = [
            "Fortune Favors the Bold", "In Unity, Strength",
            "Through Darkness, Light", "Victory or Death",
            "Honor Above All", "Steel and Sorcery",
            "We Never Retreat", "Glory Awaits"
        ]

        return Guild.create(
            name: names.randomElement()!,
            motto: mottos.randomElement()!,
            homeRealm: realm,
            homeRegion: "Region of \(realm.displayName)",
            tier: tier,
            isPlayerControlled: false
        )
    }
}

// MARK: - Supporting Types

struct GuildReputation: Codable, Equatable {
    var local: Int       // 0-100, known in home region
    var regional: Int    // 0-100, known across realm
    var continental: Int // 0-100, known across realms

    var level: ReputationLevel {
        if continental >= 75 { return .legendary }
        if continental >= 50 || regional >= 75 { return .continental }
        if regional >= 50 || local >= 75 { return .regional }
        return .local
    }
}

enum ReputationLevel: String, Codable, Comparable {
    case local
    case regional
    case continental
    case legendary

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    static func < (lhs: ReputationLevel, rhs: ReputationLevel) -> Bool {
        let order: [ReputationLevel] = [.local, .regional, .continental, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

struct GuildStatistics: Codable, Equatable {
    var questChainsCompleted: Int = 0
    var totalQuestsCompleted: Int = 0
    var totalQuestsFailed: Int = 0
    var legendaryCampaignsConquered: Int = 0
    var totalGoldEarned: Int = 0
    var totalGoldSpent: Int = 0
    var adventurersTrained: Int = 0
    var adventurersLost: Int = 0  // Deaths
    var seasonsActive: Int = 0

    var questSuccessRate: Double {
        let total = totalQuestsCompleted + totalQuestsFailed
        guard total > 0 else { return 0.0 }
        return Double(totalQuestsCompleted) / Double(total)
    }

    var netProfit: Int {
        totalGoldEarned - totalGoldSpent
    }
}

// MARK: - Guild Tier Extensions

extension GuildTier {
    var averageWage: Int {
        switch self {
        case .fledgling: return 20
        case .rising: return 50
        case .established: return 100
        case .elite: return 250
        case .legendary: return 600
        }
    }
}
