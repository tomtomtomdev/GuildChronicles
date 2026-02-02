//
//  AppState.swift
//  GuildChronicles
//
//  Application-level state management
//

import SwiftUI

/// Application navigation and game state container
@Observable
final class AppState {
    // MARK: - Navigation
    var currentScreen: AppScreen = .mainMenu
    var selectedTab: MainTab = .dashboard

    // MARK: - Game State
    var gameState: GameState?
    var playerGuild: Guild?

    // MARK: - UI State
    var isLoading: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""

    // MARK: - Computed

    var hasActiveGame: Bool {
        gameState != nil && playerGuild != nil
    }

    var currentSeasonDisplay: String {
        guard let game = gameState else { return "" }
        return "Season \(game.currentSeason), \(game.seasonPhase.displayName)"
    }

    var treasuryDisplay: String {
        guard let guild = playerGuild else { return "0 gold" }
        return "\(guild.finances.treasury) gold"
    }

    // MARK: - Navigation Actions

    func startNewCampaign() {
        currentScreen = .newCampaign
    }

    func returnToMainMenu() {
        currentScreen = .mainMenu
    }

    func enterGame() {
        guard hasActiveGame else { return }
        currentScreen = .mainGame
    }

    func showSettings() {
        currentScreen = .settings
    }

    // MARK: - Game Actions

    func createNewGame(
        campaignName: String,
        guildName: String,
        motto: String,
        homeRealm: Realm,
        settings: GameSettings
    ) {
        isLoading = true

        // Create game state
        let game = GameState()
        game.campaignName = campaignName
        game.settings = settings
        game.generateInitialFreeAgents(count: 50)

        // Create player guild
        let guild = Guild.create(
            name: guildName,
            motto: motto,
            homeRealm: homeRealm,
            homeRegion: homeRealm.regions.first ?? "Unknown",
            tier: .fledgling,
            isPlayerControlled: true
        )

        // Link them
        game.playerGuildID = guild.id

        self.gameState = game
        self.playerGuild = guild

        isLoading = false
        enterGame()
    }

    func showError(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - Navigation Types

enum AppScreen: Equatable {
    case mainMenu
    case newCampaign
    case settings
    case mainGame
}

enum MainTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case roster = "Roster"
    case quests = "Quests"
    case guild = "Guild"
    case inventory = "Inventory"

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .roster: return "person.3.fill"
        case .quests: return "scroll.fill"
        case .guild: return "building.columns.fill"
        case .inventory: return "bag.fill"
        }
    }
}
