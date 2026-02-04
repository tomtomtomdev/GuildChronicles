//
//  HapticService.swift
//  GuildChronicles
//
//  Provides haptic feedback for game interactions
//

import UIKit

/// Service for providing haptic feedback
enum HapticService {

    // MARK: - Impact Feedback

    /// Light impact for subtle UI interactions
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact for standard interactions
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy impact for significant actions
    static func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft impact for gentle feedback
    static func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Rigid impact for firm feedback
    static func rigidImpact() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success feedback for completed actions
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning feedback for cautionary states
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error feedback for failed actions
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection feedback for picker/selection changes
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Game-Specific Feedback

    /// Feedback for advancing week
    static func weekAdvanced() {
        mediumImpact()
    }

    /// Feedback for quest acceptance
    static func questAccepted() {
        lightImpact()
    }

    /// Feedback for quest completion based on outcome
    static func questCompleted(outcome: QuestOutcome) {
        switch outcome {
        case .perfectVictory:
            // Double tap for perfect victory
            heavyImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                heavyImpact()
            }
        case .success:
            success()
        case .partialSuccess:
            mediumImpact()
        case .failure:
            warning()
        case .catastrophicFailure:
            error()
        }
    }

    /// Feedback for level up
    static func levelUp() {
        // Triple tap pattern for level up celebration
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            mediumImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            success()
        }
    }

    /// Feedback for loot obtained
    static func lootObtained(rarity: ItemRarity) {
        switch rarity {
        case .common:
            lightImpact()
        case .uncommon:
            softImpact()
        case .rare:
            mediumImpact()
        case .epic:
            heavyImpact()
        case .legendary:
            // Special pattern for legendary items
            rigidImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                success()
            }
        }
    }

    /// Feedback for hiring adventurer
    static func adventurerHired() {
        success()
    }

    /// Feedback for dismissing adventurer
    static func adventurerDismissed() {
        warning()
    }

    /// Feedback for adventurer injury
    static func adventurerInjured() {
        error()
    }

    /// Feedback for saving game
    static func gameSaved() {
        success()
    }

    /// Feedback for button press
    static func buttonPressed() {
        lightImpact()
    }

    /// Feedback for navigation
    static func navigation() {
        selectionChanged()
    }

    /// Feedback for receiving gold
    static func goldReceived() {
        lightImpact()
    }

    /// Feedback for treasury warning
    static func treasuryWarning() {
        warning()
    }
}
