//
//  GuildService.swift
//  GuildChronicles
//
//  Handles guild management actions - facilities, staff, loans
//

import Foundation

/// Service for guild management operations
enum GuildService {

    // MARK: - Facility Upgrades

    /// Calculate the cost to upgrade a facility
    static func upgradeCost(for facility: Facility) -> Int {
        let nextRating = facility.rating.next
        guard nextRating != facility.rating else { return 0 } // Already max

        // upgradeCost is on FacilityRating and represents cost to reach that rating
        return nextRating.upgradeCost
    }

    /// Upgrade a facility to the next level
    static func upgradeFacility(
        _ facilityType: FacilityType,
        guild: inout Guild,
        gameState: GameState
    ) -> UpgradeResult {
        let facility = guild.facilities.facility(for: facilityType)
        let cost = upgradeCost(for: facility)

        guard cost > 0 else {
            return .failure(.alreadyMaxLevel)
        }

        guard guild.finances.treasury >= cost else {
            return .failure(.insufficientFunds)
        }

        // Deduct cost
        guild.finances.treasury -= cost
        guild.finances.seasonExpenses += cost

        // Upgrade facility
        guild.facilities.upgrade(facilityType, currentWeek: gameState.totalWeeksElapsed)

        // Record transaction
        let transaction = FinancialTransaction.expense(
            week: gameState.totalWeeksElapsed,
            amount: cost,
            type: .guildHallMaintenance,
            description: "Upgraded \(facilityType.displayName)"
        )
        guild.ledger.record(transaction)

        // Log event
        gameState.addEvent(
            .facilityUpgraded,
            message: "\(facilityType.displayName) upgraded to \(facility.rating.next.displayName)!",
            relatedEntityID: guild.id
        )

        return .success
    }

    // MARK: - Staff Management

    /// Hire a new staff member
    static func hireStaff(
        role: StaffRole,
        guild: inout Guild,
        gameState: GameState
    ) -> HireStaffResult {
        // Check if role is already filled (for unique roles)
        if role == .secondInCommand && guild.hasSecondInCommand {
            return .failure(.roleAlreadyFilled)
        }

        // Calculate hiring cost (first month salary)
        let staffMember = StaffMember.random(role: role, skillLevel: Int.random(in: 8...15))
        let hiringCost = staffMember.weeklySalary * 4

        guard guild.finances.treasury >= hiringCost else {
            return .failure(.insufficientFunds)
        }

        // Deduct cost
        guild.finances.treasury -= hiringCost
        guild.finances.seasonExpenses += hiringCost

        // Add staff member
        guild.staff.append(staffMember)

        // Record transaction
        let transaction = FinancialTransaction.expense(
            week: gameState.totalWeeksElapsed,
            amount: hiringCost,
            type: .staffSalaries,
            description: "Hired \(staffMember.name) as \(role.displayName)"
        )
        guild.ledger.record(transaction)

        // Log event
        gameState.addEvent(
            .staffHired,
            message: "Hired \(staffMember.name) as \(role.displayName)",
            relatedEntityID: guild.id
        )

        return .success(staffMember)
    }

    /// Dismiss a staff member
    static func dismissStaff(
        _ staffId: UUID,
        guild: inout Guild,
        gameState: GameState
    ) -> DismissStaffResult {
        guard let index = guild.staff.firstIndex(where: { $0.id == staffId }) else {
            return .failure(.staffNotFound)
        }

        let staffMember = guild.staff[index]
        guild.staff.remove(at: index)

        gameState.addEvent(
            .staffDismissed,
            message: "\(staffMember.name) has left the guild",
            relatedEntityID: guild.id
        )

        return .success
    }

    // MARK: - Loans

    /// Take out a loan
    static func takeLoan(
        type: LoanType,
        amount: Int,
        guild: inout Guild,
        gameState: GameState
    ) -> LoanResult {
        let loan: Loan
        switch type {
        case .merchant:
            loan = Loan.merchantLoan(amount: amount, currentWeek: gameState.totalWeeksElapsed)
        case .temple:
            loan = Loan.templeLoan(amount: amount, currentWeek: gameState.totalWeeksElapsed)
        }

        // Add gold to treasury
        guild.finances.treasury += amount
        guild.finances.seasonIncome += amount

        // Add loan
        guild.loans.append(loan)

        // Record transaction
        let transaction = FinancialTransaction.income(
            week: gameState.totalWeeksElapsed,
            amount: amount,
            type: .patronContract,
            description: "Loan from \(loan.lenderName)"
        )
        guild.ledger.record(transaction)

        // Log event
        gameState.addEvent(
            .loanTaken,
            message: "Took loan of \(amount) gold from \(loan.lenderName)",
            relatedEntityID: guild.id
        )

        return .success(loan)
    }
}

// MARK: - Result Types

enum UpgradeResult {
    case success
    case failure(UpgradeError)
}

enum UpgradeError: Error {
    case alreadyMaxLevel
    case insufficientFunds

    var message: String {
        switch self {
        case .alreadyMaxLevel: return "Facility is already at maximum level"
        case .insufficientFunds: return "Insufficient funds for upgrade"
        }
    }
}

enum HireStaffResult {
    case success(StaffMember)
    case failure(HireStaffError)
}

enum HireStaffError: Error {
    case roleAlreadyFilled
    case insufficientFunds

    var message: String {
        switch self {
        case .roleAlreadyFilled: return "This role is already filled"
        case .insufficientFunds: return "Insufficient funds to hire"
        }
    }
}

enum DismissStaffResult {
    case success
    case failure(DismissStaffError)
}

enum DismissStaffError: Error {
    case staffNotFound

    var message: String {
        switch self {
        case .staffNotFound: return "Staff member not found"
        }
    }
}

enum LoanType {
    case merchant
    case temple
}

enum LoanResult {
    case success(Loan)
    case failure(LoanError)
}

enum LoanError: Error {
    case none

    var message: String {
        switch self {
        case .none: return ""
        }
    }
}

// MARK: - Facility Extensions

extension FacilityRating {
    var next: FacilityRating {
        switch self {
        case .ramshackle: return .poor
        case .poor: return .adequate
        case .adequate: return .good
        case .good: return .excellent
        case .excellent: return .masterwork
        case .masterwork: return .legendary
        case .legendary: return .legendary
        }
    }
}

extension GuildFacilities {
    func facility(for type: FacilityType) -> Facility {
        switch type {
        case .guildHall: return guildHall
        case .trainingGrounds: return trainingGrounds
        case .apprenticeAcademy: return apprenticeAcademy
        case .library: return library
        case .temple: return temple
        case .tavern: return tavern
        case .armory: return armory
        }
    }

    mutating func upgrade(_ type: FacilityType, currentWeek: Int) {
        switch type {
        case .guildHall:
            guildHall = Facility(type: .guildHall, rating: guildHall.rating.next, condition: 100, lastUpgraded: currentWeek)
        case .trainingGrounds:
            trainingGrounds = Facility(type: .trainingGrounds, rating: trainingGrounds.rating.next, condition: 100, lastUpgraded: currentWeek)
        case .apprenticeAcademy:
            apprenticeAcademy = Facility(type: .apprenticeAcademy, rating: apprenticeAcademy.rating.next, condition: 100, lastUpgraded: currentWeek)
        case .library:
            library = Facility(type: .library, rating: library.rating.next, condition: 100, lastUpgraded: currentWeek)
        case .temple:
            temple = Facility(type: .temple, rating: temple.rating.next, condition: 100, lastUpgraded: currentWeek)
        case .tavern:
            tavern = Facility(type: .tavern, rating: tavern.rating.next, condition: 100, lastUpgraded: currentWeek)
        case .armory:
            armory = Facility(type: .armory, rating: armory.rating.next, condition: 100, lastUpgraded: currentWeek)
        }
    }
}
