//
//  GameEvent.swift
//  GuildChronicles
//
//  Event tracking for game history and UI display
//

import Foundation
import SwiftUI

/// A game event for history tracking and display
struct GameEvent: Identifiable, Codable {
    let id: UUID
    let type: EventType
    let message: String
    let timestamp: GameTimestamp
    let relatedEntityID: UUID?

    init(
        type: EventType,
        message: String,
        timestamp: GameTimestamp,
        relatedEntityID: UUID? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.message = message
        self.timestamp = timestamp
        self.relatedEntityID = relatedEntityID
    }
}

// MARK: - Event Types

enum EventType: String, Codable, CaseIterable {
    // Guild events
    case guildFounded
    case guildUpgraded
    case facilityUpgraded
    case facilityDamaged

    // Roster events
    case adventurerHired
    case adventurerDismissed
    case adventurerInjured
    case adventurerRecovered
    case adventurerDied
    case adventurerLevelUp

    // Staff events
    case staffHired
    case staffDismissed

    // Quest events
    case questAccepted
    case questCompleted
    case questFailed
    case questAbandoned

    // Financial events
    case incomeReceived
    case expensePaid
    case loanTaken
    case loanRepaid
    case treasuryLow

    // Council events
    case patronHappy
    case patronUnhappy
    case ultimatumIssued
    case voteOfConfidence

    // Time events
    case weekAdvanced
    case monthChanged
    case seasonChanged

    var icon: String {
        switch self {
        case .guildFounded: return "flag.fill"
        case .guildUpgraded: return "crown.fill"
        case .facilityUpgraded: return "hammer.fill"
        case .facilityDamaged: return "exclamationmark.triangle.fill"
        case .adventurerHired: return "person.badge.plus"
        case .adventurerDismissed: return "person.badge.minus"
        case .adventurerInjured: return "bandage.fill"
        case .adventurerRecovered: return "heart.fill"
        case .adventurerDied: return "xmark.circle.fill"
        case .adventurerLevelUp: return "arrow.up.circle.fill"
        case .staffHired: return "person.badge.key.fill"
        case .staffDismissed: return "person.badge.key"
        case .questAccepted: return "scroll.fill"
        case .questCompleted: return "checkmark.seal.fill"
        case .questFailed: return "xmark.seal.fill"
        case .questAbandoned: return "escape"
        case .incomeReceived: return "plus.circle.fill"
        case .expensePaid: return "minus.circle.fill"
        case .loanTaken: return "banknote.fill"
        case .loanRepaid: return "checkmark.circle.fill"
        case .treasuryLow: return "exclamationmark.triangle.fill"
        case .patronHappy: return "face.smiling.fill"
        case .patronUnhappy: return "face.dashed.fill"
        case .ultimatumIssued: return "exclamationmark.octagon.fill"
        case .voteOfConfidence: return "hand.thumbsup.fill"
        case .weekAdvanced: return "calendar"
        case .monthChanged: return "calendar.badge.clock"
        case .seasonChanged: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .guildFounded, .guildUpgraded, .facilityUpgraded:
            return .purple
        case .facilityDamaged, .adventurerInjured, .adventurerDied, .questFailed, .treasuryLow, .patronUnhappy, .ultimatumIssued:
            return .red
        case .adventurerHired, .staffHired, .questAccepted:
            return .blue
        case .adventurerDismissed, .staffDismissed, .questAbandoned:
            return .orange
        case .adventurerRecovered, .questCompleted, .incomeReceived, .loanRepaid, .patronHappy, .voteOfConfidence:
            return .green
        case .adventurerLevelUp:
            return .yellow
        case .expensePaid, .loanTaken:
            return .orange
        case .weekAdvanced, .monthChanged, .seasonChanged:
            return .cyan
        }
    }
}

// MARK: - Game Timestamp

struct GameTimestamp: Codable, Equatable {
    let season: Int
    let month: Int
    let week: Int

    var displayString: String {
        "Season \(season), Month \(month)"
    }

    var shortDisplay: String {
        "S\(season)M\(month)"
    }
}
