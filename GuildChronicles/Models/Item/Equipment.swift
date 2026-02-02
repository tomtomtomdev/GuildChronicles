//
//  Equipment.swift
//  GuildChronicles
//
//  Equipment system - weapons, armor, accessories (Sprint 1.4)
//

import Foundation

// MARK: - Equipment Slots

enum EquipmentSlot: String, Codable, CaseIterable {
    case mainHand
    case offHand
    case head
    case chest
    case legs
    case boots
    case gloves
    case ring1
    case ring2
    case amulet
    case cloak

    var displayName: String {
        switch self {
        case .mainHand: return "Main Hand"
        case .offHand: return "Off Hand"
        case .head: return "Head"
        case .chest: return "Chest"
        case .legs: return "Legs"
        case .boots: return "Boots"
        case .gloves: return "Gloves"
        case .ring1: return "Ring (Left)"
        case .ring2: return "Ring (Right)"
        case .amulet: return "Amulet"
        case .cloak: return "Cloak"
        }
    }

    var isWeaponSlot: Bool {
        self == .mainHand || self == .offHand
    }

    var isArmorSlot: Bool {
        [.head, .chest, .legs, .boots, .gloves].contains(self)
    }

    var isAccessorySlot: Bool {
        [.ring1, .ring2, .amulet, .cloak].contains(self)
    }
}

// MARK: - Weapon Types

enum WeaponType: String, Codable, CaseIterable {
    // Melee - One Hand
    case sword
    case axe
    case mace
    case dagger
    case rapier

    // Melee - Two Hand
    case greatsword
    case greataxe
    case warhammer
    case polearm
    case staff

    // Ranged
    case bow
    case crossbow
    case throwingWeapon

    // Magic
    case wand
    case orb

    // Special
    case shield

    var displayName: String {
        switch self {
        case .sword: return "Sword"
        case .axe: return "Axe"
        case .mace: return "Mace"
        case .dagger: return "Dagger"
        case .rapier: return "Rapier"
        case .greatsword: return "Greatsword"
        case .greataxe: return "Greataxe"
        case .warhammer: return "Warhammer"
        case .polearm: return "Polearm"
        case .staff: return "Staff"
        case .bow: return "Bow"
        case .crossbow: return "Crossbow"
        case .throwingWeapon: return "Throwing Weapon"
        case .wand: return "Wand"
        case .orb: return "Orb"
        case .shield: return "Shield"
        }
    }

    var isTwoHanded: Bool {
        switch self {
        case .greatsword, .greataxe, .warhammer, .polearm, .staff, .bow, .crossbow:
            return true
        default:
            return false
        }
    }

    var isRanged: Bool {
        switch self {
        case .bow, .crossbow, .throwingWeapon, .wand:
            return true
        default:
            return false
        }
    }

    var isMagic: Bool {
        switch self {
        case .wand, .orb, .staff:
            return true
        default:
            return false
        }
    }

    var primaryAttribute: AttributeType {
        switch self {
        case .sword, .axe, .mace, .greatsword, .greataxe, .warhammer, .polearm:
            return .meleeCombat
        case .dagger, .rapier:
            return .dexterity
        case .bow, .crossbow, .throwingWeapon:
            return .rangedCombat
        case .wand, .orb, .staff:
            return .arcanePower
        case .shield:
            return .defense
        }
    }

    var baseDamageRange: ClosedRange<Int> {
        switch self {
        case .dagger: return 2...6
        case .sword, .axe, .mace, .rapier: return 4...10
        case .greatsword, .greataxe: return 8...16
        case .warhammer, .polearm: return 6...14
        case .staff: return 3...8
        case .bow: return 4...12
        case .crossbow: return 6...14
        case .throwingWeapon: return 3...8
        case .wand, .orb: return 2...8
        case .shield: return 1...4
        }
    }
}

// MARK: - Armor Types

enum ArmorType: String, Codable, CaseIterable {
    case cloth
    case leather
    case chainmail
    case plate

    var displayName: String {
        switch self {
        case .cloth: return "Cloth"
        case .leather: return "Leather"
        case .chainmail: return "Chainmail"
        case .plate: return "Plate"
        }
    }

    var baseDefenseBonus: Int {
        switch self {
        case .cloth: return 1
        case .leather: return 3
        case .chainmail: return 5
        case .plate: return 8
        }
    }

    var speedPenalty: Int {
        switch self {
        case .cloth: return 0
        case .leather: return 0
        case .chainmail: return 1
        case .plate: return 3
        }
    }

    var magicPenalty: Int {
        switch self {
        case .cloth: return 0
        case .leather: return 0
        case .chainmail: return 2
        case .plate: return 5
        }
    }

    /// Classes that can use this armor type
    var allowedClasses: [AdventurerClass] {
        switch self {
        case .cloth:
            return AdventurerClass.allCases
        case .leather:
            return [.fighter, .ranger, .rogue, .bard, .monk, .cleric, .druid, .paladin, .warlock, .barbarian]
        case .chainmail:
            return [.fighter, .ranger, .cleric, .paladin, .barbarian, .eldritchKnight]
        case .plate:
            return [.fighter, .paladin]
        }
    }
}

/// Armor slot-specific defense values
struct ArmorSlotDefense {
    static func baseDefense(for slot: EquipmentSlot, armorType: ArmorType) -> Int {
        let typeBonus = armorType.baseDefenseBonus
        switch slot {
        case .chest: return typeBonus * 3
        case .legs: return typeBonus * 2
        case .head, .boots, .gloves: return typeBonus
        default: return 0
        }
    }
}

// MARK: - Accessory Types

enum AccessoryType: String, Codable, CaseIterable {
    case ring
    case amulet
    case cloak
    case bracelet
    case belt
    case trinket

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var allowedSlots: [EquipmentSlot] {
        switch self {
        case .ring, .bracelet: return [.ring1, .ring2]
        case .amulet, .trinket: return [.amulet]
        case .cloak, .belt: return [.cloak]
        }
    }
}

// MARK: - Weapon Model

struct Weapon: Identifiable, Codable, Equatable {
    let id: UUID
    let baseItem: Item
    var weaponType: WeaponType
    var condition: ItemCondition

    // Combat stats
    var baseDamageMin: Int
    var baseDamageMax: Int
    var attackSpeed: Double  // Attacks per round (1.0 = normal)
    var criticalChance: Double
    var criticalMultiplier: Double

    // Requirements
    var requiredStrength: Int
    var requiredDexterity: Int
    var requiredLevel: AdventurerLevel

    // Enchantments
    var enchantments: [Enchantment]

    // MARK: - Computed Properties

    var damageRange: ClosedRange<Int> {
        let min = Int(Double(baseDamageMin) * condition.effectivenessMultiplier)
        let max = Int(Double(baseDamageMax) * condition.effectivenessMultiplier)
        return min...Swift.max(min, max)
    }

    var averageDamage: Double {
        Double(damageRange.lowerBound + damageRange.upperBound) / 2.0
    }

    var dps: Double {
        averageDamage * attackSpeed
    }

    var isTwoHanded: Bool {
        weaponType.isTwoHanded
    }

    var isRanged: Bool {
        weaponType.isRanged
    }

    var isMagic: Bool {
        weaponType.isMagic
    }

    var hasEnchantments: Bool {
        !enchantments.isEmpty
    }

    var totalEnchantmentValue: Int {
        enchantments.reduce(0) { $0 + $1.value }
    }

    // MARK: - Factory

    static func create(
        name: String,
        description: String,
        type: WeaponType,
        rarity: ItemRarity = .common,
        baseValue: Int,
        condition: ItemCondition = .average
    ) -> Weapon {
        let damageRange = type.baseDamageRange
        let rarityBonus = Int(rarity.valueMultiplier)

        return Weapon(
            id: UUID(),
            baseItem: Item.create(
                name: name,
                description: description,
                category: .weapon,
                rarity: rarity,
                baseValue: baseValue,
                weight: type.isTwoHanded ? 8.0 : 4.0
            ),
            weaponType: type,
            condition: condition,
            baseDamageMin: damageRange.lowerBound + rarityBonus,
            baseDamageMax: damageRange.upperBound + rarityBonus * 2,
            attackSpeed: 1.0,
            criticalChance: 0.05,
            criticalMultiplier: 2.0,
            requiredStrength: type.isTwoHanded ? 12 : 8,
            requiredDexterity: type.isRanged ? 10 : 6,
            requiredLevel: .apprentice,
            enchantments: []
        )
    }
}

// MARK: - Armor Model

struct Armor: Identifiable, Codable, Equatable {
    let id: UUID
    let baseItem: Item
    var armorType: ArmorType
    var slot: EquipmentSlot
    var condition: ItemCondition

    // Defense stats
    var baseDefense: Int
    var magicResistance: Int

    // Penalties
    var speedPenalty: Int
    var magicPenalty: Int

    // Requirements
    var requiredStrength: Int
    var requiredLevel: AdventurerLevel
    var allowedClasses: [AdventurerClass]

    // Enchantments
    var enchantments: [Enchantment]

    // MARK: - Computed Properties

    var effectiveDefense: Int {
        Int(Double(baseDefense) * condition.effectivenessMultiplier)
    }

    var hasEnchantments: Bool {
        !enchantments.isEmpty
    }

    // MARK: - Factory

    static func create(
        name: String,
        description: String,
        type: ArmorType,
        slot: EquipmentSlot,
        rarity: ItemRarity = .common,
        baseValue: Int,
        condition: ItemCondition = .average
    ) -> Armor {
        let baseDefense = ArmorSlotDefense.baseDefense(for: slot, armorType: type)
        let rarityBonus = Int(rarity.valueMultiplier)

        return Armor(
            id: UUID(),
            baseItem: Item.create(
                name: name,
                description: description,
                category: .armor,
                rarity: rarity,
                baseValue: baseValue,
                weight: slot == .chest ? 15.0 : 5.0
            ),
            armorType: type,
            slot: slot,
            condition: condition,
            baseDefense: baseDefense + rarityBonus,
            magicResistance: type == .cloth ? 2 : 0,
            speedPenalty: type.speedPenalty,
            magicPenalty: type.magicPenalty,
            requiredStrength: type == .plate ? 14 : (type == .chainmail ? 10 : 6),
            requiredLevel: .apprentice,
            allowedClasses: type.allowedClasses,
            enchantments: []
        )
    }
}

// MARK: - Accessory Model

struct Accessory: Identifiable, Codable, Equatable {
    let id: UUID
    let baseItem: Item
    var accessoryType: AccessoryType
    var condition: ItemCondition
    var allowedSlots: [EquipmentSlot]

    // Stat bonuses
    var attributeBonuses: [AttributeType: Int]

    // Enchantments
    var enchantments: [Enchantment]

    // MARK: - Computed Properties

    var hasAttributeBonuses: Bool {
        !attributeBonuses.isEmpty
    }

    var hasEnchantments: Bool {
        !enchantments.isEmpty
    }

    var totalAttributeBonus: Int {
        attributeBonuses.values.reduce(0, +)
    }

    // MARK: - Factory

    static func create(
        name: String,
        description: String,
        type: AccessoryType,
        rarity: ItemRarity = .common,
        baseValue: Int,
        attributeBonuses: [AttributeType: Int] = [:]
    ) -> Accessory {
        Accessory(
            id: UUID(),
            baseItem: Item.create(
                name: name,
                description: description,
                category: .accessory,
                rarity: rarity,
                baseValue: baseValue,
                weight: 0.2
            ),
            accessoryType: type,
            condition: .pristine,
            allowedSlots: type.allowedSlots,
            attributeBonuses: attributeBonuses,
            enchantments: []
        )
    }
}

// MARK: - Adventurer Equipment Set

struct AdventurerEquipment: Codable, Equatable {
    var mainHand: UUID?   // Weapon ID
    var offHand: UUID?    // Weapon or Shield ID
    var head: UUID?       // Armor ID
    var chest: UUID?      // Armor ID
    var legs: UUID?       // Armor ID
    var boots: UUID?      // Armor ID
    var gloves: UUID?     // Armor ID
    var ring1: UUID?      // Accessory ID
    var ring2: UUID?      // Accessory ID
    var amulet: UUID?     // Accessory ID
    var cloak: UUID?      // Accessory ID

    var equippedSlots: [EquipmentSlot: UUID] {
        var slots: [EquipmentSlot: UUID] = [:]
        if let id = mainHand { slots[.mainHand] = id }
        if let id = offHand { slots[.offHand] = id }
        if let id = head { slots[.head] = id }
        if let id = chest { slots[.chest] = id }
        if let id = legs { slots[.legs] = id }
        if let id = boots { slots[.boots] = id }
        if let id = gloves { slots[.gloves] = id }
        if let id = ring1 { slots[.ring1] = id }
        if let id = ring2 { slots[.ring2] = id }
        if let id = amulet { slots[.amulet] = id }
        if let id = cloak { slots[.cloak] = id }
        return slots
    }

    var filledSlotCount: Int {
        equippedSlots.count
    }

    var isEmpty: Bool {
        equippedSlots.isEmpty
    }

    mutating func equip(_ itemID: UUID, to slot: EquipmentSlot) {
        switch slot {
        case .mainHand: mainHand = itemID
        case .offHand: offHand = itemID
        case .head: head = itemID
        case .chest: chest = itemID
        case .legs: legs = itemID
        case .boots: boots = itemID
        case .gloves: gloves = itemID
        case .ring1: ring1 = itemID
        case .ring2: ring2 = itemID
        case .amulet: amulet = itemID
        case .cloak: cloak = itemID
        }
    }

    mutating func unequip(_ slot: EquipmentSlot) -> UUID? {
        let current = equippedSlots[slot]
        switch slot {
        case .mainHand: mainHand = nil
        case .offHand: offHand = nil
        case .head: head = nil
        case .chest: chest = nil
        case .legs: legs = nil
        case .boots: boots = nil
        case .gloves: gloves = nil
        case .ring1: ring1 = nil
        case .ring2: ring2 = nil
        case .amulet: amulet = nil
        case .cloak: cloak = nil
        }
        return current
    }

    static var empty: AdventurerEquipment {
        AdventurerEquipment(
            mainHand: nil, offHand: nil,
            head: nil, chest: nil, legs: nil, boots: nil, gloves: nil,
            ring1: nil, ring2: nil, amulet: nil, cloak: nil
        )
    }
}
