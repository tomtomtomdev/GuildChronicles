//
//  TimeService.swift
//  GuildChronicles
//
//  Handles time progression and weekly/seasonal events
//

import Foundation

/// Service for managing game time progression
enum TimeService {

    // MARK: - Time Advancement

    /// Advance the game by one week
    static func advanceWeek(
        gameState: GameState,
        guild: inout Guild
    ) {
        let previousMonth = gameState.currentMonth

        // Advance time
        gameState.advanceWeek()

        // Process weekly costs
        processWeeklyCosts(guild: &guild, gameState: gameState)

        // Process loan payments
        processLoanPayments(guild: &guild, gameState: gameState)

        // Check for month change
        if gameState.currentMonth != previousMonth {
            handleMonthChange(gameState: gameState, guild: &guild, previousMonth: previousMonth)
        }

        // Refresh quest board occasionally
        if gameState.totalWeeksElapsed % 4 == 0 {
            refreshQuestBoard(gameState: gameState, guild: guild)
        }

        // Log weekly event
        gameState.addEvent(
            .weekAdvanced,
            message: "Week \(gameState.weekInSeason) of \(gameState.seasonPhase.displayName)"
        )
    }

    // MARK: - Weekly Processing

    private static func processWeeklyCosts(guild: inout Guild, gameState: GameState) {
        let wageBill = calculateWeeklyWages(guild: guild, gameState: gameState)
        let staffSalaries = guild.weeklyStaffSalaries
        let maintenance = guild.facilities.totalWeeklyMaintenance

        let totalCosts = wageBill + staffSalaries + maintenance

        // Deduct costs
        guild.finances.treasury -= totalCosts
        guild.finances.seasonExpenses += totalCosts
        guild.finances.weeklyWageExpense = wageBill
        guild.finances.weeklyMaintenanceExpense = maintenance

        // Record transaction
        if totalCosts > 0 {
            let transaction = FinancialTransaction.expense(
                week: gameState.totalWeeksElapsed,
                amount: totalCosts,
                type: .adventurerSalaries,
                description: "Weekly operating costs"
            )
            guild.ledger.record(transaction)
        }

        // Add tavern income
        let tavernIncome = guild.facilities.tavernIncome
        if tavernIncome > 0 {
            guild.finances.treasury += tavernIncome
            guild.finances.seasonIncome += tavernIncome

            let incomeTransaction = FinancialTransaction.income(
                week: gameState.totalWeeksElapsed,
                amount: tavernIncome,
                type: .tavernIncome,
                description: "Weekly tavern income"
            )
            guild.ledger.record(incomeTransaction)
        }

        // Check financial status
        if guild.finances.treasury < 0 {
            gameState.addEvent(
                .treasuryLow,
                message: "Guild is in debt! Consider taking a loan.",
                relatedEntityID: guild.id
            )
        } else if guild.finances.treasury < guild.weeklyOperatingCosts * 4 {
            gameState.addEvent(
                .treasuryLow,
                message: "Low reserves - less than one month of operating costs.",
                relatedEntityID: guild.id
            )
        }
    }

    private static func calculateWeeklyWages(guild: Guild, gameState: GameState) -> Int {
        var total = 0
        for adventurerId in guild.rosterIDs {
            if let adventurer = gameState.allAdventurers[adventurerId] {
                total += adventurer.weeklyWage
            }
        }
        return total
    }

    private static func processLoanPayments(guild: inout Guild, gameState: GameState) {
        for i in guild.loans.indices {
            let payment = min(guild.loans[i].weeklyPayment, guild.loans[i].remainingBalance)
            guild.loans[i].remainingBalance -= payment
            guild.finances.treasury -= payment

            if guild.loans[i].isPaidOff {
                gameState.addEvent(
                    .loanRepaid,
                    message: "Loan from \(guild.loans[i].lenderName) has been paid off!"
                )
            }
        }

        // Remove paid-off loans
        guild.loans.removeAll { $0.isPaidOff }
    }

    // MARK: - Month/Season Changes

    private static func handleMonthChange(
        gameState: GameState,
        guild: inout Guild,
        previousMonth: Int
    ) {
        // Check if season changed
        let previousPhase = SeasonPhase.forMonth(previousMonth)
        let currentPhase = gameState.seasonPhase

        if previousPhase != currentPhase {
            handleSeasonChange(
                gameState: gameState,
                guild: &guild,
                from: previousPhase,
                to: currentPhase
            )
        } else {
            gameState.addEvent(
                .monthChanged,
                message: "Month \(gameState.currentMonth) begins"
            )
        }

        // Regenerate free agents periodically
        if gameState.freeAgents.count < 30 {
            gameState.generateInitialFreeAgents(count: 20)
        }
    }

    private static func handleSeasonChange(
        gameState: GameState,
        guild: inout Guild,
        from previousPhase: SeasonPhase,
        to currentPhase: SeasonPhase
    ) {
        // Log season change
        gameState.addEvent(
            .seasonChanged,
            message: "\(currentPhase.displayName) has begun! Season \(gameState.currentSeason)"
        )

        // Update guild statistics
        guild.statistics.seasonsActive += 1

        // Reset seasonal finances
        guild.finances.seasonIncome = 0
        guild.finances.seasonExpenses = 0

        // Refresh quest board for new season
        refreshQuestBoard(gameState: gameState, guild: guild)
    }

    // MARK: - Quest Board Management

    private static func refreshQuestBoard(gameState: GameState, guild: Guild) {
        // Keep some old quests, add new ones
        let keepCount = min(gameState.availableQuests.count, 4)
        var newQuests = Array(gameState.availableQuests.prefix(keepCount))

        // Generate new quests to fill the board
        let newQuestCount = 8 - newQuests.count
        if newQuestCount > 0 {
            let generated = QuestService.generateAvailableQuests(for: guild, count: newQuestCount)
            newQuests.append(contentsOf: generated)
        }

        gameState.availableQuests = newQuests
    }
}

// MARK: - SeasonPhase Extension

extension SeasonPhase {
    static func forMonth(_ month: Int) -> SeasonPhase {
        switch month {
        case 1...3: return .springThaw
        case 4...6: return .summerCampaign
        case 7...9: return .autumnHarvest
        case 10...12: return .wintersEnd
        default: return .springThaw
        }
    }
}
