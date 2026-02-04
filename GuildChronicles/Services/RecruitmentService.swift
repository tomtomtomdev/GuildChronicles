//
//  RecruitmentService.swift
//  GuildChronicles
//
//  Handles adventurer recruitment and dismissal
//

import Foundation

/// Service for managing adventurer recruitment
enum RecruitmentService {

    // MARK: - Hiring

    /// Hire an adventurer from the free agent pool
    /// - Parameters:
    ///   - adventurerId: The adventurer to hire
    ///   - guild: The guild hiring the adventurer (mutated)
    ///   - gameState: The game state containing adventurers (mutated)
    /// - Returns: Result indicating success or failure reason
    @discardableResult
    static func hireAdventurer(
        _ adventurerId: UUID,
        into guild: inout Guild,
        gameState: GameState
    ) -> HireResult {
        // Validate adventurer exists and is available
        guard var adventurer = gameState.allAdventurers[adventurerId] else {
            return .failure(.adventurerNotFound)
        }

        guard adventurer.contractStatus == .freeAgent else {
            return .failure(.notFreeAgent)
        }

        // Check roster space
        guard guild.hasRosterSpace else {
            return .failure(.noRosterSpace)
        }

        // Check treasury
        let hiringCost = adventurer.estimatedValue
        guard guild.finances.treasury >= hiringCost else {
            return .failure(.insufficientFunds)
        }

        // Perform the hire
        guild.finances.treasury -= hiringCost
        guild.finances.seasonExpenses += hiringCost
        guild.rosterIDs.append(adventurerId)

        // Update adventurer
        adventurer.contractStatus = .underContract
        adventurer.currentGuildID = guild.id
        gameState.allAdventurers[adventurerId] = adventurer

        // Remove from free agents
        gameState.freeAgents.removeAll { $0 == adventurerId }

        // Record transaction
        let transaction = FinancialTransaction.expense(
            week: gameState.totalWeeksElapsed,
            amount: hiringCost,
            type: .recruitmentFees,
            description: "Hired \(adventurer.fullName)",
            relatedTo: adventurerId
        )
        guild.ledger.record(transaction)

        // Log event
        gameState.addEvent(
            .adventurerHired,
            message: "\(adventurer.fullName) has joined the guild!",
            relatedEntityID: adventurerId
        )

        return .success(adventurer)
    }

    // MARK: - Dismissal

    /// Dismiss an adventurer from the guild
    /// - Parameters:
    ///   - adventurerId: The adventurer to dismiss
    ///   - guild: The guild dismissing the adventurer (mutated)
    ///   - gameState: The game state (mutated)
    /// - Returns: Result indicating success or failure reason
    @discardableResult
    static func dismissAdventurer(
        _ adventurerId: UUID,
        from guild: inout Guild,
        gameState: GameState
    ) -> DismissResult {
        // Validate adventurer is in guild roster
        guard guild.rosterIDs.contains(adventurerId) else {
            return .failure(.notInRoster)
        }

        guard var adventurer = gameState.allAdventurers[adventurerId] else {
            return .failure(.adventurerNotFound)
        }

        // Remove from roster
        guild.rosterIDs.removeAll { $0 == adventurerId }

        // Update adventurer status
        adventurer.contractStatus = .freeAgent
        adventurer.currentGuildID = nil
        gameState.allAdventurers[adventurerId] = adventurer

        // Return to free agent pool
        gameState.freeAgents.append(adventurerId)

        // Log event
        gameState.addEvent(
            .adventurerDismissed,
            message: "\(adventurer.fullName) has left the guild.",
            relatedEntityID: adventurerId
        )

        return .success(adventurer)
    }

    // MARK: - Queries

    /// Get all available free agents sorted by value
    static func availableFreeAgents(in gameState: GameState) -> [Adventurer] {
        gameState.freeAgentAdventurers.sorted { $0.estimatedValue > $1.estimatedValue }
    }

    /// Check if guild can afford to hire an adventurer
    static func canAfford(
        _ adventurer: Adventurer,
        guild: Guild
    ) -> Bool {
        guild.finances.treasury >= adventurer.estimatedValue
    }

    /// Get adventurers the guild can afford
    static func affordableAdventurers(
        in gameState: GameState,
        for guild: Guild
    ) -> [Adventurer] {
        gameState.freeAgentAdventurers.filter { canAfford($0, guild: guild) }
    }
}

// MARK: - Result Types

enum HireResult {
    case success(Adventurer)
    case failure(HireError)

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

enum HireError: Error {
    case adventurerNotFound
    case notFreeAgent
    case noRosterSpace
    case insufficientFunds

    var message: String {
        switch self {
        case .adventurerNotFound:
            return "Adventurer not found"
        case .notFreeAgent:
            return "Adventurer is not available for hire"
        case .noRosterSpace:
            return "No space in guild roster"
        case .insufficientFunds:
            return "Insufficient funds in treasury"
        }
    }
}

enum DismissResult {
    case success(Adventurer)
    case failure(DismissError)

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

enum DismissError: Error {
    case adventurerNotFound
    case notInRoster

    var message: String {
        switch self {
        case .adventurerNotFound:
            return "Adventurer not found"
        case .notInRoster:
            return "Adventurer is not in guild roster"
        }
    }
}
