//
//  SaveManager.swift
//  GuildChronicles
//
//  Handles saving and loading game state
//

import Foundation

/// Service for game save/load operations
enum SaveManager {

    // MARK: - File Paths

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private static var savesDirectory: URL {
        documentsDirectory.appendingPathComponent("Saves", isDirectory: true)
    }

    private static func saveFileURL(name: String) -> URL {
        savesDirectory.appendingPathComponent("\(name).json")
    }

    // MARK: - Save Data Structure

    struct SaveData: Codable {
        let version: Int
        let savedAt: Date
        let gameState: GameStateSaveData
        let guild: Guild
        let questParties: [UUID: QuestParty]

        static let currentVersion = 1
    }

    struct GameStateSaveData: Codable {
        let campaignName: String
        let currentSeason: Int
        let currentMonth: Int
        let totalWeeksElapsed: Int
        let playerGuildID: UUID?
        let allAdventurers: [UUID: Adventurer]
        let freeAgents: [UUID]
        let availableQuests: [Quest]
        let activeQuests: [Quest]
        let completedQuests: [Quest]
        let events: [GameEvent]
        let settings: GameSettings
    }

    // MARK: - Save Operations

    /// Save current game state
    static func saveGame(
        name: String,
        gameState: GameState,
        guild: Guild,
        questParties: [UUID: QuestParty]
    ) throws {
        // Ensure saves directory exists
        try createSavesDirectoryIfNeeded()

        // Convert GameState to saveable format
        let gameStateSaveData = GameStateSaveData(
            campaignName: gameState.campaignName,
            currentSeason: gameState.currentSeason,
            currentMonth: gameState.currentMonth,
            totalWeeksElapsed: gameState.totalWeeksElapsed,
            playerGuildID: gameState.playerGuildID,
            allAdventurers: gameState.allAdventurers,
            freeAgents: gameState.freeAgents,
            availableQuests: gameState.availableQuests,
            activeQuests: gameState.activeQuests,
            completedQuests: gameState.completedQuests,
            events: gameState.events,
            settings: gameState.settings
        )

        let saveData = SaveData(
            version: SaveData.currentVersion,
            savedAt: Date(),
            gameState: gameStateSaveData,
            guild: guild,
            questParties: questParties
        )

        // Encode and save
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(saveData)
        try data.write(to: saveFileURL(name: name))
    }

    /// Quick save with auto-generated name
    static func quickSave(
        gameState: GameState,
        guild: Guild,
        questParties: [UUID: QuestParty]
    ) throws {
        let name = "quicksave_\(guild.name.replacingOccurrences(of: " ", with: "_"))"
        try saveGame(name: name, gameState: gameState, guild: guild, questParties: questParties)
    }

    // MARK: - Load Operations

    /// Load a saved game
    static func loadGame(name: String) throws -> (GameState, Guild, [UUID: QuestParty]) {
        let url = saveFileURL(name: name)

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let saveData = try decoder.decode(SaveData.self, from: data)

        // Convert back to GameState
        let gameState = GameState()
        gameState.campaignName = saveData.gameState.campaignName
        gameState.currentSeason = saveData.gameState.currentSeason
        gameState.currentMonth = saveData.gameState.currentMonth
        gameState.totalWeeksElapsed = saveData.gameState.totalWeeksElapsed
        gameState.playerGuildID = saveData.gameState.playerGuildID
        gameState.allAdventurers = saveData.gameState.allAdventurers
        gameState.freeAgents = saveData.gameState.freeAgents
        gameState.availableQuests = saveData.gameState.availableQuests
        gameState.activeQuests = saveData.gameState.activeQuests
        gameState.completedQuests = saveData.gameState.completedQuests
        gameState.events = saveData.gameState.events
        gameState.settings = saveData.gameState.settings

        return (gameState, saveData.guild, saveData.questParties)
    }

    // MARK: - Save Management

    /// List all saved games
    static func listSavedGames() -> [SaveInfo] {
        do {
            try createSavesDirectoryIfNeeded()

            let files = try FileManager.default.contentsOfDirectory(
                at: savesDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            )

            return files.compactMap { url -> SaveInfo? in
                guard url.pathExtension == "json" else { return nil }

                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let saveData = try decoder.decode(SaveData.self, from: data)

                    return SaveInfo(
                        name: url.deletingPathExtension().lastPathComponent,
                        guildName: saveData.guild.name,
                        campaignName: saveData.gameState.campaignName,
                        season: saveData.gameState.currentSeason,
                        savedAt: saveData.savedAt
                    )
                } catch {
                    return nil
                }
            }
            .sorted { $0.savedAt > $1.savedAt }
        } catch {
            return []
        }
    }

    /// Delete a saved game
    static func deleteSave(name: String) throws {
        let url = saveFileURL(name: name)
        try FileManager.default.removeItem(at: url)
    }

    /// Check if a save exists
    static func saveExists(name: String) -> Bool {
        FileManager.default.fileExists(atPath: saveFileURL(name: name).path)
    }

    // MARK: - Private Helpers

    private static func createSavesDirectoryIfNeeded() throws {
        if !FileManager.default.fileExists(atPath: savesDirectory.path) {
            try FileManager.default.createDirectory(
                at: savesDirectory,
                withIntermediateDirectories: true
            )
        }
    }
}

// MARK: - Save Info

struct SaveInfo: Identifiable {
    let name: String
    let guildName: String
    let campaignName: String
    let season: Int
    let savedAt: Date

    var id: String { name }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: savedAt)
    }
}
