//
//  LootTable.swift
//  GuildChronicles
//
//  Loot generation system for quest rewards (Sprint 1.4)
//

import Foundation

/// A weighted entry in a loot table
struct LootEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var itemTemplateID: UUID?  // Specific item
    var itemCategory: ItemCategory?  // Category to pick from
    var itemRarity: ItemRarity?  // Override rarity
    var weight: Int  // Higher = more likely
    var minQuantity: Int
    var maxQuantity: Int
    var guaranteedDrop: Bool

    var isSpecificItem: Bool {
        itemTemplateID != nil
    }

    var isCategoryDrop: Bool {
        itemCategory != nil
    }

    var quantityRange: ClosedRange<Int> {
        minQuantity...maxQuantity
    }

    static func specific(itemID: UUID, weight: Int = 10, quantity: Int = 1) -> LootEntry {
        LootEntry(
            id: UUID(),
            itemTemplateID: itemID,
            itemCategory: nil,
            itemRarity: nil,
            weight: weight,
            minQuantity: quantity,
            maxQuantity: quantity,
            guaranteedDrop: false
        )
    }

    static func category(_ category: ItemCategory, rarity: ItemRarity? = nil, weight: Int = 10) -> LootEntry {
        LootEntry(
            id: UUID(),
            itemTemplateID: nil,
            itemCategory: category,
            itemRarity: rarity,
            weight: weight,
            minQuantity: 1,
            maxQuantity: 1,
            guaranteedDrop: false
        )
    }

    static func guaranteed(itemID: UUID, quantity: Int = 1) -> LootEntry {
        LootEntry(
            id: UUID(),
            itemTemplateID: itemID,
            itemCategory: nil,
            itemRarity: nil,
            weight: 100,
            minQuantity: quantity,
            maxQuantity: quantity,
            guaranteedDrop: true
        )
    }
}

/// A loot table defining possible drops
struct LootTable: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var tier: LootTableTier

    // Entries
    var entries: [LootEntry]

    // Gold rewards
    var minGold: Int
    var maxGold: Int
    var goldDropChance: Double  // 0.0 to 1.0

    // Roll configuration
    var minDrops: Int
    var maxDrops: Int
    var allowDuplicates: Bool

    // MARK: - Computed Properties

    var guaranteedEntries: [LootEntry] {
        entries.filter { $0.guaranteedDrop }
    }

    var randomEntries: [LootEntry] {
        entries.filter { !$0.guaranteedDrop }
    }

    var totalWeight: Int {
        randomEntries.reduce(0) { $0 + $1.weight }
    }

    var goldRange: ClosedRange<Int> {
        minGold...maxGold
    }

    var dropRange: ClosedRange<Int> {
        minDrops...maxDrops
    }

    // MARK: - Factory

    static func create(
        name: String,
        description: String = "",
        tier: LootTableTier,
        entries: [LootEntry],
        minGold: Int = 0,
        maxGold: Int = 100,
        minDrops: Int = 1,
        maxDrops: Int = 3
    ) -> LootTable {
        LootTable(
            id: UUID(),
            name: name,
            description: description,
            tier: tier,
            entries: entries,
            minGold: minGold,
            maxGold: maxGold,
            goldDropChance: 1.0,
            minDrops: minDrops,
            maxDrops: maxDrops,
            allowDuplicates: false
        )
    }
}

/// Tier of loot table affecting item quality
enum LootTableTier: String, Codable, CaseIterable, Comparable {
    case poor
    case common
    case uncommon
    case rare
    case epic
    case legendary

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var maxRarity: ItemRarity {
        switch self {
        case .poor: return .common
        case .common: return .uncommon
        case .uncommon: return .rare
        case .rare: return .rare
        case .epic: return .epic
        case .legendary: return .legendary
        }
    }

    var goldMultiplier: Double {
        switch self {
        case .poor: return 0.5
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.5
        case .epic: return 5.0
        case .legendary: return 10.0
        }
    }

    var rarityWeights: [ItemRarity: Int] {
        switch self {
        case .poor:
            return [.common: 95, .uncommon: 5]
        case .common:
            return [.common: 70, .uncommon: 25, .rare: 5]
        case .uncommon:
            return [.common: 40, .uncommon: 40, .rare: 18, .epic: 2]
        case .rare:
            return [.common: 20, .uncommon: 35, .rare: 35, .epic: 9, .legendary: 1]
        case .epic:
            return [.uncommon: 20, .rare: 40, .epic: 35, .legendary: 5]
        case .legendary:
            return [.rare: 25, .epic: 50, .legendary: 25]
        }
    }

    static func < (lhs: LootTableTier, rhs: LootTableTier) -> Bool {
        let order: [LootTableTier] = [.poor, .common, .uncommon, .rare, .epic, .legendary]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Loot Generation Result

/// Result of rolling on a loot table
struct LootRoll: Codable, Equatable {
    var goldAmount: Int
    var itemIDs: [UUID]  // Items generated
    var sourceTableID: UUID
    var rolledAt: Date

    var isEmpty: Bool {
        goldAmount == 0 && itemIDs.isEmpty
    }

    var itemCount: Int {
        itemIDs.count
    }

    static var empty: LootRoll {
        LootRoll(goldAmount: 0, itemIDs: [], sourceTableID: UUID(), rolledAt: Date())
    }
}

// MARK: - Predefined Loot Tables

extension LootTable {
    /// Common chest loot
    static var commonChest: LootTable {
        LootTable.create(
            name: "Common Chest",
            description: "Basic treasure chest contents",
            tier: .common,
            entries: [
                .category(.consumable, weight: 30),
                .category(.valuable, weight: 25),
                .category(.weapon, rarity: .common, weight: 20),
                .category(.armor, rarity: .common, weight: 20),
                .category(.accessory, rarity: .common, weight: 5)
            ],
            minGold: 10,
            maxGold: 50,
            minDrops: 1,
            maxDrops: 2
        )
    }

    /// Rare chest loot
    static var rareChest: LootTable {
        LootTable.create(
            name: "Rare Chest",
            description: "Valuable treasure chest contents",
            tier: .rare,
            entries: [
                .category(.weapon, rarity: .rare, weight: 25),
                .category(.armor, rarity: .rare, weight: 25),
                .category(.accessory, rarity: .rare, weight: 20),
                .category(.consumable, weight: 15),
                .category(.valuable, weight: 15)
            ],
            minGold: 100,
            maxGold: 500,
            minDrops: 2,
            maxDrops: 4
        )
    }

    /// Boss loot
    static var bossLoot: LootTable {
        LootTable.create(
            name: "Boss Loot",
            description: "Rewards from defeating a boss",
            tier: .epic,
            entries: [
                .category(.weapon, rarity: .epic, weight: 30),
                .category(.armor, rarity: .epic, weight: 30),
                .category(.accessory, rarity: .rare, weight: 20),
                .category(.consumable, weight: 20)
            ],
            minGold: 500,
            maxGold: 2000,
            minDrops: 3,
            maxDrops: 5
        )
    }

    /// Quest completion reward
    static func questReward(for stakes: QuestStakes) -> LootTable {
        let tier: LootTableTier = {
            switch stakes {
            case .low: return .common
            case .medium: return .uncommon
            case .high: return .rare
            case .critical: return .epic
            }
        }()

        let goldMultiplier: Int = {
            switch stakes {
            case .low: return 1
            case .medium: return 2
            case .high: return 4
            case .critical: return 8
            }
        }()

        return LootTable.create(
            name: "\(stakes.displayName) Quest Reward",
            description: "Rewards for completing a \(stakes.displayName.lowercased()) stakes quest",
            tier: tier,
            entries: [
                .category(.weapon, weight: 20),
                .category(.armor, weight: 20),
                .category(.accessory, weight: 15),
                .category(.consumable, weight: 25),
                .category(.valuable, weight: 20)
            ],
            minGold: 25 * goldMultiplier,
            maxGold: 100 * goldMultiplier,
            minDrops: 1 + (stakes == .critical ? 1 : 0),
            maxDrops: 2 + goldMultiplier / 2
        )
    }
}

// MARK: - Guild Inventory

/// The guild's storage of items
struct GuildInventory: Codable, Equatable {
    var gold: Int
    var items: [ItemStack]
    var weapons: [UUID: Weapon]  // Weapon ID -> Weapon
    var armors: [UUID: Armor]    // Armor ID -> Armor
    var accessories: [UUID: Accessory]  // Accessory ID -> Accessory
    var consumables: [UUID: Consumable]  // Consumable ID -> Consumable
    var questItems: [UUID: QuestItem]  // Quest Item ID -> Item
    var valuables: [UUID: Valuable]  // Valuable ID -> Valuable

    var totalItems: Int {
        weapons.count + armors.count + accessories.count +
        consumables.count + questItems.count + valuables.count
    }

    var totalValue: Int {
        var value = gold
        value += weapons.values.reduce(0) { $0 + $1.baseItem.effectiveValue }
        value += armors.values.reduce(0) { $0 + $1.baseItem.effectiveValue }
        value += accessories.values.reduce(0) { $0 + $1.baseItem.effectiveValue }
        value += valuables.values.reduce(0) { $0 + $1.actualValue }
        return value
    }

    mutating func addGold(_ amount: Int) {
        gold += amount
    }

    mutating func removeGold(_ amount: Int) -> Bool {
        guard gold >= amount else { return false }
        gold -= amount
        return true
    }

    mutating func addWeapon(_ weapon: Weapon) {
        weapons[weapon.id] = weapon
    }

    mutating func addArmor(_ armor: Armor) {
        armors[armor.id] = armor
    }

    mutating func addAccessory(_ accessory: Accessory) {
        accessories[accessory.id] = accessory
    }

    mutating func addConsumable(_ consumable: Consumable) {
        consumables[consumable.id] = consumable
    }

    static var empty: GuildInventory {
        GuildInventory(
            gold: 0,
            items: [],
            weapons: [:],
            armors: [:],
            accessories: [:],
            consumables: [:],
            questItems: [:],
            valuables: [:]
        )
    }

    static var starter: GuildInventory {
        var inventory = GuildInventory.empty
        inventory.gold = 500

        // Starter weapons
        inventory.addWeapon(Weapon.create(
            name: "Iron Sword",
            description: "A basic iron sword",
            type: .sword,
            baseValue: 50
        ))
        inventory.addWeapon(Weapon.create(
            name: "Hunting Bow",
            description: "A reliable hunting bow",
            type: .bow,
            baseValue: 40
        ))

        // Starter armor
        inventory.addArmor(Armor.create(
            name: "Leather Vest",
            description: "A worn leather vest",
            type: .leather,
            slot: .chest,
            baseValue: 30
        ))

        return inventory
    }
}
