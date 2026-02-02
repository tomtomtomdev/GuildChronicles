//
//  Consumable.swift
//  GuildChronicles
//
//  Consumable items - potions, scrolls, supplies (Sprint 1.4)
//

import Foundation

/// Types of consumable items
enum ConsumableType: String, Codable, CaseIterable {
    // Potions
    case healthPotion
    case manaPotion
    case staminaPotion
    case antidote
    case elixir

    // Scrolls
    case spellScroll
    case teleportScroll
    case identifyScroll
    case enchantScroll

    // Supplies
    case rations
    case torches
    case campingGear
    case repairKit
    case lockpicks

    // Throwables
    case throwingKnife
    case alchemistFire
    case smokeBomb
    case flashBomb

    var displayName: String {
        switch self {
        case .healthPotion: return "Health Potion"
        case .manaPotion: return "Mana Potion"
        case .staminaPotion: return "Stamina Potion"
        case .antidote: return "Antidote"
        case .elixir: return "Elixir"
        case .spellScroll: return "Spell Scroll"
        case .teleportScroll: return "Teleport Scroll"
        case .identifyScroll: return "Identify Scroll"
        case .enchantScroll: return "Enchant Scroll"
        case .rations: return "Rations"
        case .torches: return "Torches"
        case .campingGear: return "Camping Gear"
        case .repairKit: return "Repair Kit"
        case .lockpicks: return "Lockpicks"
        case .throwingKnife: return "Throwing Knife"
        case .alchemistFire: return "Alchemist's Fire"
        case .smokeBomb: return "Smoke Bomb"
        case .flashBomb: return "Flash Bomb"
        }
    }

    var category: ConsumableCategory {
        switch self {
        case .healthPotion, .manaPotion, .staminaPotion, .antidote, .elixir:
            return .potion
        case .spellScroll, .teleportScroll, .identifyScroll, .enchantScroll:
            return .scroll
        case .rations, .torches, .campingGear, .repairKit, .lockpicks:
            return .supply
        case .throwingKnife, .alchemistFire, .smokeBomb, .flashBomb:
            return .throwable
        }
    }

    var isUsableInCombat: Bool {
        switch self {
        case .healthPotion, .manaPotion, .staminaPotion, .antidote,
             .throwingKnife, .alchemistFire, .smokeBomb, .flashBomb,
             .spellScroll:
            return true
        default:
            return false
        }
    }

    var defaultStackSize: Int {
        switch self {
        case .rations, .torches, .lockpicks: return 20
        case .throwingKnife: return 10
        default: return 5
        }
    }

    var baseWeight: Double {
        switch self {
        case .rations, .campingGear: return 2.0
        case .torches: return 0.5
        default: return 0.2
        }
    }
}

enum ConsumableCategory: String, Codable {
    case potion
    case scroll
    case supply
    case throwable

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

/// Quality/strength of potions
enum PotionStrength: String, Codable, CaseIterable, Comparable {
    case minor
    case lesser
    case standard
    case greater
    case superior

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var effectMultiplier: Double {
        switch self {
        case .minor: return 0.5
        case .lesser: return 0.75
        case .standard: return 1.0
        case .greater: return 1.5
        case .superior: return 2.0
        }
    }

    var valueMultiplier: Double {
        switch self {
        case .minor: return 0.3
        case .lesser: return 0.6
        case .standard: return 1.0
        case .greater: return 2.0
        case .superior: return 4.0
        }
    }

    static func < (lhs: PotionStrength, rhs: PotionStrength) -> Bool {
        let order: [PotionStrength] = [.minor, .lesser, .standard, .greater, .superior]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

/// A consumable item
struct Consumable: Identifiable, Codable, Equatable {
    let id: UUID
    let baseItem: Item
    var consumableType: ConsumableType
    var strength: PotionStrength?  // For potions
    var charges: Int  // For scrolls (1 = single use)
    var effectValue: Int  // Amount of healing, damage, etc.
    var duration: Int?  // Duration in turns/segments if applicable
    var targetAttribute: AttributeType?  // For stat-boosting consumables

    // MARK: - Computed Properties

    var category: ConsumableCategory {
        consumableType.category
    }

    var isPotion: Bool {
        category == .potion
    }

    var isScroll: Bool {
        category == .scroll
    }

    var isUsableInCombat: Bool {
        consumableType.isUsableInCombat
    }

    var effectDescription: String {
        switch consumableType {
        case .healthPotion:
            return "Restores \(effectValue) health"
        case .manaPotion:
            return "Restores \(effectValue) mana"
        case .staminaPotion:
            return "Restores \(effectValue) stamina"
        case .antidote:
            return "Cures poison and disease"
        case .elixir:
            if let attr = targetAttribute, let dur = duration {
                return "+\(effectValue) \(attr.displayName) for \(dur) turns"
            }
            return "Temporary attribute boost"
        case .spellScroll:
            return "Contains a spell (\(charges) charge\(charges == 1 ? "" : "s"))"
        case .teleportScroll:
            return "Instantly return to guild hall"
        case .identifyScroll:
            return "Identify one unknown item"
        case .enchantScroll:
            return "Add an enchantment to equipment"
        case .rations:
            return "Sustains party during travel"
        case .torches:
            return "Provides light in dark areas"
        case .campingGear:
            return "Required for rest during expeditions"
        case .repairKit:
            return "Repairs equipment by one condition level"
        case .lockpicks:
            return "+\(effectValue) to lock picking attempts"
        case .throwingKnife:
            return "Deals \(effectValue) damage at range"
        case .alchemistFire:
            return "Deals \(effectValue) fire damage in area"
        case .smokeBomb:
            return "Creates cover, allows escape"
        case .flashBomb:
            return "Blinds enemies for \(duration ?? 2) turns"
        }
    }

    // MARK: - Factory

    static func potion(
        type: ConsumableType,
        strength: PotionStrength = .standard
    ) -> Consumable {
        let baseHeal = 25
        let effectValue = Int(Double(baseHeal) * strength.effectMultiplier)
        let name = "\(strength.displayName) \(type.displayName)"

        return Consumable(
            id: UUID(),
            baseItem: Item.create(
                name: name,
                description: type.displayName,
                category: .consumable,
                rarity: strength < .greater ? .common : .uncommon,
                baseValue: Int(20.0 * strength.valueMultiplier),
                weight: 0.2,
                isStackable: true,
                maxStackSize: 10
            ),
            consumableType: type,
            strength: strength,
            charges: 1,
            effectValue: effectValue,
            duration: nil,
            targetAttribute: nil
        )
    }

    static func scroll(type: ConsumableType, charges: Int = 1) -> Consumable {
        Consumable(
            id: UUID(),
            baseItem: Item.create(
                name: type.displayName,
                description: "A magical scroll",
                category: .consumable,
                rarity: .uncommon,
                baseValue: 50 * charges,
                weight: 0.1,
                isStackable: false,
                maxStackSize: 1
            ),
            consumableType: type,
            strength: nil,
            charges: charges,
            effectValue: 0,
            duration: nil,
            targetAttribute: nil
        )
    }

    static func supply(type: ConsumableType, quantity: Int = 1) -> Consumable {
        let effectValue: Int = {
            switch type {
            case .lockpicks: return 5
            case .repairKit: return 1
            default: return 0
            }
        }()

        return Consumable(
            id: UUID(),
            baseItem: Item.create(
                name: type.displayName,
                description: type.displayName,
                category: .consumable,
                rarity: .common,
                baseValue: 5,
                weight: type.baseWeight,
                isStackable: true,
                maxStackSize: type.defaultStackSize
            ),
            consumableType: type,
            strength: nil,
            charges: 1,
            effectValue: effectValue,
            duration: nil,
            targetAttribute: nil
        )
    }

    static func throwable(type: ConsumableType) -> Consumable {
        let damage: Int = {
            switch type {
            case .throwingKnife: return 8
            case .alchemistFire: return 15
            case .smokeBomb: return 0
            case .flashBomb: return 0
            default: return 5
            }
        }()

        let duration: Int? = {
            switch type {
            case .smokeBomb: return 3
            case .flashBomb: return 2
            default: return nil
            }
        }()

        return Consumable(
            id: UUID(),
            baseItem: Item.create(
                name: type.displayName,
                description: type.displayName,
                category: .consumable,
                rarity: .common,
                baseValue: 15,
                weight: 0.3,
                isStackable: true,
                maxStackSize: 10
            ),
            consumableType: type,
            strength: nil,
            charges: 1,
            effectValue: damage,
            duration: duration,
            targetAttribute: nil
        )
    }
}
