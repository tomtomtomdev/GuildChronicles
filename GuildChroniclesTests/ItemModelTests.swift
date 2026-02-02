//
//  ItemModelTests.swift
//  GuildChroniclesTests
//
//  Tests for Item, Equipment, Enchantment, Consumable, and LootTable models
//

import Testing
import Foundation
@testable import GuildChronicles

struct ItemModelTests {

    // MARK: - Item Rarity Tests

    @Test func itemRarityComparison() async throws {
        #expect(ItemRarity.common < ItemRarity.legendary)
        #expect(ItemRarity.rare < ItemRarity.epic)
        #expect(ItemRarity.legendary.valueMultiplier > ItemRarity.common.valueMultiplier)
    }

    @Test func itemRarityDropWeights() async throws {
        #expect(ItemRarity.common.dropWeight > ItemRarity.legendary.dropWeight)
        #expect(ItemRarity.uncommon.dropWeight > ItemRarity.rare.dropWeight)
    }

    @Test func itemCategoryEquippable() async throws {
        #expect(ItemCategory.weapon.canBeEquipped == true)
        #expect(ItemCategory.armor.canBeEquipped == true)
        #expect(ItemCategory.accessory.canBeEquipped == true)
        #expect(ItemCategory.consumable.canBeEquipped == false)
        #expect(ItemCategory.questItem.canBeEquipped == false)
        #expect(ItemCategory.valuable.canBeEquipped == false)
    }

    @Test func itemCreation() async throws {
        let item = Item.create(
            name: "Test Item",
            description: "A test item",
            category: .valuable,
            rarity: .rare,
            baseValue: 100
        )

        #expect(item.name == "Test Item")
        #expect(item.category == .valuable)
        #expect(item.rarity == .rare)
        #expect(item.effectiveValue == 500)  // 100 * 5.0 (rare multiplier)
    }

    @Test func itemConditionEffects() async throws {
        #expect(ItemCondition.broken.valueMultiplier < ItemCondition.pristine.valueMultiplier)
        #expect(ItemCondition.broken.effectivenessMultiplier == 0.0)
        #expect(ItemCondition.pristine.effectivenessMultiplier == 1.0)
    }

    // MARK: - Weapon Tests

    @Test func weaponTypeAttributes() async throws {
        #expect(WeaponType.greatsword.isTwoHanded == true)
        #expect(WeaponType.sword.isTwoHanded == false)
        #expect(WeaponType.bow.isRanged == true)
        #expect(WeaponType.axe.isRanged == false)
        #expect(WeaponType.wand.isMagic == true)
        #expect(WeaponType.mace.isMagic == false)
    }

    @Test func weaponCreation() async throws {
        let sword = Weapon.create(
            name: "Iron Sword",
            description: "A sturdy iron sword",
            type: .sword,
            rarity: .uncommon,
            baseValue: 75
        )

        #expect(sword.weaponType == .sword)
        #expect(sword.isTwoHanded == false)
        #expect(sword.isRanged == false)
        #expect(sword.baseDamageMin > 0)
        #expect(sword.baseDamageMax > sword.baseDamageMin)
    }

    @Test func weaponDamageCalculation() async throws {
        var weapon = Weapon.create(
            name: "Test Weapon",
            description: "",
            type: .sword,
            baseValue: 50
        )

        let normalDamage = weapon.damageRange
        weapon.condition = .broken
        let brokenDamage = weapon.damageRange

        // Broken condition should reduce damage
        #expect(brokenDamage.lowerBound <= normalDamage.lowerBound)
    }

    @Test func weaponDPS() async throws {
        let fastWeapon = Weapon(
            id: UUID(),
            baseItem: Item.create(name: "Fast", description: "", category: .weapon, baseValue: 50),
            weaponType: .dagger,
            condition: .average,
            baseDamageMin: 5,
            baseDamageMax: 10,
            attackSpeed: 2.0,
            criticalChance: 0.1,
            criticalMultiplier: 2.0,
            requiredStrength: 6,
            requiredDexterity: 10,
            requiredLevel: .apprentice,
            enchantments: []
        )

        let slowWeapon = Weapon(
            id: UUID(),
            baseItem: Item.create(name: "Slow", description: "", category: .weapon, baseValue: 50),
            weaponType: .greatsword,
            condition: .average,
            baseDamageMin: 10,
            baseDamageMax: 20,
            attackSpeed: 0.5,
            criticalChance: 0.05,
            criticalMultiplier: 2.0,
            requiredStrength: 14,
            requiredDexterity: 6,
            requiredLevel: .journeyman,
            enchantments: []
        )

        // Fast weapon with low damage can have comparable DPS to slow high damage
        #expect(fastWeapon.dps > 0)
        #expect(slowWeapon.dps > 0)
    }

    // MARK: - Armor Tests

    @Test func armorTypeProperties() async throws {
        #expect(ArmorType.plate.baseDefenseBonus > ArmorType.cloth.baseDefenseBonus)
        #expect(ArmorType.plate.speedPenalty > ArmorType.leather.speedPenalty)
        #expect(ArmorType.cloth.magicPenalty < ArmorType.plate.magicPenalty)
    }

    @Test func armorSlotDefense() async throws {
        let chestDefense = ArmorSlotDefense.baseDefense(for: .chest, armorType: .plate)
        let glovesDefense = ArmorSlotDefense.baseDefense(for: .gloves, armorType: .plate)

        #expect(chestDefense > glovesDefense)  // Chest provides more defense
    }

    @Test func armorCreation() async throws {
        let armor = Armor.create(
            name: "Steel Breastplate",
            description: "Heavy steel armor",
            type: .plate,
            slot: .chest,
            rarity: .rare,
            baseValue: 200
        )

        #expect(armor.armorType == .plate)
        #expect(armor.slot == .chest)
        #expect(armor.baseDefense > 0)
        #expect(armor.speedPenalty > 0)
    }

    @Test func armorClassRestrictions() async throws {
        let plateClasses = ArmorType.plate.allowedClasses
        let clothClasses = ArmorType.cloth.allowedClasses

        #expect(plateClasses.contains(.fighter))
        #expect(plateClasses.contains(.paladin))
        #expect(!plateClasses.contains(.wizard))
        #expect(clothClasses.contains(.wizard))  // Everyone can wear cloth
    }

    // MARK: - Accessory Tests

    @Test func accessoryTypeSlots() async throws {
        #expect(AccessoryType.ring.allowedSlots.contains(.ring1))
        #expect(AccessoryType.ring.allowedSlots.contains(.ring2))
        #expect(AccessoryType.amulet.allowedSlots.contains(.amulet))
        #expect(AccessoryType.cloak.allowedSlots.contains(.cloak))
    }

    @Test func accessoryCreation() async throws {
        let ring = Accessory.create(
            name: "Ring of Strength",
            description: "Increases strength",
            type: .ring,
            rarity: .rare,
            baseValue: 150,
            attributeBonuses: [.meleeCombat: 3, .fortitude: 2]
        )

        #expect(ring.accessoryType == .ring)
        #expect(ring.hasAttributeBonuses == true)
        #expect(ring.totalAttributeBonus == 5)
    }

    // MARK: - Equipment Slot Tests

    @Test func equipmentSlotCategories() async throws {
        #expect(EquipmentSlot.mainHand.isWeaponSlot == true)
        #expect(EquipmentSlot.chest.isArmorSlot == true)
        #expect(EquipmentSlot.ring1.isAccessorySlot == true)
        #expect(EquipmentSlot.head.isWeaponSlot == false)
    }

    @Test func adventurerEquipmentManagement() async throws {
        var equipment = AdventurerEquipment.empty
        #expect(equipment.isEmpty == true)

        let weaponID = UUID()
        equipment.equip(weaponID, to: .mainHand)
        #expect(equipment.isEmpty == false)
        #expect(equipment.filledSlotCount == 1)
        #expect(equipment.mainHand == weaponID)

        let unequipped = equipment.unequip(.mainHand)
        #expect(unequipped == weaponID)
        #expect(equipment.isEmpty == true)
    }

    // MARK: - Enchantment Tests

    @Test func enchantmentTierComparison() async throws {
        #expect(EnchantmentTier.minor < EnchantmentTier.legendary)
        #expect(EnchantmentTier.legendary.valueMultiplier > EnchantmentTier.minor.valueMultiplier)
    }

    @Test func enchantmentTypeCategories() async throws {
        #expect(EnchantmentType.fireDamage.isElementalDamage == true)
        #expect(EnchantmentType.fireResistance.isResistance == true)
        #expect(EnchantmentType.fireDamage.validForWeapons == true)
        #expect(EnchantmentType.fireResistance.validForArmor == true)
    }

    @Test func enchantmentCreation() async throws {
        let enchant = Enchantment.create(
            type: .fireDamage,
            tier: .greater
        )

        #expect(enchant.type == .fireDamage)
        #expect(enchant.tier == .greater)
        #expect(enchant.value > 0)
        #expect(enchant.displayName.contains("Greater"))
    }

    @Test func attributeEnchantment() async throws {
        let enchant = Enchantment.create(
            type: .attributeBonus,
            tier: .standard,
            targetAttribute: .meleeCombat
        )

        #expect(enchant.targetAttribute == .meleeCombat)
        #expect(enchant.description.contains("Melee Combat"))
    }

    // MARK: - Consumable Tests

    @Test func consumableTypeCategories() async throws {
        #expect(ConsumableType.healthPotion.category == .potion)
        #expect(ConsumableType.spellScroll.category == .scroll)
        #expect(ConsumableType.rations.category == .supply)
        #expect(ConsumableType.alchemistFire.category == .throwable)
    }

    @Test func consumableCombatUsability() async throws {
        #expect(ConsumableType.healthPotion.isUsableInCombat == true)
        #expect(ConsumableType.alchemistFire.isUsableInCombat == true)
        #expect(ConsumableType.campingGear.isUsableInCombat == false)
    }

    @Test func potionStrengthComparison() async throws {
        #expect(PotionStrength.minor < PotionStrength.superior)
        #expect(PotionStrength.superior.effectMultiplier > PotionStrength.minor.effectMultiplier)
    }

    @Test func potionCreation() async throws {
        let potion = Consumable.potion(type: .healthPotion, strength: .greater)

        #expect(potion.consumableType == .healthPotion)
        #expect(potion.strength == .greater)
        #expect(potion.isPotion == true)
        #expect(potion.isUsableInCombat == true)
    }

    @Test func scrollCreation() async throws {
        let scroll = Consumable.scroll(type: .teleportScroll, charges: 3)

        #expect(scroll.isScroll == true)
        #expect(scroll.charges == 3)
    }

    // MARK: - Loot Table Tests

    @Test func lootTableTierComparison() async throws {
        #expect(LootTableTier.poor < LootTableTier.legendary)
        #expect(LootTableTier.legendary.goldMultiplier > LootTableTier.poor.goldMultiplier)
    }

    @Test func lootTableTierRarityWeights() async throws {
        let poorWeights = LootTableTier.poor.rarityWeights
        let legendaryWeights = LootTableTier.legendary.rarityWeights

        #expect(poorWeights[.legendary] == nil)
        #expect(legendaryWeights[.legendary] != nil)
    }

    @Test func lootTableCreation() async throws {
        let table = LootTable.create(
            name: "Test Table",
            tier: .rare,
            entries: [
                .category(.weapon, weight: 50),
                .category(.armor, weight: 30),
                .guaranteed(itemID: UUID())
            ],
            minGold: 100,
            maxGold: 500
        )

        #expect(table.tier == .rare)
        #expect(table.entries.count == 3)
        #expect(table.guaranteedEntries.count == 1)
        #expect(table.randomEntries.count == 2)
        #expect(table.totalWeight == 80)
    }

    @Test func lootEntryCreation() async throws {
        let specific = LootEntry.specific(itemID: UUID(), weight: 20)
        #expect(specific.isSpecificItem == true)
        #expect(specific.weight == 20)

        let category = LootEntry.category(.weapon, rarity: .rare)
        #expect(category.isCategoryDrop == true)
        #expect(category.itemRarity == .rare)

        let guaranteed = LootEntry.guaranteed(itemID: UUID())
        #expect(guaranteed.guaranteedDrop == true)
    }

    @Test func predefinedLootTables() async throws {
        let commonChest = LootTable.commonChest
        #expect(commonChest.tier == .common)
        #expect(commonChest.entries.count > 0)

        let bossLoot = LootTable.bossLoot
        #expect(bossLoot.tier == .epic)
        #expect(bossLoot.maxGold > commonChest.maxGold)
    }

    @Test func questRewardLootTable() async throws {
        let lowReward = LootTable.questReward(for: .low)
        let criticalReward = LootTable.questReward(for: .critical)

        #expect(criticalReward.tier > lowReward.tier)
        #expect(criticalReward.maxGold > lowReward.maxGold)
    }

    // MARK: - Guild Inventory Tests

    @Test func guildInventoryGoldManagement() async throws {
        var inventory = GuildInventory.empty
        #expect(inventory.gold == 0)

        inventory.addGold(100)
        #expect(inventory.gold == 100)

        let success = inventory.removeGold(50)
        #expect(success == true)
        #expect(inventory.gold == 50)

        let failure = inventory.removeGold(100)
        #expect(failure == false)
        #expect(inventory.gold == 50)  // Unchanged
    }

    @Test func guildInventoryItemManagement() async throws {
        var inventory = GuildInventory.empty

        let weapon = Weapon.create(name: "Sword", description: "", type: .sword, baseValue: 50)
        inventory.addWeapon(weapon)
        #expect(inventory.weapons.count == 1)

        let armor = Armor.create(name: "Helm", description: "", type: .leather, slot: .head, baseValue: 30)
        inventory.addArmor(armor)
        #expect(inventory.armors.count == 1)

        #expect(inventory.totalItems == 2)
    }

    @Test func starterInventory() async throws {
        let starter = GuildInventory.starter
        #expect(starter.gold == 500)
        #expect(starter.weapons.count >= 2)
        #expect(starter.armors.count >= 1)
        #expect(starter.totalValue > starter.gold)
    }

    // MARK: - Valuable Tests

    @Test func valuableCreation() async throws {
        let treasure = Valuable.treasure(
            name: "Ancient Crown",
            description: "A crown from a lost kingdom",
            value: 1000,
            rarity: .epic
        )

        #expect(treasure.baseItem.name == "Ancient Crown")
        #expect(treasure.condition == .pristine)
        #expect(treasure.actualValue > 1000)  // Pristine bonus
    }

    @Test func valuableConditionAffectsValue() async throws {
        var treasure = Valuable.treasure(name: "Gem", description: "", value: 100)
        let pristineValue = treasure.actualValue

        treasure.condition = .poor
        let poorValue = treasure.actualValue

        #expect(poorValue < pristineValue)
    }

    // MARK: - Quest Item Tests

    @Test func questItemCreation() async throws {
        let questID = UUID()
        let questItem = QuestItem.create(
            name: "Ancient Key",
            description: "Opens the sealed door",
            forQuest: questID,
            isKeyItem: true
        )

        #expect(questItem.baseItem.name == "Ancient Key")
        #expect(questItem.questID == questID)
        #expect(questItem.isKeyItem == true)
        #expect(questItem.canBeDropped == false)
    }
}
