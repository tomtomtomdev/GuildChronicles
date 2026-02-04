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

        // Record initial events
        game.addEvent(.guildFounded, message: "\(guildName) has been founded!", relatedEntityID: guild.id)

        // Generate initial available quests
        game.availableQuests = QuestService.generateAvailableQuests(for: guild, count: 8)

        self.gameState = game
        self.playerGuild = guild

        isLoading = false
        enterGame()
    }

    func showError(_ message: String) {
        alertMessage = message
        showingAlert = true
    }

    // MARK: - Time Progression

    func advanceWeek() {
        guard let gameState = gameState,
              var guild = playerGuild else { return }

        TimeService.advanceWeek(gameState: gameState, guild: &guild)

        // Process active quests (simulate completion for quests that have been active)
        processActiveQuests(guild: &guild)

        playerGuild = guild

        // Haptic feedback
        HapticService.weekAdvanced()
    }

    // MARK: - Quest Management

    func acceptQuest(questId: UUID, partyMemberIds: Set<UUID>) -> Bool {
        guard let gameState = gameState,
              var guild = playerGuild,
              let questIndex = gameState.availableQuests.firstIndex(where: { $0.id == questId }) else {
            return false
        }

        var quest = gameState.availableQuests[questIndex]

        // Create party using factory method
        let party = QuestParty.create(adventurerIDs: Array(partyMemberIds))

        // Mark adventurers as fatigued while on quest
        for adventurerId in partyMemberIds {
            if var adventurer = gameState.allAdventurers[adventurerId] {
                adventurer.currentCondition = .fatigued
                gameState.allAdventurers[adventurerId] = adventurer
            }
        }

        // Accept through service
        let result = QuestService.acceptQuest(
            &quest,
            party: party,
            guild: &guild,
            gameState: gameState
        )

        switch result {
        case .success:
            // Move quest from available to active
            gameState.availableQuests.remove(at: questIndex)

            // Store the party with the quest
            var activeQuest = quest
            activeQuest.status = .inProgress
            gameState.activeQuests.append(activeQuest)

            // Store party mapping
            questParties[quest.id] = party

            playerGuild = guild

            // Haptic feedback
            HapticService.questAccepted()
            return true

        case .failure(let error):
            showError(error.message)
            HapticService.error()
            return false
        }
    }

    /// Party assignments for active quests
    var questParties: [UUID: QuestParty] = [:]

    /// Get the party assigned to a quest
    func getParty(for questId: UUID) -> QuestParty? {
        questParties[questId]
    }

    /// Process active quests - simulate completion based on time elapsed
    private func processActiveQuests(guild: inout Guild) {
        guard let gameState = gameState else { return }

        var completedIndices: [Int] = []

        for (index, quest) in gameState.activeQuests.enumerated() {
            // Simulate quest after 1 week of being active
            guard let party = questParties[quest.id] else { continue }

            let adventurers = party.adventurerIDs.compactMap { gameState.allAdventurers[$0] }

            // Run simulation
            let result = QuestExecutionService.simulateQuest(
                quest: quest,
                party: party,
                adventurers: adventurers,
                difficulty: gameState.settings.difficultyLevel
            )

            // Apply results
            var mutableQuest = quest
            QuestExecutionService.applyQuestResults(
                quest: &mutableQuest,
                result: result,
                party: party,
                guild: &guild,
                gameState: gameState
            )

            // Mark adventurers as healthy again (unless injured by quest)
            for adventurerId in party.adventurerIDs {
                if var adventurer = gameState.allAdventurers[adventurerId] {
                    // Only reset to healthy if not injured during quest
                    if adventurer.currentCondition == .fatigued {
                        adventurer.currentCondition = .healthy
                    }
                    gameState.allAdventurers[adventurerId] = adventurer
                }
            }

            // Move to completed quests
            gameState.completedQuests.append(mutableQuest)
            completedIndices.append(index)

            // Remove party mapping
            questParties.removeValue(forKey: quest.id)
        }

        // Remove completed quests from active list (in reverse to maintain indices)
        for index in completedIndices.reversed() {
            gameState.activeQuests.remove(at: index)
        }

        // Replenish available quests if needed
        if gameState.availableQuests.count < 5 {
            let newQuests = QuestService.generateAvailableQuests(
                for: guild,
                count: 8 - gameState.availableQuests.count
            )
            gameState.availableQuests.append(contentsOf: newQuests)
        }
    }

    /// Calculate success chance for a party on a quest
    func calculateSuccessChance(quest: Quest, partyMemberIds: Set<UUID>) -> Double {
        guard let gameState = gameState else { return 0 }

        let adventurers = partyMemberIds.compactMap { gameState.allAdventurers[$0] }
        guard !adventurers.isEmpty else { return 0 }

        let party = QuestParty.create(adventurerIDs: Array(partyMemberIds))

        let result = QuestExecutionService.simulateQuest(
            quest: quest,
            party: party,
            adventurers: adventurers,
            difficulty: gameState.settings.difficultyLevel
        )

        return result.successChance
    }

    /// Check if an adventurer is currently on an active quest
    func isAdventurerOnQuest(_ adventurerId: UUID) -> Bool {
        for party in questParties.values {
            if party.adventurerIDs.contains(adventurerId) {
                return true
            }
        }
        return false
    }

    // MARK: - Save/Load

    /// Save current game
    func saveGame(name: String? = nil) -> Bool {
        guard let gameState = gameState, let guild = playerGuild else {
            showError("No active game to save")
            return false
        }

        let saveName = name ?? "save_\(guild.name.replacingOccurrences(of: " ", with: "_"))"

        do {
            try SaveManager.saveGame(
                name: saveName,
                gameState: gameState,
                guild: guild,
                questParties: questParties
            )
            return true
        } catch {
            showError("Failed to save game: \(error.localizedDescription)")
            return false
        }
    }

    /// Quick save
    func quickSave() -> Bool {
        guard let gameState = gameState, let guild = playerGuild else {
            showError("No active game to save")
            return false
        }

        do {
            try SaveManager.quickSave(
                gameState: gameState,
                guild: guild,
                questParties: questParties
            )
            HapticService.gameSaved()
            return true
        } catch {
            showError("Failed to quick save: \(error.localizedDescription)")
            HapticService.error()
            return false
        }
    }

    /// Load a saved game
    func loadGame(name: String) -> Bool {
        do {
            let (loadedGameState, loadedGuild, loadedParties) = try SaveManager.loadGame(name: name)

            self.gameState = loadedGameState
            self.playerGuild = loadedGuild
            self.questParties = loadedParties

            enterGame()
            return true
        } catch {
            showError("Failed to load game: \(error.localizedDescription)")
            return false
        }
    }

    /// Get list of saved games
    var savedGames: [SaveInfo] {
        SaveManager.listSavedGames()
    }

    /// Delete a saved game
    func deleteSave(name: String) -> Bool {
        do {
            try SaveManager.deleteSave(name: name)
            return true
        } catch {
            showError("Failed to delete save: \(error.localizedDescription)")
            return false
        }
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
