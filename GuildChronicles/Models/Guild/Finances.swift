//
//  Finances.swift
//  GuildChronicles
//
//  Guild financial management (Section 3.7)
//

import Foundation

/// Financial record for a guild
struct GuildFinances: Codable, Equatable {
    var treasury: Int  // Current gold
    var seasonBudget: Int  // Allocated by council
    var wagesBudget: Int  // Portion for adventurer wages
    var recruitmentBudget: Int  // Portion for recruitment
    var operationsBudget: Int  // Portion for operations

    // Tracking
    var seasonIncome: Int
    var seasonExpenses: Int
    var weeklyWageExpense: Int
    var weeklyMaintenanceExpense: Int

    var netBalance: Int {
        seasonIncome - seasonExpenses
    }

    var isInDebt: Bool {
        treasury < 0
    }

    var budgetRemaining: Int {
        seasonBudget - seasonExpenses
    }

    var wagesBudgetRemaining: Int {
        wagesBudget - weeklyWageExpense * 48  // Projected annual
    }

    static var starter: GuildFinances {
        GuildFinances(
            treasury: 5000,
            seasonBudget: 20000,
            wagesBudget: 10000,
            recruitmentBudget: 5000,
            operationsBudget: 5000,
            seasonIncome: 0,
            seasonExpenses: 0,
            weeklyWageExpense: 0,
            weeklyMaintenanceExpense: 0
        )
    }
}

/// Types of income (Section 3.7)
enum IncomeType: String, Codable, CaseIterable {
    case questReward
    case lootSales
    case patronContract
    case merchandise
    case tavernIncome
    case bountyHunting
    case monsterParts
    case trainingServices

    var displayName: String {
        switch self {
        case .questReward: return "Quest Completion Rewards"
        case .lootSales: return "Dungeon Loot Sales"
        case .patronContract: return "Contract Fees from Patrons"
        case .merchandise: return "Merchandise Sales"
        case .tavernIncome: return "Tavern Income"
        case .bountyHunting: return "Bounty Hunting"
        case .monsterParts: return "Monster Parts Trade"
        case .trainingServices: return "Training Services"
        }
    }
}

/// Types of expenses (Section 3.7)
enum ExpenseType: String, Codable, CaseIterable {
    case adventurerSalaries
    case recruitmentFees
    case staffSalaries
    case guildHallMaintenance
    case trainingFacility
    case equipmentSupplies
    case healingResurrection
    case scoutingNetwork

    var displayName: String {
        switch self {
        case .adventurerSalaries: return "Adventurer Salaries"
        case .recruitmentFees: return "Recruitment Fees"
        case .staffSalaries: return "Staff Salaries"
        case .guildHallMaintenance: return "Guild Hall Maintenance"
        case .trainingFacility: return "Training Facility Costs"
        case .equipmentSupplies: return "Equipment and Supplies"
        case .healingResurrection: return "Healing and Resurrection"
        case .scoutingNetwork: return "Scouting Network"
        }
    }
}

/// A single financial transaction
struct FinancialTransaction: Identifiable, Codable, Equatable {
    let id: UUID
    var week: Int
    var amount: Int  // Positive for income, negative for expense
    var incomeType: IncomeType?
    var expenseType: ExpenseType?
    var description: String
    var relatedEntityID: UUID?  // Adventurer, Quest, etc.

    var isIncome: Bool {
        amount > 0
    }

    static func income(
        week: Int,
        amount: Int,
        type: IncomeType,
        description: String,
        relatedTo: UUID? = nil
    ) -> FinancialTransaction {
        FinancialTransaction(
            id: UUID(),
            week: week,
            amount: abs(amount),
            incomeType: type,
            expenseType: nil,
            description: description,
            relatedEntityID: relatedTo
        )
    }

    static func expense(
        week: Int,
        amount: Int,
        type: ExpenseType,
        description: String,
        relatedTo: UUID? = nil
    ) -> FinancialTransaction {
        FinancialTransaction(
            id: UUID(),
            week: week,
            amount: -abs(amount),
            incomeType: nil,
            expenseType: type,
            description: description,
            relatedEntityID: relatedTo
        )
    }
}

/// Financial ledger tracking all transactions
struct FinancialLedger: Codable, Equatable {
    var transactions: [FinancialTransaction]

    var totalIncome: Int {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Int {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + abs($1.amount) }
    }

    var netBalance: Int {
        transactions.reduce(0) { $0 + $1.amount }
    }

    func transactions(forWeek week: Int) -> [FinancialTransaction] {
        transactions.filter { $0.week == week }
    }

    func incomeByType() -> [IncomeType: Int] {
        var result: [IncomeType: Int] = [:]
        for transaction in transactions where transaction.isIncome {
            if let type = transaction.incomeType {
                result[type, default: 0] += transaction.amount
            }
        }
        return result
    }

    func expensesByType() -> [ExpenseType: Int] {
        var result: [ExpenseType: Int] = [:]
        for transaction in transactions where !transaction.isIncome {
            if let type = transaction.expenseType {
                result[type, default: 0] += abs(transaction.amount)
            }
        }
        return result
    }

    mutating func record(_ transaction: FinancialTransaction) {
        transactions.append(transaction)
    }

    static var empty: FinancialLedger {
        FinancialLedger(transactions: [])
    }
}

/// Loan from merchants or temples (Section 3.7)
struct Loan: Identifiable, Codable, Equatable {
    let id: UUID
    var lenderName: String
    var principalAmount: Int
    var interestRate: Double  // e.g., 0.1 for 10%
    var remainingBalance: Int
    var weeklyPayment: Int
    var startWeek: Int
    var durationWeeks: Int

    var totalOwed: Int {
        Int(Double(principalAmount) * (1 + interestRate))
    }

    var isPaidOff: Bool {
        remainingBalance <= 0
    }

    var weeksRemaining: Int {
        if weeklyPayment <= 0 { return 0 }
        return (remainingBalance + weeklyPayment - 1) / weeklyPayment
    }

    static func merchantLoan(amount: Int, currentWeek: Int) -> Loan {
        let interest = 0.15
        let duration = 24  // 6 months
        let total = Int(Double(amount) * (1 + interest))
        let weekly = total / duration

        return Loan(
            id: UUID(),
            lenderName: "Merchant's Guild",
            principalAmount: amount,
            interestRate: interest,
            remainingBalance: total,
            weeklyPayment: weekly,
            startWeek: currentWeek,
            durationWeeks: duration
        )
    }

    static func templeLoan(amount: Int, currentWeek: Int) -> Loan {
        let interest = 0.08  // Lower interest from temple
        let duration = 36  // 9 months, more lenient
        let total = Int(Double(amount) * (1 + interest))
        let weekly = total / duration

        return Loan(
            id: UUID(),
            lenderName: "Temple of Commerce",
            principalAmount: amount,
            interestRate: interest,
            remainingBalance: total,
            weeklyPayment: weekly,
            startWeek: currentWeek,
            durationWeeks: duration
        )
    }
}
