//
//  AudioService.swift
//  GuildChronicles
//
//  Provides audio feedback for game events using system sounds
//

import AudioToolbox
import AVFoundation

/// Service for playing audio feedback
enum AudioService {

    // MARK: - Audio Session Setup

    private static var isConfigured = false

    /// Configure audio session for game sounds
    static func configure() {
        guard !isConfigured else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            isConfigured = true
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - System Sounds

    /// Play a system sound by ID
    private static func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - UI Sounds

    /// Sound for button tap
    static func buttonTap() {
        // System keyboard click sound
        playSystemSound(1104)
    }

    /// Sound for navigation
    static func navigation() {
        playSystemSound(1105)
    }

    /// Sound for selection change
    static func selectionChanged() {
        playSystemSound(1306)
    }

    // MARK: - Game Event Sounds

    /// Sound for quest acceptance
    static func questAccepted() {
        // Paper/scroll sound simulation
        playSystemSound(1100)
    }

    /// Sound for quest completion based on outcome
    static func questCompleted(outcome: QuestOutcome) {
        switch outcome {
        case .perfectVictory, .success:
            // Positive confirmation sound
            playSystemSound(1025)
        case .partialSuccess:
            // Neutral sound
            playSystemSound(1057)
        case .failure:
            // Warning sound
            playSystemSound(1053)
        case .catastrophicFailure:
            // Error sound
            playSystemSound(1073)
        }
    }

    /// Sound for level up
    static func levelUp() {
        // Celebratory sound
        playSystemSound(1025)
    }

    /// Sound for loot obtained
    static func lootObtained(rarity: ItemRarity) {
        switch rarity {
        case .common, .uncommon:
            // Subtle pickup sound
            playSystemSound(1103)
        case .rare, .epic:
            // More noticeable sound
            playSystemSound(1114)
        case .legendary:
            // Special sound for legendary
            playSystemSound(1015)
        }
    }

    /// Sound for week advancement
    static func weekAdvanced() {
        // Clock/time sound
        playSystemSound(1113)
    }

    /// Sound for adventurer hired
    static func adventurerHired() {
        playSystemSound(1111)
    }

    /// Sound for adventurer dismissed
    static func adventurerDismissed() {
        playSystemSound(1112)
    }

    /// Sound for injury
    static func adventurerInjured() {
        playSystemSound(1073)
    }

    /// Sound for death
    static func adventurerDied() {
        playSystemSound(1006)
    }

    /// Sound for game saved
    static func gameSaved() {
        // Save confirmation sound
        playSystemSound(1001)
    }

    /// Sound for gold received
    static func goldReceived() {
        // Coin/payment sound
        playSystemSound(1117)
    }

    /// Sound for treasury warning
    static func treasuryWarning() {
        playSystemSound(1053)
    }

    /// Sound for error/failure
    static func error() {
        playSystemSound(1073)
    }

    /// Sound for success
    static func success() {
        playSystemSound(1025)
    }
}
