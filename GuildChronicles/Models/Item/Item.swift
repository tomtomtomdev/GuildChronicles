//
//  Item.swift
//  GuildChronicles
//
//  Base item model and types (Sprint 1.4)
//

import Foundation

/// Item rarity levels
enum ItemRarity: String, Codable, CaseIterable, Comparable {
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var valueMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 2.0
        case .rare: return 5.0
        case .epic: return 15.0
        case .legendary: return 50.0
        }
    }

    var dropWeight: Int {
        switch self {
        case .common: return 60
        case .uncommon: return 25
        case .rare: return 10
        case .epic: return 4
        case .legendary: return 1
        }
    }

    static func < (lhs: ItemRarity, rhs: ItemRarity) -> Bool {
        let order: [ItemRarity] = [.common, .uncommon, .rare, .epic, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

/// High-level item categories
enum ItemCategory: String, Codable, CaseIterable {
    case weapon
    case armor
    case accessory
    case consumable
    case questItem
    case valuable

    var displayName: String {
        switch self {
        case .weapon: return "Weapon"
        case .armor: return "Armor"
        case .accessory: return "Accessory"
        case .consumable: return "Consumable"
        case .questItem: return "Quest Item"
        case .valuable: return "Valuable"
        }
    }

    var canBeEquipped: Bool {
        switch self {
        case .weapon, .armor, .accessory: return true
        case .consumable, .questItem, .valuable: return false
        }
    }
}

/// Base item model
struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var category: ItemCategory
    var rarity: ItemRarity
    var baseValue: Int
    var weight: Double  // In pounds
    var isStackable: Bool
    var maxStackSize: Int
    var iconName: String?

    // MARK: - Computed Properties

    var effectiveValue: Int {
        Int(Double(baseValue) * rarity.valueMultiplier)
    }

    var isEquippable: Bool {
        category.canBeEquipped
    }

    // MARK: - Factory

    static func create(
        name: String,
        description: String,
        category: ItemCategory,
        rarity: ItemRarity = .common,
        baseValue: Int,
        weight: Double = 1.0,
        isStackable: Bool = false,
        maxStackSize: Int = 1
    ) -> Item {
        Item(
            id: UUID(),
            name: name,
            description: description,
            category: category,
            rarity: rarity,
            baseValue: baseValue,
            weight: weight,
            isStackable: isStackable,
            maxStackSize: maxStackSize,
            iconName: nil
        )
    }
}

/// A stack of items in inventory
struct ItemStack: Identifiable, Codable, Equatable {
    let id: UUID
    let itemID: UUID
    var quantity: Int

    var isEmpty: Bool {
        quantity <= 0
    }

    static func single(_ itemID: UUID) -> ItemStack {
        ItemStack(id: UUID(), itemID: itemID, quantity: 1)
    }

    static func stack(_ itemID: UUID, quantity: Int) -> ItemStack {
        ItemStack(id: UUID(), itemID: itemID, quantity: quantity)
    }
}

/// A valuable/treasure item with gold value
struct Valuable: Codable, Equatable {
    let baseItem: Item
    var condition: ItemCondition
    var appraisedValue: Int?

    var displayValue: Int {
        appraisedValue ?? baseItem.effectiveValue
    }

    var actualValue: Int {
        let base = baseItem.effectiveValue
        return Int(Double(base) * condition.valueMultiplier)
    }

    static func treasure(name: String, description: String, value: Int, rarity: ItemRarity = .uncommon) -> Valuable {
        Valuable(
            baseItem: Item.create(
                name: name,
                description: description,
                category: .valuable,
                rarity: rarity,
                baseValue: value,
                weight: 0.5
            ),
            condition: .pristine,
            appraisedValue: nil
        )
    }
}

/// Item condition affecting value
enum ItemCondition: String, Codable, CaseIterable {
    case broken
    case poor
    case worn
    case average
    case good
    case pristine

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var valueMultiplier: Double {
        switch self {
        case .broken: return 0.1
        case .poor: return 0.4
        case .worn: return 0.7
        case .average: return 1.0
        case .good: return 1.15
        case .pristine: return 1.3
        }
    }

    var effectivenessMultiplier: Double {
        switch self {
        case .broken: return 0.0
        case .poor: return 0.5
        case .worn: return 0.8
        case .average: return 1.0
        case .good: return 1.0
        case .pristine: return 1.0
        }
    }
}

/// Quest-specific item
struct QuestItem: Codable, Equatable {
    let baseItem: Item
    var questChainID: UUID?
    var questID: UUID?
    var isKeyItem: Bool
    var canBeDropped: Bool

    static func create(
        name: String,
        description: String,
        forQuestChain chainID: UUID? = nil,
        forQuest questID: UUID? = nil,
        isKeyItem: Bool = true
    ) -> QuestItem {
        QuestItem(
            baseItem: Item.create(
                name: name,
                description: description,
                category: .questItem,
                rarity: .rare,
                baseValue: 0,
                weight: 0.1
            ),
            questChainID: chainID,
            questID: questID,
            isKeyItem: isKeyItem,
            canBeDropped: !isKeyItem
        )
    }
}
