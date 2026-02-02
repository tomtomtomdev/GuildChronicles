//
//  Enchantment.swift
//  GuildChronicles
//
//  Enchantment system for magical items (Sprint 1.4)
//

import Foundation

/// Types of enchantments that can be applied to items
enum EnchantmentType: String, Codable, CaseIterable {
    // Attribute bonuses
    case attributeBonus

    // Weapon enchantments
    case fireDamage
    case iceDamage
    case lightningDamage
    case poisonDamage
    case holyDamage
    case voidDamage
    case lifeSteal
    case armorPiercing

    // Armor enchantments
    case fireResistance
    case iceResistance
    case lightningResistance
    case poisonResistance
    case holyResistance
    case voidResistance
    case thorns
    case healthRegen
    case manaRegen

    // Accessory enchantments
    case luckBonus
    case experienceBonus
    case goldFind
    case movementSpeed

    var displayName: String {
        switch self {
        case .attributeBonus: return "Attribute Bonus"
        case .fireDamage: return "Fire Damage"
        case .iceDamage: return "Ice Damage"
        case .lightningDamage: return "Lightning Damage"
        case .poisonDamage: return "Poison Damage"
        case .holyDamage: return "Holy Damage"
        case .voidDamage: return "Void Damage"
        case .lifeSteal: return "Life Steal"
        case .armorPiercing: return "Armor Piercing"
        case .fireResistance: return "Fire Resistance"
        case .iceResistance: return "Ice Resistance"
        case .lightningResistance: return "Lightning Resistance"
        case .poisonResistance: return "Poison Resistance"
        case .holyResistance: return "Holy Resistance"
        case .voidResistance: return "Void Resistance"
        case .thorns: return "Thorns"
        case .healthRegen: return "Health Regeneration"
        case .manaRegen: return "Mana Regeneration"
        case .luckBonus: return "Luck"
        case .experienceBonus: return "Experience Bonus"
        case .goldFind: return "Gold Find"
        case .movementSpeed: return "Movement Speed"
        }
    }

    var isElementalDamage: Bool {
        switch self {
        case .fireDamage, .iceDamage, .lightningDamage, .poisonDamage, .holyDamage, .voidDamage:
            return true
        default:
            return false
        }
    }

    var isResistance: Bool {
        switch self {
        case .fireResistance, .iceResistance, .lightningResistance,
             .poisonResistance, .holyResistance, .voidResistance:
            return true
        default:
            return false
        }
    }

    var validForWeapons: Bool {
        switch self {
        case .attributeBonus, .fireDamage, .iceDamage, .lightningDamage,
             .poisonDamage, .holyDamage, .voidDamage, .lifeSteal, .armorPiercing:
            return true
        default:
            return false
        }
    }

    var validForArmor: Bool {
        switch self {
        case .attributeBonus, .fireResistance, .iceResistance, .lightningResistance,
             .poisonResistance, .holyResistance, .voidResistance, .thorns,
             .healthRegen, .manaRegen:
            return true
        default:
            return false
        }
    }

    var validForAccessories: Bool {
        true  // All enchantments can appear on accessories
    }
}

/// Tier of enchantment strength
enum EnchantmentTier: Int, Codable, CaseIterable, Comparable {
    case minor = 1
    case lesser = 2
    case standard = 3
    case greater = 4
    case superior = 5
    case legendary = 6

    var displayName: String {
        switch self {
        case .minor: return "Minor"
        case .lesser: return "Lesser"
        case .standard: return "Standard"
        case .greater: return "Greater"
        case .superior: return "Superior"
        case .legendary: return "Legendary"
        }
    }

    var valueMultiplier: Double {
        switch self {
        case .minor: return 1.0
        case .lesser: return 1.5
        case .standard: return 2.5
        case .greater: return 4.0
        case .superior: return 7.0
        case .legendary: return 15.0
        }
    }

    var effectMultiplier: Double {
        Double(rawValue)
    }

    static func < (lhs: EnchantmentTier, rhs: EnchantmentTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// An enchantment on an item
struct Enchantment: Identifiable, Codable, Equatable {
    let id: UUID
    var type: EnchantmentType
    var tier: EnchantmentTier
    var value: Int  // The magnitude of the effect
    var targetAttribute: AttributeType?  // For attribute bonus enchantments

    // MARK: - Computed Properties

    var displayName: String {
        if type == .attributeBonus, let attr = targetAttribute {
            return "\(tier.displayName) \(attr.displayName)"
        }
        return "\(tier.displayName) \(type.displayName)"
    }

    var description: String {
        switch type {
        case .attributeBonus:
            guard let attr = targetAttribute else { return "+\(value) to attribute" }
            return "+\(value) \(attr.displayName)"
        case .fireDamage, .iceDamage, .lightningDamage, .poisonDamage, .holyDamage, .voidDamage:
            return "+\(value) \(type.displayName)"
        case .lifeSteal:
            return "Steal \(value)% of damage as health"
        case .armorPiercing:
            return "Ignore \(value) armor"
        case .fireResistance, .iceResistance, .lightningResistance,
             .poisonResistance, .holyResistance, .voidResistance:
            return "+\(value)% \(type.displayName)"
        case .thorns:
            return "Reflect \(value) damage to attackers"
        case .healthRegen, .manaRegen:
            return "+\(value) \(type.displayName) per turn"
        case .luckBonus:
            return "+\(value) Luck"
        case .experienceBonus:
            return "+\(value)% Experience"
        case .goldFind:
            return "+\(value)% Gold Find"
        case .movementSpeed:
            return "+\(value) Movement Speed"
        }
    }

    var addedValue: Int {
        Int(Double(value) * 10 * tier.valueMultiplier)
    }

    // MARK: - Factory

    static func create(
        type: EnchantmentType,
        tier: EnchantmentTier,
        targetAttribute: AttributeType? = nil
    ) -> Enchantment {
        let baseValue: Int = {
            switch type {
            case .attributeBonus:
                return Int(Double([1, 2, 3, 5, 7, 10][tier.rawValue - 1]) * tier.effectMultiplier)
            case .fireDamage, .iceDamage, .lightningDamage, .poisonDamage, .holyDamage, .voidDamage:
                return [2, 4, 8, 14, 22, 35][tier.rawValue - 1]
            case .lifeSteal:
                return [3, 5, 8, 12, 18, 25][tier.rawValue - 1]
            case .armorPiercing:
                return [2, 4, 7, 11, 16, 25][tier.rawValue - 1]
            case .fireResistance, .iceResistance, .lightningResistance,
                 .poisonResistance, .holyResistance, .voidResistance:
                return [5, 10, 15, 25, 35, 50][tier.rawValue - 1]
            case .thorns:
                return [2, 5, 10, 18, 30, 50][tier.rawValue - 1]
            case .healthRegen, .manaRegen:
                return [1, 2, 4, 7, 12, 20][tier.rawValue - 1]
            case .luckBonus:
                return [1, 2, 4, 6, 10, 15][tier.rawValue - 1]
            case .experienceBonus, .goldFind:
                return [5, 10, 15, 25, 40, 60][tier.rawValue - 1]
            case .movementSpeed:
                return [1, 2, 3, 5, 7, 10][tier.rawValue - 1]
            }
        }()

        return Enchantment(
            id: UUID(),
            type: type,
            tier: tier,
            value: baseValue,
            targetAttribute: type == .attributeBonus ? targetAttribute : nil
        )
    }

    /// Create a random enchantment appropriate for a given rarity
    static func random(forRarity rarity: ItemRarity) -> Enchantment {
        let maxTier: EnchantmentTier = {
            switch rarity {
            case .common: return .minor
            case .uncommon: return .lesser
            case .rare: return .standard
            case .epic: return .greater
            case .legendary: return .legendary
            }
        }()

        let tierOptions = EnchantmentTier.allCases.filter { $0 <= maxTier }
        let tier = tierOptions.randomElement() ?? .minor
        let type = EnchantmentType.allCases.randomElement() ?? .attributeBonus

        var targetAttr: AttributeType? = nil
        if type == .attributeBonus {
            targetAttr = AttributeType.allCases.randomElement()
        }

        return create(type: type, tier: tier, targetAttribute: targetAttr)
    }
}

// MARK: - Item Set Bonus

/// A matched set of items with bonus effects
struct ItemSet: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var itemIDs: [UUID]  // Items that are part of this set
    var setBonuses: [SetBonus]

    func bonusesForCount(_ equippedCount: Int) -> [SetBonus] {
        setBonuses.filter { $0.requiredPieces <= equippedCount }
    }
}

struct SetBonus: Codable, Equatable {
    var requiredPieces: Int  // How many set pieces needed
    var attributeBonuses: [AttributeType: Int]
    var enchantment: Enchantment?
    var description: String
}
