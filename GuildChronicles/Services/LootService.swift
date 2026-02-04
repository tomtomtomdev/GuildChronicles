//
//  LootService.swift
//  GuildChronicles
//
//  Handles loot generation from quest rewards
//

import Foundation

/// Service for generating loot from quest completion
enum LootService {

    // MARK: - Loot Generation

    /// Generate loot from a quest based on outcome
    static func generateQuestLoot(
        quest: Quest,
        outcome: QuestOutcome,
        guild: inout Guild
    ) -> [GeneratedLoot] {
        // No loot on failure
        guard outcome.isSuccess else { return [] }

        var lootItems: [GeneratedLoot] = []

        // Determine loot tier based on quest stakes and outcome
        let lootTier = determineLootTier(stakes: quest.stakes, outcome: outcome)

        // Calculate drop count
        let dropCount = calculateDropCount(stakes: quest.stakes, outcome: outcome)

        // Generate items
        for _ in 0..<dropCount {
            if let loot = generateRandomItem(tier: lootTier, for: quest.type) {
                lootItems.append(loot)
                addLootToInventory(loot, guild: &guild)
            }
        }

        // Perfect victory bonus loot
        if outcome == .perfectVictory {
            if let bonusLoot = generateBonusLoot(tier: lootTier) {
                lootItems.append(bonusLoot)
                addLootToInventory(bonusLoot, guild: &guild)
            }
        }

        return lootItems
    }

    // MARK: - Tier Determination

    private static func determineLootTier(stakes: QuestStakes, outcome: QuestOutcome) -> LootTableTier {
        let baseTier: LootTableTier = {
            switch stakes {
            case .low: return .common
            case .medium: return .uncommon
            case .high: return .rare
            case .critical: return .epic
            }
        }()

        // Upgrade tier on perfect victory
        if outcome == .perfectVictory {
            switch baseTier {
            case .poor: return .common
            case .common: return .uncommon
            case .uncommon: return .rare
            case .rare: return .epic
            case .epic: return .legendary
            case .legendary: return .legendary
            }
        }

        // Downgrade tier on partial success
        if outcome == .partialSuccess {
            switch baseTier {
            case .poor: return .poor
            case .common: return .poor
            case .uncommon: return .common
            case .rare: return .uncommon
            case .epic: return .rare
            case .legendary: return .epic
            }
        }

        return baseTier
    }

    private static func calculateDropCount(stakes: QuestStakes, outcome: QuestOutcome) -> Int {
        let baseCount: Int = {
            switch stakes {
            case .low: return 1
            case .medium: return Int.random(in: 1...2)
            case .high: return Int.random(in: 1...3)
            case .critical: return Int.random(in: 2...4)
            }
        }()

        // Modifier based on outcome
        let modifier: Int = {
            switch outcome {
            case .perfectVictory: return 1
            case .success: return 0
            case .partialSuccess: return -1
            case .failure, .catastrophicFailure: return -baseCount
            }
        }()

        return max(0, baseCount + modifier)
    }

    // MARK: - Item Generation

    private static func generateRandomItem(tier: LootTableTier, for questType: QuestType) -> GeneratedLoot? {
        // Weighted random category selection based on quest type
        let category = randomCategory(for: questType)
        let rarity = randomRarity(for: tier)

        switch category {
        case .weapon:
            return generateWeapon(rarity: rarity)
        case .armor:
            return generateArmor(rarity: rarity)
        case .accessory:
            return generateAccessory(rarity: rarity)
        case .consumable:
            return generateConsumable(rarity: rarity)
        default:
            return generateValuable(tier: tier)
        }
    }

    private static func randomCategory(for questType: QuestType) -> ItemCategory {
        let weights: [ItemCategory: Int] = {
            switch questType {
            case .combat, .assassination:
                return [.weapon: 35, .armor: 30, .consumable: 20, .valuable: 15]
            case .exploration, .retrieval:
                return [.valuable: 40, .consumable: 25, .weapon: 20, .armor: 15]
            case .defense, .siege:
                return [.armor: 40, .weapon: 30, .consumable: 20, .valuable: 10]
            case .ritual:
                return [.accessory: 35, .consumable: 30, .valuable: 25, .weapon: 10]
            default:
                return [.valuable: 30, .consumable: 30, .weapon: 20, .armor: 20]
            }
        }()

        return weightedRandom(from: weights) ?? .valuable
    }

    private static func randomRarity(for tier: LootTableTier) -> ItemRarity {
        return weightedRandom(from: tier.rarityWeights) ?? .common
    }

    private static func weightedRandom<T>(from weights: [T: Int]) -> T? {
        let total = weights.values.reduce(0, +)
        guard total > 0 else { return nil }

        var roll = Int.random(in: 0..<total)
        for (item, weight) in weights {
            roll -= weight
            if roll < 0 {
                return item
            }
        }
        return weights.keys.first
    }

    // MARK: - Specific Item Generators

    private static func generateWeapon(rarity: ItemRarity) -> GeneratedLoot {
        let type = WeaponType.allCases.randomElement()!
        let name = generateWeaponName(type: type, rarity: rarity)
        let baseValue = calculateItemValue(rarity: rarity, baseValue: 50)

        let weapon = Weapon.create(
            name: name,
            description: "A \(rarity.displayName.lowercased()) quality \(type.displayName.lowercased())",
            type: type,
            rarity: rarity,
            baseValue: baseValue
        )

        return .weapon(weapon)
    }

    private static func generateArmor(rarity: ItemRarity) -> GeneratedLoot {
        let armorType = ArmorType.allCases.randomElement()!
        let slot = EquipmentSlot.allCases.filter { $0.isArmorSlot }.randomElement()!
        let name = generateArmorName(type: armorType, slot: slot, rarity: rarity)
        let baseValue = calculateItemValue(rarity: rarity, baseValue: 40)

        let armor = Armor.create(
            name: name,
            description: "A \(rarity.displayName.lowercased()) quality \(armorType.displayName.lowercased()) piece",
            type: armorType,
            slot: slot,
            rarity: rarity,
            baseValue: baseValue
        )

        return .armor(armor)
    }

    private static func generateAccessory(rarity: ItemRarity) -> GeneratedLoot {
        let type = AccessoryType.allCases.randomElement()!
        let name = generateAccessoryName(type: type, rarity: rarity)
        let baseValue = calculateItemValue(rarity: rarity, baseValue: 60)

        let accessory = Accessory.create(
            name: name,
            description: "A \(rarity.displayName.lowercased()) quality \(type.displayName.lowercased())",
            type: type,
            rarity: rarity,
            baseValue: baseValue
        )

        return .accessory(accessory)
    }

    private static func generateConsumable(rarity: ItemRarity) -> GeneratedLoot {
        let type = ConsumableType.allCases.randomElement()!
        let name = consumableName(for: type, rarity: rarity)
        let baseValue = calculateItemValue(rarity: rarity, baseValue: 15)

        let consumable = Consumable(
            id: UUID(),
            baseItem: Item.create(
                name: name,
                description: "A useful \(type.displayName.lowercased())",
                category: .consumable,
                rarity: rarity,
                baseValue: baseValue,
                weight: type.baseWeight
            ),
            consumableType: type,
            strength: rarity == .legendary ? .superior : (rarity == .epic ? .greater : .standard),
            charges: type.category == .scroll ? 1 : 0,
            effectValue: Int(30 * rarity.valueMultiplier),
            duration: nil,
            targetAttribute: nil
        )

        return .consumable(consumable)
    }

    private static func generateValuable(tier: LootTableTier) -> GeneratedLoot {
        let value = Int(Double.random(in: 20...100) * tier.goldMultiplier)
        let name = valuableName(for: tier)

        let valuable = Valuable.treasure(
            name: name,
            description: "A valuable item worth selling",
            value: value,
            rarity: tier.maxRarity
        )

        return .valuable(valuable)
    }

    private static func generateBonusLoot(tier: LootTableTier) -> GeneratedLoot? {
        // Bonus loot is always at least one tier higher
        let upgradedTier: LootTableTier = {
            switch tier {
            case .poor: return .common
            case .common: return .uncommon
            case .uncommon: return .rare
            case .rare: return .epic
            case .epic, .legendary: return .legendary
            }
        }()

        let rarity = randomRarity(for: upgradedTier)

        // 50% chance weapon, 50% chance accessory for bonus
        if Bool.random() {
            return generateWeapon(rarity: rarity)
        } else {
            return generateAccessory(rarity: rarity)
        }
    }

    // MARK: - Item Value Calculation

    private static func calculateItemValue(rarity: ItemRarity, baseValue: Int) -> Int {
        let multiplier: Double = {
            switch rarity {
            case .common: return 1.0
            case .uncommon: return 2.0
            case .rare: return 5.0
            case .epic: return 15.0
            case .legendary: return 50.0
            }
        }()

        let variance = Double.random(in: 0.8...1.2)
        return Int(Double(baseValue) * multiplier * variance)
    }

    // MARK: - Name Generators

    private static func generateWeaponName(type: WeaponType, rarity: ItemRarity) -> String {
        let prefixes: [ItemRarity: [String]] = [
            .common: ["Iron", "Steel", "Worn", "Simple"],
            .uncommon: ["Fine", "Balanced", "Sturdy", "Tempered"],
            .rare: ["Masterwork", "Enchanted", "Gleaming", "Pristine"],
            .epic: ["Arcane", "Blessed", "Runic", "Mythril"],
            .legendary: ["Ancient", "Divine", "Legendary", "Dragon's"]
        ]

        let prefix = prefixes[rarity]?.randomElement() ?? "Basic"
        return "\(prefix) \(type.displayName)"
    }

    private static func generateArmorName(type: ArmorType, slot: EquipmentSlot, rarity: ItemRarity) -> String {
        let prefixes: [ItemRarity: [String]] = [
            .common: ["Worn", "Simple", "Basic"],
            .uncommon: ["Reinforced", "Sturdy", "Fine"],
            .rare: ["Masterwork", "Enchanted", "Gleaming"],
            .epic: ["Arcane", "Blessed", "Runic"],
            .legendary: ["Ancient", "Divine", "Legendary"]
        ]

        let slotNames: [EquipmentSlot: String] = [
            .head: "Helm", .chest: "Cuirass", .legs: "Greaves",
            .boots: "Boots", .gloves: "Gauntlets"
        ]

        let prefix = prefixes[rarity]?.randomElement() ?? "Basic"
        let slotName = slotNames[slot] ?? "Armor"
        return "\(prefix) \(type.displayName) \(slotName)"
    }

    private static func generateAccessoryName(type: AccessoryType, rarity: ItemRarity) -> String {
        let prefixes: [ItemRarity: [String]] = [
            .common: ["Simple", "Plain", "Modest"],
            .uncommon: ["Ornate", "Crafted", "Fine"],
            .rare: ["Enchanted", "Magical", "Gleaming"],
            .epic: ["Arcane", "Blessed", "Runic"],
            .legendary: ["Ancient", "Divine", "Legendary"]
        ]

        let prefix = prefixes[rarity]?.randomElement() ?? "Basic"
        return "\(prefix) \(type.displayName)"
    }

    private static func consumableName(for type: ConsumableType, rarity: ItemRarity) -> String {
        let quality = rarity == .common ? "" : "\(rarity.displayName) "
        return "\(quality)\(type.displayName)"
    }

    private static func valuableName(for tier: LootTableTier) -> String {
        let names: [LootTableTier: [String]] = [
            .poor: ["Copper Coins", "Worn Trinket", "Tarnished Brooch"],
            .common: ["Silver Coins", "Gem Shard", "Gold Ring"],
            .uncommon: ["Gold Coins", "Small Ruby", "Silver Goblet"],
            .rare: ["Platinum Coins", "Sapphire", "Gold Statuette"],
            .epic: ["Diamond", "Ancient Coin", "Ornate Chalice"],
            .legendary: ["Perfect Diamond", "Royal Crown", "Dragon Scale"]
        ]

        return names[tier]?.randomElement() ?? "Valuable Trinket"
    }

    // MARK: - Inventory Addition

    private static func addLootToInventory(_ loot: GeneratedLoot, guild: inout Guild) {
        switch loot {
        case .weapon(let weapon):
            guild.inventory.addWeapon(weapon)
        case .armor(let armor):
            guild.inventory.addArmor(armor)
        case .accessory(let accessory):
            guild.inventory.addAccessory(accessory)
        case .consumable(let consumable):
            guild.inventory.addConsumable(consumable)
        case .valuable(let valuable):
            guild.inventory.valuables[valuable.baseItem.id] = valuable
        }
    }
}

// MARK: - Generated Loot Type

enum GeneratedLoot {
    case weapon(Weapon)
    case armor(Armor)
    case accessory(Accessory)
    case consumable(Consumable)
    case valuable(Valuable)

    var displayName: String {
        switch self {
        case .weapon(let w): return w.baseItem.name
        case .armor(let a): return a.baseItem.name
        case .accessory(let a): return a.baseItem.name
        case .consumable(let c): return c.baseItem.name
        case .valuable(let v): return v.baseItem.name
        }
    }

    var rarity: ItemRarity {
        switch self {
        case .weapon(let w): return w.baseItem.rarity
        case .armor(let a): return a.baseItem.rarity
        case .accessory(let a): return a.baseItem.rarity
        case .consumable(let c): return c.baseItem.rarity
        case .valuable: return .common
        }
    }

    var value: Int {
        switch self {
        case .weapon(let w): return w.baseItem.effectiveValue
        case .armor(let a): return a.baseItem.effectiveValue
        case .accessory(let a): return a.baseItem.effectiveValue
        case .consumable(let c): return c.baseItem.effectiveValue
        case .valuable(let v): return v.actualValue
        }
    }
}

// MARK: - Loot Valuable Item

struct LootValuable: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let baseValue: Int
    let actualValue: Int
}
